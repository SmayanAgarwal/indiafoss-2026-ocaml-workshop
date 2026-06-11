#!/usr/bin/env node
// Dashboard smoke check: loads _site/dashboard.html, lets its JS hit
// the real quiz Worker (/quiz/agg and /quiz/agg/readers), and verifies
// that the page settles into one of its two healthy states:
//
//   1. data state:  the headline cards rendered with numeric
//      "Total responses" / "Distinct readers" values, or
//   2. empty state: the explicit "No quiz responses yet" message.
//
// Anything else (the .err status, a hung "Loading..." spinner, console
// errors, uncaught page errors) exits 1. Modeled on playwright-check.mjs.

import { chromium } from 'playwright';

const URL = process.argv[2] || 'http://localhost:8765/_site/dashboard.html';

const failures = [];
const fail = (msg) => { failures.push(msg); console.error('FAIL: ' + msg); };

async function main() {
  const browser = await chromium.launch({ headless: true });
  const ctx = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await ctx.newPage();

  const events = [];
  const consoleErrors = [];
  page.on('console', m => {
    events.push(`console.${m.type()}: ${m.text()}`);
    // Ignore favicon 404 noise; everything else of type error counts.
    if (m.type() === 'error' && !m.text().includes('favicon')) {
      consoleErrors.push(m.text());
    }
  });
  page.on('pageerror', e => {
    events.push(`pageerror: ${e.message}`);
    consoleErrors.push('pageerror: ' + e.message);
  });
  page.on('requestfailed', r =>
    events.push(`requestfailed: ${r.url()} -- ${r.failure()?.errorText}`));

  await page.goto(URL, { waitUntil: 'domcontentloaded' });

  // Wait until the dashboard JS resolves out of the initial
  // "Loading aggregated stats..." state: either the cards section is
  // revealed, or #status switches to the empty / error message.
  try {
    await page.waitForFunction(() => {
      const status = document.getElementById('status');
      const cards = document.getElementById('cards');
      if (cards && cards.querySelector('.card')) return true;
      if (!status) return false;
      if (status.className === 'err') return true;
      return status.className === 'empty'
        && /No quiz responses yet/.test(status.textContent || '');
    }, null, { timeout: 30_000 });
  } catch {
    fail('dashboard never left the loading state within 30s');
  }

  const state = await page.evaluate(() => {
    const status = document.getElementById('status');
    const cards = Array.from(document.querySelectorAll('#cards .card')).map(c => ({
      label: c.querySelector('.label')?.textContent?.trim() ?? '',
      value: c.querySelector('.value')?.textContent?.trim() ?? '',
    }));
    return {
      statusClass: status?.className ?? '',
      statusText: status?.textContent?.trim() ?? '',
      statusHidden: status?.hidden ?? false,
      cards,
    };
  });

  if (state.statusClass === 'err') {
    fail('dashboard is in the error state: ' + state.statusText);
  } else if (state.cards.length > 0) {
    // Data state: headline cards must carry real numbers.
    console.log('cards rendered:', JSON.stringify(state.cards));
    for (const label of ['Total responses', 'Distinct readers']) {
      const card = state.cards.find(c => c.label === label);
      if (!card) fail(`headline card "${label}" missing`);
      else if (!/\d/.test(card.value)) {
        fail(`headline card "${label}" has no numeric value: "${card.value}"`);
      }
    }
  } else if (/No quiz responses yet/.test(state.statusText)) {
    // Explicit, intentional empty state: healthy.
    console.log('dashboard reports the explicit no-data state');
  } else {
    fail('dashboard in unrecognized state: class="' + state.statusClass
       + '" text="' + state.statusText + '" cards=' + state.cards.length);
  }

  if (consoleErrors.length > 0) {
    fail('console errors during load:\n  ' + consoleErrors.join('\n  '));
  }

  console.log('---events---');
  for (const e of events) console.log('  ' + e);

  await browser.close();

  if (failures.length > 0) {
    console.error(`\n${failures.length} dashboard check(s) failed`);
    process.exit(1);
  }
  console.log('\ndashboard check OK');
}

main().catch(e => { console.error(e); process.exit(1); });
