#!/usr/bin/env node

/**
 * PARA Plan Structural Linter (OSS Edition)
 * 
 * Usage: node lint-plan.js <path-to-plan> <path-to-template>
 * 
 * Verifies that the plan file contains all structural headings defined in the template.
 * Headings MUST be written in English (OSS-first standard).
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

// Clean and normalize text to flat lowercase words
function tokenizeAndClean(text) {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')            // Remove diacritics
    .replace(/\[[^\]]+\]/g, '')                 // Remove [placeholder]
    .replace(/[⚙️🟢🟡🔴\-\:\`\'\’\”\“\"\(\)\,\&\→]/g, ' ') // Replace symbols with spaces
    .split(/\s+/)
    .map(w => w.trim())
    .filter(w => w.length > 0);
}

// Check if a template heading is optional or explanatory
function isOptionalOrExplanatory(text) {
  const norm = text.toLowerCase();
  return (
    norm.includes('template') ||
    norm.includes('optional') ||
    norm.includes('block') ||
    norm.includes('if project') ||
    norm.includes('if has') ||
    norm.includes('if any') ||
    norm.includes('schema') ||
    norm.includes('code reuse')
  );
}

function matchHeadings(templateHeadings, planHeadings) {
  const missing = [];
  
  // Skip the first template heading as it's always the template title
  const targetTemplateHeadings = templateHeadings.slice(1);

  for (const tHead of targetTemplateHeadings) {
    if (isOptionalOrExplanatory(tHead.text)) {
      continue;
    }

    const tTokens = tokenizeAndClean(tHead.text);
    if (tTokens.length === 0) continue;

    const tCleanedString = tTokens.join(' ');
    let found = false;

    for (const pHead of planHeadings) {
      // Allow level drift of ±1
      if (Math.abs(pHead.level - tHead.level) > 1) {
        continue;
      }

      const pTokens = tokenizeAndClean(pHead.text);
      const pCleanedString = pTokens.join(' ');

      // 1. Substring Match of normalized string
      if (pCleanedString.includes(tCleanedString) || tCleanedString.includes(pCleanedString)) {
        found = true;
        break;
      }

      // 2. Keyword Intersection Match (for dynamic phase names / extra text)
      // If at least 50% of the keywords from the template heading are present in the plan heading
      const intersection = tTokens.filter(tok => pTokens.includes(tok));
      const matchRatio = intersection.length / tTokens.length;
      
      // If it has at least 2 matching words and ratio >= 0.5, count as match
      if (matchRatio >= 0.5 && (tTokens.length === 1 || intersection.length >= 2)) {
        found = true;
        break;
      }
    }

    if (!found) {
      missing.push(`${'#'.repeat(tHead.level)} ${tHead.text}`);
    }
  }

  return missing;
}

function main() {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    console.error('Usage: node lint-plan.js <path-to-plan> <path-to-template>');
    process.exit(1);
  }

  const planPath = path.resolve(args[0]);
  const templatePath = path.resolve(args[1]);

  if (!fs.existsSync(planPath)) {
    console.error(`Error: Plan file not found at ${planPath}`);
    process.exit(1);
  }

  if (!fs.existsSync(templatePath)) {
    console.error(`Error: Template file not found at ${templatePath}`);
    process.exit(1);
  }

  const planContent = fs.readFileSync(planPath, 'utf8');
  const templateContent = fs.readFileSync(templatePath, 'utf8');

  const planHeadings = getHeadings(planContent);
  const templateHeadings = getHeadings(templateContent);

  const missing = matchHeadings(templateHeadings, planHeadings);

  // Content Inspection 1: Secrets & Fallback Strategy Placeholder Check
  if (templateContent.includes('Secrets & Fallback Strategy')) {
    if (!planContent.includes('Secrets & Fallback Strategy')) {
      missing.push('## Secrets & Fallback Strategy (Environment Variables & Observability)');
    } else {
      const secretsSection = planContent.split(/##\s+Secrets/i)[1]?.split(/##\s+/)[0] || '';
      if (secretsSection.includes('[ENV_VAR_NAME]')) {
        missing.push('## Secrets & Fallback Strategy: Contains unreplaced template placeholders ([ENV_VAR_NAME]). Agent MUST analyze and list real project env variables or explicit "None".');
      }
    }
  }

  // Content Inspection 2: Techstack Live Deployment Task Check
  const planDir = path.dirname(planPath);
  const projectDir = path.dirname(planDir);
  const hasWrangler = fs.existsSync(path.join(projectDir, 'wrangler.toml')) || 
                      fs.existsSync(path.join(projectDir, 'repo/wrangler.toml')) || 
                      fs.existsSync(path.join(projectDir, 'repo/worker/wrangler.toml'));
  const hasVercel = fs.existsSync(path.join(projectDir, 'vercel.json')) || 
                    fs.existsSync(path.join(projectDir, 'repo/vercel.json'));

  if ((hasWrangler || hasVercel) && !planContent.toLowerCase().includes('deploy')) {
    missing.push('Phase 7: Missing Live Deployment Gate task! (Project contains wrangler.toml/vercel.json live deployment config but plan lacks deployment task)');
  }

  if (missing.length > 0) {
    console.error('\n❌ Plan Structural & Content Lint Failed!');
    console.error('The following issues were detected against template & project rules:');
    missing.forEach(h => console.error(`  - ${h}`));
    console.error('\nPlease resolve these issues to align with project governance rules.\n');
    process.exit(1);
  }

  console.log('\n✅ Plan Structural & Content Lint Passed! All mandatory template headings and env/deployment rules are verified.');
  process.exit(0);
}

if (require.main === module) {
  main();
}
