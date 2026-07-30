#!/usr/bin/env node

/**
 * Page Map Index Generator & Coverage Tracker
 * Usage: node gen-pagemap.js <repo-path>
 */

const fs = require('fs');
const path = require('path');

const repoPath = process.argv[2] || '.';
const srcPagesDir = path.join(repoPath, 'src', 'pages');
const srcComponentsDir = path.join(repoPath, 'src', 'components');

const pageMapsDir = fs.existsSync(path.join(repoPath, '.pageel', 'page-maps'))
  ? path.join(repoPath, '.pageel', 'page-maps')
  : path.join(repoPath, '.para', 'page-maps');

function renderProgressBar(mapped, total) {
  if (total === 0) return '░░░░░░░░░░░░░░░░░░░░ 0/0 (0%)';
  const ratio = mapped / total;
  const filledCount = Math.round(ratio * 20);
  const emptyCount = 20 - filledCount;
  const bar = '█'.repeat(filledCount) + '░'.repeat(emptyCount);
  const percentage = Math.round(ratio * 100);
  return `${bar} ${mapped}/${total} (${percentage}%)`;
}

function scanFiles(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const entries = fs.readdirSync(dir);
  entries.forEach(entry => {
    const fullPath = path.join(dir, entry);
    if (fs.statSync(fullPath).isDirectory()) {
      scanFiles(fullPath, fileList);
    } else {
      if (['.astro', '.tsx', '.jsx', '.html', '.vue'].includes(path.extname(entry))) {
        fileList.push(fullPath);
      }
    }
  });
  return fileList;
}

console.log(`\n🗺️ Page-Map Generator scanning repository: ${repoPath}\n${'━'.repeat(50)}`);

const pages = scanFiles(srcPagesDir).map(p => path.relative(srcPagesDir, p));
const components = scanFiles(srcComponentsDir).map(c => path.relative(srcComponentsDir, c));

let mappedPagesCount = 0;
let mappedComponentsCount = 0;

const pageRows = pages.map(p => {
  const pageSlug = p.replace(/\.[^/.]+$/, '').replace(/\/index$/, '');
  const slugDirName = pageSlug === '' ? 'index' : pageSlug.replace(/\//g, '-');
  const mapPath = path.join(pageMapsDir, 'pages', slugDirName, 'PAGE_MAP.md');
  const isMapped = fs.existsSync(mapPath);
  if (isMapped) mappedPagesCount++;
  const status = isMapped ? '✅ Mapped' : '⬜ Pending';
  const mapLink = isMapped ? `[pages/${slugDirName}/](pages/${slugDirName}/PAGE_MAP.md)` : '—';
  return `| \`/${pageSlug}\` | \`src/pages/${p}\` | ${status} | ${mapLink} |`;
});

const componentRows = components.map(c => {
  const compName = path.basename(c, path.extname(c));
  const mapPath = path.join(pageMapsDir, 'components', compName, 'PAGE_MAP.md');
  const isMapped = fs.existsSync(mapPath);
  if (isMapped) mappedComponentsCount++;
  const status = isMapped ? '✅ Mapped' : '⬜ Pending';
  const mapLink = isMapped ? `[components/${compName}/](components/${compName}/PAGE_MAP.md)` : '—';
  return `| ${compName} | \`src/components/${c}\` | ${status} | ${mapLink} |`;
});

const indexContent = `# Site Map Index

> Last updated: ${new Date().toISOString().split('T')[0]}

## Pages

| Route | Source | Status | Map |
| :--- | :--- | :--- | :--- |
${pageRows.join('\n')}

Pages: \`${renderProgressBar(mappedPagesCount, pages.length)}\`

## Components

| Component | Source | Status | Map |
| :--- | :--- | :--- | :--- |
${componentRows.join('\n')}

Components: \`${renderProgressBar(mappedComponentsCount, components.length)}\`
`;

if (!fs.existsSync(pageMapsDir)) {
  fs.mkdirSync(pageMapsDir, { recursive: true });
}

const indexPath = path.join(pageMapsDir, 'INDEX.md');
fs.writeFileSync(indexPath, indexContent, 'utf8');

console.log(`✅ INDEX.md updated at: ${indexPath}`);
console.log(`📊 Pages Coverage: ${mappedPagesCount}/${pages.length}`);
console.log(`📊 Components Coverage: ${mappedComponentsCount}/${components.length}\n`);
