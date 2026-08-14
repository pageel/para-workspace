#!/usr/bin/env node
/**
 * PARA Plan Phase Task Completion Checker (v1.1.0)
 *
 * Universal script to verify all tasks in a plan phase are marked as completed [x]
 * before allowing git commit. Prevents agent hallucination about task completion.
 *
 * v1.1.0: Added --audit-checkpoints flag to also verify ⛔ CHECKPOINT items
 *         are marked [x], catching cases where Agent bypassed interactive pauses.
 *
 * Usage:
 *   node check-phase-tasks.js <plan-file> [phase-number] [--audit-checkpoints]
 *
 * Arguments:
 *   plan-file              Path to the plan markdown file
 *   phase-number           (Optional) Specific phase to check. If omitted, checks ALL phases.
 *   --audit-checkpoints    (Optional) Also check ⛔ CHECKPOINT items are [x]. Default: skip them.
 *
 * Exit codes:
 *   0 — All tasks completed ✅
 *   1 — Unchecked tasks remain ❌
 *   2 — Phase or plan not found ⚠️
 */

const fs = require('fs');
const path = require('path');

// ── Regex patterns for phase headings ──────────────────────────────────────
// Matches: ## Phase N, ### Phase N, ## ⏳ Phase N, ## 🟢 Phase N, etc.
// Also matches: ### Phase 1. [Name], ## Phase 0. [Name]
const PHASE_HEADING_RE = /^(#{2,3})\s+(?:[⏳🟢🔴🟡⚡📋]*\s*)?Phase\s+(\d+)/i;

// ── Regex for task items ───────────────────────────────────────────────────
// Matches: - [ ] task, - [x] task, [ ] task, [x] task (with optional leading spaces)
const TASK_UNCHECKED_RE = /^\s*[-*]?\s*\[\s\]\s+(.+)$/;
const TASK_CHECKED_RE   = /^\s*[-*]?\s*\[x\]\s+(.+)$/i;

// ── Lines to exclude from task counting ────────────────────────────────────
// CHECKPOINT items are gates, not implementation tasks (skipped by default)
// When --audit-checkpoints is active, they ARE counted as tasks
const CHECKPOINT_RE = /⛔\s*CHECKPOINT/i;
const CHECKPOINT_UNCHECKED_RE = /^\s*[-*]?\s*\[\s\]\s+(⛔\s*CHECKPOINT.+)$/;
const CHECKPOINT_CHECKED_RE   = /^\s*[-*]?\s*\[x\]\s+(⛔\s*CHECKPOINT.+)$/i;

// Section boundary: next phase heading, horizontal rule, or major heading
const SECTION_BOUNDARY_RE = /^(#{2,3})\s+(?:[⏳🟢🔴🟡⚡📋]*\s*)?Phase\s+\d+|^---\s*$|^##\s+(?!Phase)/i;

function parsePhases(content, auditCheckpoints = false) {
  const lines = content.split('\n');
  const phases = [];
  let currentPhase = null;
  let inCodeBlock = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Track code blocks to skip
    if (line.trim().startsWith('```')) {
      inCodeBlock = !inCodeBlock;
      continue;
    }
    if (inCodeBlock) continue;

    // Check for phase heading
    const phaseMatch = line.match(PHASE_HEADING_RE);
    if (phaseMatch) {
      // Save previous phase
      if (currentPhase) {
        phases.push(currentPhase);
      }
      currentPhase = {
        number: parseInt(phaseMatch[2], 10),
        heading: line.trim(),
        lineStart: i + 1,
        tasks: { checked: [], unchecked: [] },
        checkpoints: { checked: [], unchecked: [] }
      };
      continue;
    }

    // If we hit a section boundary while in a phase, close the phase
    if (currentPhase && i > currentPhase.lineStart) {
      // Check for ## headings that are NOT phase headings (e.g. ## Walkthrough, ## Completion)
      if (/^##\s+/.test(line) && !PHASE_HEADING_RE.test(line)) {
        phases.push(currentPhase);
        currentPhase = null;
        continue;
      }
      // Check for --- horizontal rule (but only if it's standalone, not in a table)
      if (/^---\s*$/.test(line)) {
        phases.push(currentPhase);
        currentPhase = null;
        continue;
      }
    }

    // Parse task items within a phase
    if (currentPhase) {
      // Skip HTML comments (harness guards)
      if (line.trim().startsWith('<!--')) continue;
      // Skip blockquote guards
      if (line.trim().startsWith('> ⛔')) continue;

      // Handle checkpoint items
      if (CHECKPOINT_RE.test(line)) {
        if (auditCheckpoints) {
          // When auditing, track checkpoint completion separately
          const cpUnchecked = line.match(CHECKPOINT_UNCHECKED_RE);
          if (cpUnchecked) {
            currentPhase.checkpoints.unchecked.push({
              line: i + 1,
              text: cpUnchecked[1].trim()
            });
          }
          const cpChecked = line.match(CHECKPOINT_CHECKED_RE);
          if (cpChecked) {
            currentPhase.checkpoints.checked.push({
              line: i + 1,
              text: cpChecked[1].trim()
            });
          }
        }
        continue; // Checkpoints are always separate from regular tasks
      }

      const uncheckedMatch = line.match(TASK_UNCHECKED_RE);
      if (uncheckedMatch) {
        currentPhase.tasks.unchecked.push({
          line: i + 1,
          text: uncheckedMatch[1].trim()
        });
        continue;
      }

      const checkedMatch = line.match(TASK_CHECKED_RE);
      if (checkedMatch) {
        currentPhase.tasks.checked.push({
          line: i + 1,
          text: checkedMatch[1].trim()
        });
      }
    }
  }

  // Don't forget the last phase
  if (currentPhase) {
    phases.push(currentPhase);
  }

  return phases;
}

function reportPhase(phase, auditCheckpoints = false) {
  const total = phase.tasks.checked.length + phase.tasks.unchecked.length;
  const done = phase.tasks.checked.length;
  const tasksPassed = phase.tasks.unchecked.length === 0;
  const status = tasksPassed ? '✅' : '❌';

  console.log(`  Phase ${phase.number}: ${done}/${total} tasks ${status}`);

  if (phase.tasks.unchecked.length > 0) {
    for (const task of phase.tasks.unchecked) {
      console.log(`    - [ ] ${task.text}  (line ${task.line})`);
    }
  }

  // Checkpoint audit (when --audit-checkpoints is active)
  let checkpointsPassed = true;
  if (auditCheckpoints) {
    const cpTotal = phase.checkpoints.checked.length + phase.checkpoints.unchecked.length;
    if (cpTotal > 0) {
      const cpDone = phase.checkpoints.checked.length;
      checkpointsPassed = phase.checkpoints.unchecked.length === 0;
      const cpStatus = checkpointsPassed ? '✅' : '⚠️';
      console.log(`  Phase ${phase.number}: ${cpDone}/${cpTotal} checkpoints ${cpStatus}`);
      if (!checkpointsPassed) {
        for (const cp of phase.checkpoints.unchecked) {
          console.log(`    ⚠️  [ ] ${cp.text}  (line ${cp.line})`);
        }
        console.log(`    → Agent may have bypassed interactive pause checkpoints!`);
      }
    }
  }

  return tasksPassed && checkpointsPassed;
}

function main() {
  const args = process.argv.slice(2);

  // Parse flags
  const auditCheckpoints = args.includes('--audit-checkpoints');
  const positionalArgs = args.filter(a => !a.startsWith('--'));

  if (positionalArgs.length < 1) {
    console.error('Usage: node check-phase-tasks.js <plan-file> [phase-number] [--audit-checkpoints]');
    console.error('  plan-file              Path to the plan markdown file');
    console.error('  phase-number           (Optional) Check a specific phase only');
    console.error('  --audit-checkpoints    (Optional) Also check ⛔ CHECKPOINT items are [x]');
    process.exit(2);
  }

  const planFile = positionalArgs[0];
  const targetPhase = positionalArgs[1] ? parseInt(positionalArgs[1], 10) : null;

  // Resolve path
  const filePath = path.resolve(planFile);
  if (!fs.existsSync(filePath)) {
    console.error(`⚠️  Plan file not found: ${filePath}`);
    process.exit(2);
  }

  const content = fs.readFileSync(filePath, 'utf-8');
  const phases = parsePhases(content, auditCheckpoints);

  if (phases.length === 0) {
    console.error('⚠️  No phases found in the plan file.');
    process.exit(2);
  }

  const header = auditCheckpoints
    ? `=== TASK + CHECKPOINT AUDIT: ${path.basename(filePath)} ===`
    : `=== TASK DONE CHECK: ${path.basename(filePath)} ===`;
  console.log(header);

  // Filter to target phase if specified
  let phasesToCheck = phases;
  if (targetPhase !== null) {
    phasesToCheck = phases.filter(p => p.number === targetPhase);
    if (phasesToCheck.length === 0) {
      console.error(`⚠️  Phase ${targetPhase} not found. Available phases: ${phases.map(p => p.number).join(', ')}`);
      process.exit(2);
    }
  }

  let allPassed = true;
  let totalUnchecked = 0;
  let totalChecked = 0;
  let totalCheckpointUnchecked = 0;

  for (const phase of phasesToCheck) {
    const passed = reportPhase(phase, auditCheckpoints);
    if (!passed) allPassed = false;
    totalUnchecked += phase.tasks.unchecked.length;
    totalChecked += phase.tasks.checked.length;
    if (auditCheckpoints) {
      totalCheckpointUnchecked += phase.checkpoints.unchecked.length;
    }
  }

  console.log('──────────────────────────');

  if (allPassed) {
    console.log(`RESULT: PASS (${totalChecked} tasks all completed${auditCheckpoints ? ', all checkpoints verified' : ''})`);
    console.log('EXIT CODE: 0');
    process.exit(0);
  } else {
    const parts = [];
    if (totalUnchecked > 0) parts.push(`${totalUnchecked} unchecked tasks`);
    if (totalCheckpointUnchecked > 0) parts.push(`${totalCheckpointUnchecked} unverified checkpoints`);
    console.log(`RESULT: FAIL (${parts.join(', ')} remaining)`);
    console.log('EXIT CODE: 1');
    process.exit(1);
  }
}

main();
