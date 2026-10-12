#!/usr/bin/env node
import { createRequire } from 'node:module';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { parseArgs } from 'node:util';

const HELP = `Screenshot a page of the Ravenna Core (Admissions) prototype.

Usage: node render-prototype.mjs [--page <id>] [--click <selector>]... [--eval <js>]... [--out <png>]

  --page <id>         Call admNav('<id>') first (default: landing page as loaded)
  --click <selector>  Click the first match; repeatable, runs in order after --page
  --eval <js>         Evaluate in the page; repeatable, runs after --click steps
  --out <png>         Screenshot path (default: /tmp/ravenna-<active page>.png)
  --width <px>        Viewport width (default: 1440)
  --viewport          Capture the viewport only (default: full page)
  --file <html>       Prototype file (default: ~/Projects/us-suite-design-system/ravenna-suite/core/index.html)

Resolves playwright from the current directory: run it from a checkout that has
playwright in node_modules (Hub does).

Prints JSON: {"activePage": "<id>", "out": "<png>"}`;

const { values } = parseArgs({
  options: {
    page: { type: 'string' },
    click: { type: 'string', multiple: true, default: [] },
    eval: { type: 'string', multiple: true, default: [] },
    out: { type: 'string' },
    width: { type: 'string', default: '1440' },
    viewport: { type: 'boolean', default: false },
    file: { type: 'string', default: join(homedir(), 'Projects/us-suite-design-system/ravenna-suite/core/index.html') },
    help: { type: 'boolean', default: false },
  },
});

if (values.help) {
  console.log(HELP);
  process.exit(0);
}

let chromium;
try {
  ({ chromium } = createRequire(join(process.cwd(), 'noop.js'))('playwright'));
} catch {
  console.error(`Expected playwright in ${process.cwd()}/node_modules. Try: cd ~/local/hub/dev && node ${process.argv[1]} ...`);
  process.exit(1);
}

const browser = await chromium.launch();
try {
  const page = await browser.newPage({ viewport: { width: Number(values.width), height: 900 } });
  await page.goto(`file://${values.file}`);
  if (values.page) await page.evaluate((id) => admNav(id), values.page);
  for (const selector of values.click) await page.locator(selector).first().click();
  for (const script of values.eval) await page.evaluate(script);

  const activePage = (await page.locator('.rv-page.is-active').first().getAttribute('id'))?.replace(/^adm-page-/, '');
  const out = values.out ?? `/tmp/ravenna-${activePage}.png`;
  await page.screenshot({ path: out, fullPage: !values.viewport });
  console.log(JSON.stringify({ activePage, out }));
} finally {
  await browser.close();
}
