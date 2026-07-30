#!/usr/bin/env node

/**
 * Static Mobile Responsive AST/RegEx Linter for AI Agents
 * Usage: node check-responsive.js <file-or-directory-path>
 */

const fs = require('fs');
const path = require('path');

const targetPath = process.argv[2] || '.';

let totalFilesChecked = 0;
let totalViolations = 0;
const results = [];

function checkFile(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  if (!['.astro', '.html', '.jsx', '.tsx', '.vue', '.css', '.scss', '.svelte'].includes(ext)) {
    return;
  }

  totalFilesChecked++;
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  const fileViolations = [];

  lines.forEach((line, index) => {
    const lineNum = index + 1;

    // R1: Fixed width check (> 320px in inline styles or css without max-width)
    let fixedWidthMatch = null;
    if (!line.includes('@media')) {
      fixedWidthMatch = line.match(/(?:width|min-width)\s*:\s*([3-9]\d{2}|\d{4,})px/i);
      if (fixedWidthMatch && !line.includes('max-width')) {
        fileViolations.push({
          line: lineNum,
          rule: 'R1 (Zero Fixed Layout Widths)',
          message: `Fixed width of ${fixedWidthMatch[1]}px detected without max-width constraint.`
        });
      }
    }

    // R1: Tailwind fixed width classes like w-[400px], w-[600px], min-w-[500px]
    const tailwindFixedWidthMatch = line.match(/(?:min-)?w-\[([3-9]\d{2}|\d{4,})px\]/i);
    if (tailwindFixedWidthMatch && !line.includes('max-w-')) {
      fileViolations.push({
        line: lineNum,
        rule: 'R1 (Zero Fixed Layout Widths)',
        message: `Tailwind fixed width class w-[${tailwindFixedWidthMatch[1]}px] detected without max-w constraint.`
      });
    }

    // R2: Small Touch Target (< 44px height for interactive elements)
    if (/<(button|a|select|input)\b/i.test(line)) {
      // Check Tailwind class: h-[30px], min-h-[30px]
      const twHeightMatch = line.match(/(?:min-)?h-\[(\d{1,2})px\]/i);
      if (twHeightMatch && parseInt(twHeightMatch[1], 10) < 44) {
        fileViolations.push({
          line: lineNum,
          rule: 'R2 (Minimum Touch Targets)',
          message: `Interactive element height h-[${twHeightMatch[1]}px] is smaller than minimum 44px.`
        });
      }
      // Check inline CSS: height: 30px, min-height: 30px
      const cssHeightMatch = line.match(/(?:min-)?height\s*:\s*(\d{1,2})px/i);
      if (cssHeightMatch && parseInt(cssHeightMatch[1], 10) < 44) {
        fileViolations.push({
          line: lineNum,
          rule: 'R2 (Minimum Touch Targets)',
          message: `Interactive element inline CSS height ${cssHeightMatch[1]}px is smaller than minimum 44px.`
        });
      }
    }

    // R3: Text Overflow Safety — containers with dynamic text lacking break-word
    if (/<(p|span|h[1-6]|div|li|td|th|label)\b/i.test(line)) {
      // Flag elements with fixed widths but no overflow-wrap/break-word protection
      if (fixedWidthMatch && !line.includes('break-word') && !line.includes('overflow-wrap') && !line.includes('truncate') && !line.includes('overflow-hidden')) {
        fileViolations.push({
          line: lineNum,
          rule: 'R3 (Text Overflow Safety)',
          message: 'Text container with fixed width lacks overflow-wrap: break-word protection.'
        });
      }
    }

    // R4: Unconstrained img or video tag without max-w-full or max-width: 100%
    if (/<(img|video|iframe|svg|canvas)\b/i.test(line) && !line.includes('max-w-full') && !line.includes('max-width') && !line.includes('w-full')) {
      fileViolations.push({
        line: lineNum,
        rule: 'R4 (Media Fluidity)',
        message: 'Media element without max-width constraint (needs max-w-full or max-width: 100%).'
      });
    }

    // R6: Off-Screen Drawer Visibility Guard (detect off-screen drawer position without visibility: hidden or pointer-events: none)
    if (/(?:right|left)\s*:\s*-(?:100%|100vw|[1-9]\d{2,}px)|^.*(?:translateX|translateY)\(-(?:100%|100vw|[1-9]\d{2,}px)/i.test(line)) {
      if (!content.includes('visibility') && !content.includes('pointer-events') && !content.includes('display: none') && !content.includes('display:none')) {
        fileViolations.push({
          line: lineNum,
          rule: 'R6 (Off-Screen Drawer Visibility Guard)',
          message: 'Off-screen element detected without visibility: hidden or pointer-events: none constraint. Causes horizontal swipe overflow.'
        });
      }
    }
  });

  // R5: Viewport Meta Tag check in main HTML/Astro files
  if (['.html', '.astro'].includes(ext) && (filePath.includes('Layout') || filePath.includes('index') || filePath.includes('head'))) {
    if (!content.includes('name="viewport"') && !content.includes("name='viewport'")) {
      fileViolations.push({
        line: 1,
        rule: 'R5 (Viewport Meta Tag)',
        message: 'Missing <meta name="viewport" content="width=device-width, initial-scale=1.0"> tag.'
      });
    }
  }

  if (fileViolations.length > 0) {
    totalViolations += fileViolations.length;
    results.push({ file: filePath, violations: fileViolations });
  }
}

function scanDir(dirPath) {
  if (fs.statSync(dirPath).isFile()) {
    checkFile(dirPath);
    return;
  }

  const entries = fs.readdirSync(dirPath);
  entries.forEach(entry => {
    if (entry.startsWith('.') || entry === 'node_modules' || entry === 'dist' || entry === 'build') {
      return;
    }
    const fullPath = path.join(dirPath, entry);
    if (fs.statSync(fullPath).isDirectory()) {
      scanDir(fullPath);
    } else {
      checkFile(fullPath);
    }
  });
}

console.log(`\n🔍 Mobile Responsive Linter scanning: ${targetPath}\n${'━'.repeat(50)}`);

if (!fs.existsSync(targetPath)) {
  console.error(`❌ Path not found: ${targetPath}`);
  process.exit(1);
}

scanDir(targetPath);

if (results.length === 0) {
  console.log(`✅ VERDICT: PASS | Checked ${totalFilesChecked} files. Zero mobile responsive violations found.\n`);
  process.exit(0);
} else {
  console.log(`❌ VERDICT: FAIL | Found ${totalViolations} violation(s) across ${results.length} file(s):\n`);
  results.forEach(res => {
    console.log(`📄 File: ${res.file}`);
    res.violations.forEach(v => {
      console.log(`   └─ [Line ${v.line}] [${v.rule}]: ${v.message}`);
    });
    console.log('');
  });
  process.exit(1);
}
