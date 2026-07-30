#!/usr/bin/env node

/**
 * PARA Project Rules Scanner Utility (v1.9.6)
 * 
 * Usage: node scan-project-rules.js <path-or-project-name> [--json]
 * 
 * Dynamically discovers and extracts project-specific operational rules
 * from `Projects/<project>/.agents/rules/*.md` and `project.md`.
 */

const fs = require('fs');
const path = require('path');

function resolveProjectPath(targetPath) {
  if (!targetPath) {
    targetPath = process.cwd();
  }
  
  if (fs.existsSync(targetPath) && fs.statSync(targetPath).isDirectory()) {
    // If path is a plan file, resolve project parent dir
    if (targetPath.includes('artifacts/plans')) {
      const idx = targetPath.indexOf('/artifacts/');
      if (idx !== -1) {
        return targetPath.substring(0, idx);
      }
    }
    return targetPath;
  }

  if (fs.existsSync(targetPath) && fs.statSync(targetPath).isFile()) {
    // If path is a plan file path
    const abs = path.resolve(targetPath);
    const idx = abs.indexOf('/artifacts/plans');
    if (idx !== -1) {
      return abs.substring(0, idx);
    }
    return path.dirname(abs);
  }

  // Fallback to searching Projects/<targetPath>
  const workspaceRoot = process.cwd();
  const projPath = path.join(workspaceRoot, 'Projects', targetPath);
  if (fs.existsSync(projPath)) {
    return projPath;
  }

  return targetPath;
}

function parseRuleHeadings(filePath, projectRoot) {
  if (!fs.existsSync(filePath)) return [];
  
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  const relPath = path.relative(projectRoot, filePath);
  const rules = [];

  let currentRule = null;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    // Match H3 section headings like ### M1. Title or ### M6. Tool Release Process
    const h3Match = line.match(/^###\s+([A-Z0-9\.]+)\.?\s+(.+)$/i);
    if (h3Match) {
      if (currentRule) {
        rules.push(currentRule);
      }
      
      const rawId = h3Match[1].replace(/\.$/, '').toUpperCase();
      const title = h3Match[2].trim();
      
      currentRule = {
        id: rawId,
        title: title,
        file: relPath,
        mandatory: true,
        keywords: tokenizeKeywords(`${rawId} ${title}`)
      };
    } else if (currentRule) {
      // Look for key phrases in rule body
      if (line.includes('MUST') || line.includes('mandatory') || line.includes('Phase N')) {
        const words = line.replace(/[^a-zA-Z0-9_\-\.\/]/g, ' ').split(/\s+/).filter(w => w.length > 3);
        currentRule.keywords = Array.from(new Set([...currentRule.keywords, ...words.slice(0, 5)]));
      }
    }
  }

  if (currentRule) {
    rules.push(currentRule);
  }

  return rules;
}

function tokenizeKeywords(text) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9_\-\.\/]/g, ' ')
    .split(/\s+/)
    .filter(w => w.length > 1);
}

function scanProjectRules(projectPath) {
  const absProjectRoot = path.resolve(projectPath);
  const rulesDir = path.join(absProjectRoot, '.agents', 'rules');
  const indexRule = path.join(absProjectRoot, '.agents', 'rules.md');

  const allRules = [];

  // 1. Check .agents/rules/ directory
  if (fs.existsSync(rulesDir) && fs.statSync(rulesDir).isDirectory()) {
    const files = fs.readdirSync(rulesDir);
    for (const file of files) {
      if (file.endsWith('.md')) {
        const rules = parseRuleHeadings(path.join(rulesDir, file), absProjectRoot);
        allRules.push(...rules);
      }
    }
  }

  // 2. Check .agents/rules.md index file if exists
  if (fs.existsSync(indexRule)) {
    const rules = parseRuleHeadings(indexRule, absProjectRoot);
    for (const r of rules) {
      if (!allRules.some(existing => existing.id === r.id)) {
        allRules.push(r);
      }
    }
  }

  // Check if project.md has compliance: schema
  const projectMdPath = path.join(absProjectRoot, 'project.md');
  let hasComplianceSchema = false;
  if (fs.existsSync(projectMdPath)) {
    const content = fs.readFileSync(projectMdPath, 'utf-8');
    if (content.includes('compliance:')) {
      hasComplianceSchema = true;
    }
  }

  return {
    projectRoot: absProjectRoot,
    projectName: path.basename(absProjectRoot),
    ruleCount: allRules.length,
    hasComplianceSchema,
    rules: allRules
  };
}

// CLI Execution
if (require.main === module) {
  const args = process.argv.slice(2);
  const target = args.find(a => !a.startsWith('--')) || '.';
  const isJson = args.includes('--json');

  const resolvedPath = resolveProjectPath(target);
  const result = scanProjectRules(resolvedPath);

  if (isJson) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(`\n🔍 PROJECT RULES AUDIT MATRIX — ${result.projectName}`);
    console.log(`📁 Path: ${result.projectRoot}`);
    console.log(`📋 Total Rules Discovered: ${result.ruleCount}\n`);

    if (result.rules.length === 0) {
      console.log(`ℹ️ No specialized project-level rules (M1-M7) found in .agents/rules/.\n`);
    } else {
      console.log(`| Rule ID | Rule Title | Defined File | Mandatory | Keywords |`);
      console.log(`|:---|:---|:---|:---:|:---|`);
      for (const r of result.rules) {
        console.log(`| **${r.id}** | ${r.title} | \`${r.file}\` | ${r.mandatory ? '✅ Yes' : '⚪ No'} | \`${r.keywords.slice(0, 4).join(', ')}\` |`);
      }
      console.log('');
    }

    if (!result.hasComplianceSchema) {
      console.log(`💡 SUGGESTION: 'project.md' is missing the 'compliance:' schema mapping.`);
      console.log(`   Consider adding 'compliance.rules_dir' and 'compliance.mandatory_modules' to project.md for explicit rule enforcement.\n`);
    }
  }
}


module.exports = {
  scanProjectRules,
  resolveProjectPath
};
