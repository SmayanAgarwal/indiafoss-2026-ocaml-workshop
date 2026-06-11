#!/usr/bin/env node
// Slide-overflow check: for each given lecture page, enter slide mode
// and verify every slide fits the 1280x800 reveal.js canvas.
//
//   node tools/playwright-overflow-check.mjs BASE_URL [page.html ...]
//
// BASE_URL is the directory serving _site/ contents (e.g.
// http://localhost:8765/_site). With no page args, checks every
// M*.html under _site/. Exits 1 if any slide overflows.

import { chromium } from 'playwright';
import { readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const BASE = process.argv[2] || 'http://localhost:8765/_site';
let pages = process.argv.slice(3);
if (pages.length === 0) {
  const site = join(dirname(fileURLToPath(import.meta.url)), '..', '_site');
  pages = readdirSync(site).filter(f => /^M\d\d-L\d\d-.*\.html$/.test(f)).sort();
}

// Slight tolerance: reveal reports a few px of slack on some themes.
const W = 1280, H = 800, SLACK = 2;

async function checkPage(page, url) {
  await page.goto(url + '#slides', { waitUntil: 'domcontentloaded' });
  const hasDeck = await page
    .waitForFunction(() => window.Reveal?.isReady?.(), null, { timeout: 30_000 })
    .then(() => true)
    .catch(() => false);
  if (!hasDeck) return { skipped: true };

  // Let the cells upgrade so heights are final (best effort: the
  // worker boot can be slow on the OxCaml bundle; cap the wait).
  await page
    .waitForFunction(
      () => Array.from(document.querySelectorAll('x-ocaml'))
        .every(c => c.shadowRoot?.querySelector('.run_btn button')),
      null, { timeout: 60_000 })
    .catch(() => {});
  await page.waitForTimeout(500);

  return await page.evaluate(([W, H, SLACK]) => {
    const R = window.Reveal;
    const total = R.getTotalSlides();
    const bad = [];
    const slides = document.querySelectorAll('.reveal .slides section');
    let n = 0;
    for (const s of slides) {
      if (s.querySelector('section')) continue; // container of subslides
      n++;
      const heading = s.querySelector('h1,h2,h3')?.textContent?.trim() ?? `#${n}`;
      const sw = s.scrollWidth, sh = s.scrollHeight;
      if (sw > W + SLACK || sh > H + SLACK) {
        bad.push(`${heading} (${sw}x${sh})`);
      }
    }
    return { total, bad };
  }, [W, H, SLACK]);
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({ viewport: { width: W, height: H } });
  const page = await ctx.newPage();
  let failures = 0;
  for (const p of pages) {
    const res = await checkPage(page, `${BASE}/${p}`);
    if (res.skipped) {
      console.log(`${p}: no deck (skipped)`);
      continue;
    }
    if (res.bad.length === 0) {
      console.log(`${p}: ${res.total} slides ok`);
    } else {
      failures += res.bad.length;
      console.error(`${p}: OVERFLOW on ${res.bad.length} slide(s):`);
      for (const b of res.bad) console.error(`    ${b}`);
    }
  }
  await browser.close();
  if (failures > 0) {
    console.error(`overflow-check: ${failures} overflowing slide(s)`);
    process.exit(1);
  }
  console.log('overflow-check: all slides fit');
}

main().catch(e => { console.error(e); process.exit(1); });
