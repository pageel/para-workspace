#!/usr/bin/env node

/**
 * PARA QA Structural & Report Housekeeping Linter (v1.0.0)
 * 
 * Usage: node lint-qa.js <path-to-qa-report> [path-to-template-or-skill]
 * 
 * Verifies that a QA report file contains all mandatory structural headings,
 * complies with header metadata specifications, and has no unclosed Pending states
 * when marked as final.
 */

const fs = require('fs');
const path = require('path');

function getHeadings(content) {
  const headings = [];
  const lines = content.split('\n');
  let inCodeBlock = false;

  for (let line of lines) {
    if (line.trim().startsWith('```')) {
      inCodeBlock = !inCodeBlock;
      continue;
    }
    if (inCodeBlock) continue;

    const match = line.match(/^(#{1,6})\s+(.+)$/);
    if (match) {
      headings.push({
        level: match[1].length,
        text: match[2].trim()
      });
    }
  }
  return headings;
}

function tokenizeAndClean(text) {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')            // Remove diacritics
    .replace(/\[[^\]]+\]/g, '')                 // Remove [placeholder]
    .replace(/[🛡️⚙️🟢🟡🔴🚀📋📌📊\-\:\`\'\’\”\“\"\(\)\,\&\→]/g, ' ')
    .split(/\s+/)
    .map(w => w.trim())
    .filter(w => w.length > 0);
}

const MANDATORY_QA_HEADINGS = [
  'QA Strategy',
  'Focus Areas',
  'Red Team Roster',
  'Process Log',
  'Next Steps',
  'Red Team Findings',
  'Summary'
];

function checkHeadings(headings) {
  const missing = [];
  const foundTextList = headings.map(h => tokenizeAndClean(h.text).join(' '));

  for (const mandatory of MANDATORY_QA_HEADINGS) {
    const mTokens = tokenizeAndClean(mandatory);
    const mStr = mTokens.join(' ');

    let found = false;
    for (const fStr of foundTextList) {
      if (fStr.includes(mStr) || mStr.includes(fStr)) {
        found = true;
        break;
      }
      const fTokens = fStr.split(' ');
      const intersection = mTokens.filter(tok => fTokens.includes(tok));
      if (mTokens.length > 0 && (intersection.length / mTokens.length) >= 0.5) {
        found = true;
        break;
      }
    }

    if (!found) {
      missing.push(mandatory);
    }
  }
  return missing;
}

function lintQAReport(qaPath) {
  if (!fs.existsSync(qaPath)) {
    console.error(`Error: QA Report file not found at ${qaPath}`);
    process.exit(1);
  }

  const content = fs.readFileSync(qaPath, 'utf8');
  const headings = getHeadings(content);
  const issues = [];

  // 1. Mandatory Headings Check
  const missingHeadings = checkHeadings(headings);
  if (missingHeadings.length > 0) {
    missingHeadings.forEach(h => issues.push(`Missing Mandatory Section/Heading: '${h}'`));
  }

  // 2. Header Metadata Check
  if (!content.includes('Process:') && !content.includes('Q&A review')) {
    issues.push("Header Metadata: Missing '> **Process:**' definition in report header");
  }
  if (!content.includes('Target:')) {
    issues.push("Header Metadata: Missing '> **Target:**' path definition in report header");
  }

  // 3. Housekeeping Check: Pending state when Final Verdict is assigned
  const hasHeaderFinalVerdict = content.includes('> **Verdict:** `[✅') || content.includes('> **Verdict:** `[Ready') || content.includes('> **Verdict:** `[🔴');
  const hasSummaryFinalVerdict = content.includes('VERDICT: ✅ Ready') || content.includes('FINAL VERDICT: ✅');
  const isFinalVerdict = hasHeaderFinalVerdict || hasSummaryFinalVerdict;
  const isIntermediateRound = content.includes('Verdict:** `[Pending') || content.includes('ROUND 1 VERDICT') || content.includes('Round 1 in Progress');

  if (isFinalVerdict && !isIntermediateRound) {
    // If report has reached final verdict, check for orphan ⏳ Pending items in Focus Areas or Checklist
    const lines = content.split('\n');
    let pendingCount = 0;
    for (let line of lines) {
      if (line.includes('⏳ Pending') && !line.includes('Initial')) {
        pendingCount++;
      }
    }
    if (pendingCount > 0) {
      issues.push(`Report Housekeeping: Finalized QA report contains ${pendingCount} unclosed '⏳ Pending' state item(s) in Focus Areas or Governance Checklist.`);
    }
  }


  if (issues.length > 0) {
    console.error('\n❌ QA Report Structural & Content Lint Failed!');
    console.error('The following issues were detected against QA Template standards:');
    issues.forEach(i => console.error(`  - ${i}`));
    console.error('\nPlease resolve these issues to align with QA workflow standards.\n');
    process.exit(1);
  }

  console.log('\n✅ QA Report Structural & Content Lint Passed! All mandatory headings and housekeeping rules verified.');
  process.exit(0);
}

function main() {
  const args = process.argv.slice(2);
  if (args.length < 1) {
    console.error('Usage: node lint-qa.js <path-to-qa-report>');
    process.exit(1);
  }

  lintQAReport(path.resolve(args[0]));
}

if (require.main === module) {
  main();
}
