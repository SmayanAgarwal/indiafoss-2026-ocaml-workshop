#!/usr/bin/env node
// End-to-end check for the in-browser dune VM playground: load the
// playground page, click Start, wait for the shell prompt on the
// serial console, build and run the hello project, assert its
// output. The VM data normally comes from the production
// fplaunchpad/ocaml-browser-vm Pages site; set VMBASE to serve it
// locally (run-tests.sh does when the scratch dir is present).

import { chromium } from 'playwright';

const PAGE_URL = process.argv[2] || 'http://localhost:8765/_site/playground.html';
const VMBASE = process.env.VMBASE || '';
const url = VMBASE ? `${PAGE_URL}?vmbase=${encodeURIComponent(VMBASE)}` : PAGE_URL;

async function main() {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await ctx.newPage();

  const events = [];
  page.on('pageerror', e => events.push(`pageerror: ${e.message}`));
  page.on('requestfailed', r => events.push(`requestfailed: ${r.url()} -- ${r.failure()?.errorText}`));

  console.log('loading', url);
  await page.goto(url, { waitUntil: 'domcontentloaded' });

  // Component initialised: the click-to-boot placeholder is up and
  // nothing heavy has been fetched yet.
  await page.waitForSelector('.vm-terminal button.vm-start', { timeout: 15_000 });
  console.log('placeholder rendered');

  await page.click('.vm-terminal button.vm-start');

  // The emulator object appears once xterm + libv86 are loaded.
  await page.waitForFunction(
    () => !!document.querySelector('.vm-terminal')?.vmEmulator,
    null, { timeout: 60_000 });

  // Tap the serial console for assertions.
  await page.evaluate(() => {
    window.__serial = '';
    document.querySelector('.vm-terminal').vmEmulator
      .add_listener('serial0-output-byte',
        b => { window.__serial += String.fromCharCode(b); });
  });

  // Boot snapshot restore + prompt poke. Generous: CI is slow and
  // the state download may come over the network. Match prompt by
  // containment: the getty follows it with an ESC[6n status query
  // in the same burst, so endsWith never fires.
  try {
    await page.waitForFunction(
      () => window.__serial.includes(':~# '),
      null, { timeout: 120_000 });
  } catch (e) {
    const tail = await page.evaluate(() => JSON.stringify(window.__serial.slice(-200)));
    const status = await page.evaluate(
      () => document.querySelector('.vm-terminal .vm-status')?.textContent || '');
    console.error('no shell prompt; serial tail:', tail);
    console.error('status line:', status.trim());
    throw e;
  }
  console.log('shell prompt reached');

  // Type through xterm (exercises the real input path).
  await page.click('.vm-terminal .vm-term');
  await page.keyboard.type('cd hello && dune build && ./_build/default/hello.exe', { delay: 10 });
  await page.keyboard.press('Enter');

  // First build fetches toolchain chunks on demand; allow plenty.
  await page.waitForFunction(
    () => window.__serial.includes('Hello from dune'),
    null, { timeout: 180_000 });
  console.log('hello built and ran inside the VM');

  const status = await page.evaluate(
    () => document.querySelector('.vm-terminal .vm-status')?.textContent || '');
  console.log('status line:', status.trim());

  if (events.length) {
    console.log('---events---');
    for (const e of events) console.log('  ' + e);
  }

  await browser.close();
}

main().catch(e => { console.error(e); process.exit(1); });
