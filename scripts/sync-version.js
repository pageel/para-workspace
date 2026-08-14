#!/usr/bin/env node

/**
 * PARA Version Synchronization & Release Quality Gatekeeper (Rule M2, M1, KR7)
 * 
 * Usage:
 *   node scripts/sync-version.js --check
 *   node scripts/sync-version.js <new_version> [--dry-run]
 *   node scripts/sync-version.js <new_version> --apply
 */

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');
const PROJECT_MD = path.resolve(REPO_ROOT, '../project.md');
const KNOWLEDGE_DIR = path.resolve(REPO_ROOT, 'templates/knowledge');
const LOCALES_DIR = path.resolve(REPO_ROOT, 'docs/locales');
const AGENTS_DIR = path.resolve(REPO_ROOT, 'templates/common/agents');

// 1. SemVer Validator
function isValidSemver(v) {
  return /^\d+\.\d+\.\d+(\.[\w.-]+)?$/.test(v);
}

// 2. Gate 1: Check CHANGELOG.md entry
function checkChangelogEntry(v) {
  const changelogPath = path.resolve(REPO_ROOT, 'CHANGELOG.md');
  if (!fs.existsSync(changelogPath)) return { pass: false, error: 'CHANGELOG.md missing' };
  const content = fs.readFileSync(changelogPath, 'utf8');
  const hasEntry = content.includes(`## [${v}]`);
  return {
    pass: hasEntry,
    error: hasEntry ? null : `Missing entry '## [${v}]' in CHANGELOG.md`
  };
}

// 3. Gate 2: Check M1 Catalog Double-Declaration
function checkM1Catalogs() {
  const issues = [];

  // Check Workflows
  const wfCatalogPath = path.join(AGENTS_DIR, 'workflows/catalog.yml');
  if (fs.existsSync(wfCatalogPath)) {
    const wfCatalog = fs.readFileSync(wfCatalogPath, 'utf8');
    const wfFiles = fs.readdirSync(path.join(AGENTS_DIR, 'workflows'))
      .filter(f => f.endsWith('.md') && f !== 'README.md');
    
    wfFiles.forEach(f => {
      const id = f.replace('.md', '');
      if (!wfCatalog.includes(`id: ${id}`) && !wfCatalog.includes(`id: "${id}"`)) {
        issues.push(`Workflow '${f}' not declared in workflows/catalog.yml`);
      }
    });
  }

  // Check Skills
  const skCatalogPath = path.join(AGENTS_DIR, 'skills/catalog.yml');
  if (fs.existsSync(skCatalogPath)) {
    const skCatalog = fs.readFileSync(skCatalogPath, 'utf8');
    const skDirs = fs.readdirSync(path.join(AGENTS_DIR, 'skills'))
      .filter(f => fs.statSync(path.join(AGENTS_DIR, 'skills', f)).isDirectory());
    
    skDirs.forEach(d => {
      if (!skCatalog.includes(`id: ${d}`) && !skCatalog.includes(`id: "${d}"`)) {
        issues.push(`Skill '${d}' not declared in skills/catalog.yml`);
      }
    });
  }

  return {
    pass: issues.length === 0,
    issues
  };
}

// 4. Gate 3: Check KR7 Ephemeral Reference Sanitation
function checkKR7References() {
  const issues = [];
  if (fs.existsSync(KNOWLEDGE_DIR)) {
    const dirs = fs.readdirSync(KNOWLEDGE_DIR).filter(f => fs.statSync(path.join(KNOWLEDGE_DIR, f)).isDirectory());
    dirs.forEach(d => {
      const metaPath = path.join(KNOWLEDGE_DIR, d, 'metadata.json');
      if (fs.existsSync(metaPath)) {
        const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
        if (Array.isArray(meta.references)) {
          meta.references.forEach(ref => {
            const refStr = typeof ref === 'string' ? ref : (ref.uri || ref.path || JSON.stringify(ref));
            if (refStr.includes('artifacts/plans/') || refStr.includes('sprint-current.md') || refStr.includes('sessions/')) {
              issues.push(`Ephemeral reference in ${d}/metadata.json: ${refStr}`);
            }
          });
        }
      }
    });
  }
  return {
    pass: issues.length === 0,
    issues
  };
}

// 5. Read Versions across all locations
function auditVersions() {
  const results = {};

  // 1. VERSION
  const vPath = path.join(REPO_ROOT, 'VERSION');
  results['repo/VERSION'] = fs.existsSync(vPath) ? fs.readFileSync(vPath, 'utf8').trim() : 'MISSING';

  // 2. VERSIONS.yml
  const vyPath = path.join(REPO_ROOT, 'VERSIONS.yml');
  if (fs.existsSync(vyPath)) {
    const m = fs.readFileSync(vyPath, 'utf8').match(/^workspace:\s*["']?([\w.-]+)["']?/m);
    results['repo/VERSIONS.yml'] = m ? m[1] : 'UNKNOWN';
  } else {
    results['repo/VERSIONS.yml'] = 'MISSING';
  }

  // 3. cli/para
  const cliPath = path.join(REPO_ROOT, 'cli/para');
  if (fs.existsSync(cliPath)) {
    const m = fs.readFileSync(cliPath, 'utf8').match(/^# Version:\s*([\w.-]+)/m);
    results['repo/cli/para'] = m ? m[1] : 'UNKNOWN';
  } else {
    results['repo/cli/para'] = 'MISSING';
  }

  // 4. project.md
  if (fs.existsSync(PROJECT_MD)) {
    const m = fs.readFileSync(PROJECT_MD, 'utf8').match(/^version:\s*["']?([\w.-]+)["']?/m);
    results['Projects/para-workspace/project.md'] = m ? m[1] : 'UNKNOWN';
  } else {
    results['Projects/para-workspace/project.md'] = 'MISSING';
  }

  // 5. README.md
  const rmPath = path.join(REPO_ROOT, 'README.md');
  if (fs.existsSync(rmPath)) {
    const content = fs.readFileSync(rmPath, 'utf8');
    const badgeMatch = content.match(/badge\/version-([\w.-]+)-blue\.svg/);
    const footerMatch = content.match(/_Version:\s*([\w.-]+)_/);
    results['repo/README.md (badge)'] = badgeMatch ? badgeMatch[1] : 'UNKNOWN';
    results['repo/README.md (footer)'] = footerMatch ? footerMatch[1] : 'UNKNOWN';
  } else {
    results['repo/README.md'] = 'MISSING';
  }

  // 6. Locales
  if (fs.existsSync(LOCALES_DIR)) {
    const locales = fs.readdirSync(LOCALES_DIR).filter(f => f.endsWith('.md'));
    locales.forEach(loc => {
      const locPath = path.join(LOCALES_DIR, loc);
      const content = fs.readFileSync(locPath, 'utf8');
      const badgeMatch = content.match(/badge\/version-([\w.-]+)-blue\.svg/);
      const footerMatch = content.match(/_(?:Version|Phiên bản|版本|Versión):\s*([\w.-]+)_/i);
      results[`docs/locales/${loc} (badge)`] = badgeMatch ? badgeMatch[1] : 'UNKNOWN';
      results[`docs/locales/${loc} (footer)`] = footerMatch ? footerMatch[1] : 'UNKNOWN';
    });
  }

  // 7. System KIs
  if (fs.existsSync(KNOWLEDGE_DIR)) {
    const dirs = fs.readdirSync(KNOWLEDGE_DIR).filter(f => fs.statSync(path.join(KNOWLEDGE_DIR, f)).isDirectory());
    dirs.forEach(d => {
      const metaPath = path.join(KNOWLEDGE_DIR, d, 'metadata.json');
      if (fs.existsSync(metaPath)) {
        const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
        results[`KI: ${d}`] = meta.para_version || meta.kernel_version || 'UNKNOWN';
      }
    });
  }

  return results;
}

// 6. Mutate / Synchronize all locations
function applyVersionSync(newVersion, isDryRun) {
  console.log(`\n🚀 ${isDryRun ? '[DRY-RUN] Simulating' : 'Applying'} Version Sync ➔ v${newVersion}...\n`);

  // 1. repo/VERSION
  const vPath = path.join(REPO_ROOT, 'VERSION');
  if (!isDryRun) fs.writeFileSync(vPath, `${newVersion}\n`);
  console.log(`  [1] repo/VERSION ➔ ${newVersion}`);

  // 2. repo/VERSIONS.yml
  const vyPath = path.join(REPO_ROOT, 'VERSIONS.yml');
  if (fs.existsSync(vyPath)) {
    let content = fs.readFileSync(vyPath, 'utf8');
    content = content.replace(/^workspace:\s*["'].*?["']/m, `workspace: "${newVersion}"`);
    if (!isDryRun) fs.writeFileSync(vyPath, content);
    console.log(`  [2] repo/VERSIONS.yml ➔ workspace: "${newVersion}"`);
  }

  // 3. repo/cli/para
  const cliPath = path.join(REPO_ROOT, 'cli/para');
  if (fs.existsSync(cliPath)) {
    let content = fs.readFileSync(cliPath, 'utf8');
    content = content.replace(/^# Version:\s*.*$/m, `# Version: ${newVersion}`);
    if (!isDryRun) fs.writeFileSync(cliPath, content);
    console.log(`  [3] repo/cli/para ➔ # Version: ${newVersion}`);
  }

  // 4. project.md
  if (fs.existsSync(PROJECT_MD)) {
    let content = fs.readFileSync(PROJECT_MD, 'utf8');
    content = content.replace(/^version:\s*["'].*?["']/m, `version: "${newVersion}"`);
    if (!isDryRun) fs.writeFileSync(PROJECT_MD, content);
    console.log(`  [4] Projects/para-workspace/project.md ➔ version: "${newVersion}"`);
  }

  // 5. repo/README.md
  const rmPath = path.join(REPO_ROOT, 'README.md');
  if (fs.existsSync(rmPath)) {
    let content = fs.readFileSync(rmPath, 'utf8');
    content = content.replace(/badge\/version-[\w.-]+-blue\.svg/g, `badge/version-${newVersion}-blue.svg`);
    content = content.replace(/_Version:\s*[\w.-]+_/g, `_Version: ${newVersion}_`);
    if (!isDryRun) fs.writeFileSync(rmPath, content);
    console.log(`  [5] repo/README.md (badge & footer) ➔ ${newVersion}`);
  }

  // 6. repo/docs/locales/*.md
  if (fs.existsSync(LOCALES_DIR)) {
    const locales = fs.readdirSync(LOCALES_DIR).filter(f => f.endsWith('.md'));
    locales.forEach(loc => {
      const locPath = path.join(LOCALES_DIR, loc);
      let content = fs.readFileSync(locPath, 'utf8');
      content = content.replace(/badge\/version-[\w.-]+-blue\.svg/g, `badge/version-${newVersion}-blue.svg`);
      content = content.replace(/_(Version|Phiên bản|版本|Versión):\s*[\w.-]+_/gi, `_$1: ${newVersion}_`);
      if (!isDryRun) fs.writeFileSync(locPath, content);
      console.log(`  [6] docs/locales/${loc} (badge & footer) ➔ ${newVersion}`);
    });
  }

  // 7. repo/templates/knowledge/*/metadata.json
  if (fs.existsSync(KNOWLEDGE_DIR)) {
    const dirs = fs.readdirSync(KNOWLEDGE_DIR).filter(f => fs.statSync(path.join(KNOWLEDGE_DIR, f)).isDirectory());
    const today = new Date().toISOString().split('T')[0];
    dirs.forEach(d => {
      const metaPath = path.join(KNOWLEDGE_DIR, d, 'metadata.json');
      if (fs.existsSync(metaPath)) {
        const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
        meta.para_version = newVersion;
        meta.last_updated = today;
        if (meta.kernel_version) meta.kernel_version = newVersion;
        if (meta.kernel_min) meta.kernel_min = newVersion;
        if (!isDryRun) fs.writeFileSync(metaPath, JSON.stringify(meta, null, 2) + '\n');
        console.log(`  [7] templates/knowledge/${d}/metadata.json ➔ para_version: "${newVersion}"`);
      }
    });
  }
}

// === CLI Execution Controller ===
function main() {
  const args = process.argv.slice(2);
  const isCheckMode = args.includes('--check') || args.length === 0;
  const isDryRun = args.includes('--dry-run');
  const targetVersion = args.find(a => !a.startsWith('--'));

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('   PARA Guarded Version Sync & Quality Gatekeeper (M2/M1)   ');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  if (isCheckMode) {
    console.log('🔍 Auditing version consistency across all release locations...\n');
    const results = auditVersions();
    const versions = new Set(Object.values(results));
    let hasDrift = false;

    for (const [loc, ver] of Object.entries(results)) {
      const statusIcon = versions.size === 1 && !ver.includes('UNKNOWN') && !ver.includes('MISSING') ? '✅' : '⚠️';
      printf(`  %-45s %-12s %s\n`, loc, ver, statusIcon);
      if (statusIcon === '⚠️') hasDrift = true;
    }

    console.log('\n--- Governance Gates ---');
    const m1 = checkM1Catalogs();
    console.log(`  [Gate 1] M1 Catalog Double-Declaration : ${m1.pass ? 'PASS ✅' : 'FAIL ❌'}`);
    if (!m1.pass) m1.issues.forEach(i => console.log(`           - ${i}`));

    const kr7 = checkKR7References();
    console.log(`  [Gate 2] KR7 Ephemeral Ref Sanitation  : ${kr7.pass ? 'PASS ✅' : 'FAIL ❌'}`);
    if (!kr7.pass) kr7.issues.forEach(i => console.log(`           - ${i}`));

    if (hasDrift || !m1.pass || !kr7.pass) {
      console.log('\n❌ Result: DRIFT / GOVERNANCE FAILURE DETECTED.');
      process.exit(1);
    } else {
      console.log(`\n✅ Result: 100% IN SYNC across all locations (${Array.from(versions)[0]}).`);
      process.exit(0);
    }
  }

  // Apply or Dry-Run Mode
  if (!targetVersion || !isValidSemver(targetVersion)) {
    console.error(`❌ Error: Invalid or missing SemVer version '${targetVersion}'.`);
    console.error('Usage: node scripts/sync-version.js <new_version> [--dry-run]');
    process.exit(1);
  }

  console.log(`🛡️ Running Pre-Flight Quality Gates for v${targetVersion}...`);

  // Gate 1: Changelog
  const chkChangelog = checkChangelogEntry(targetVersion);
  if (!chkChangelog.pass) {
    console.error(`\n❌ [Gate 1 Blocked] ${chkChangelog.error}`);
    console.error(`   👉 Please add release notes to CHANGELOG.md under '## [${targetVersion}]' before bumping version.`);
    process.exit(1);
  }
  console.log('  ✅ [Gate 1] CHANGELOG.md entry verified.');

  // Gate 2: M1 Double Declaration
  const chkM1 = checkM1Catalogs();
  if (!chkM1.pass) {
    console.error('\n❌ [Gate 2 Blocked] Unregistered templates found (Rule M1 violation):');
    chkM1.issues.forEach(i => console.error(`   - ${i}`));
    console.error('   👉 Please register all staged templates in workflows/catalog.yml or skills/catalog.yml before bumping version.');
    process.exit(1);
  }
  console.log('  ✅ [Gate 2] M1 Catalog Double-Declaration verified.');

  // Gate 3: KR7 Reference Sanitation
  const chkKR7 = checkKR7References();
  if (!chkKR7.pass) {
    console.error('\n❌ [Gate 3 Blocked] Ephemeral references detected in System KIs (Rule KR7 violation):');
    chkKR7.issues.forEach(i => console.error(`   - ${i}`));
    process.exit(1);
  }
  console.log('  ✅ [Gate 3] KR7 Ephemeral References sanitized.');

  // All gates passed -> apply sync
  applyVersionSync(targetVersion, isDryRun);

  if (!isDryRun) {
    console.log('\n🔍 Running Post-Sync Verification...');
    const audit = auditVersions();
    const verValues = new Set(Object.values(audit));
    if (verValues.size === 1 && verValues.has(targetVersion)) {
      console.log(`\n🎉 Success! All release locations successfully updated to v${targetVersion} with 100% integrity.`);
      process.exit(0);
    } else {
      console.error('\n❌ Post-sync verification failed! Some files did not update properly.');
      process.exit(1);
    }
  } else {
    console.log('\n[DRY-RUN Complete] No files were modified on disk.');
  }
}

function printf(format, ...args) {
  let i = 0;
  console.log(format.replace(/%(-?\d+)?s/g, (match, width) => {
    let val = String(args[i++] || '');
    if (width) {
      const len = Math.abs(parseInt(width, 10));
      const pad = ' '.repeat(Math.max(0, len - val.length));
      return width.startsWith('-') ? val + pad : pad + val;
    }
    return val;
  }).trimEnd());
}

main();
