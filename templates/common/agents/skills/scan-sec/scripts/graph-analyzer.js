#!/usr/bin/env node
/**
 * graph-analyzer.js
 * Analyzes the blast radius of a vulnerable file using para-graph database
 */

const fs = require('fs');
const path = require('path');

// Helper to print usage
function printUsage() {
  console.log('Usage: node graph-analyzer.js --project <project_path> --file <relative_file_path>');
  process.exit(1);
}

// Parse arguments
let projectPath = '';
let targetFile = '';

const args = process.argv.slice(2);
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--project' && args[i + 1]) {
    projectPath = args[i + 1];
    i++;
  } else if (args[i] === '--file' && args[i + 1]) {
    targetFile = args[i + 1];
    i++;
  }
}

if (!projectPath || !targetFile) {
  printUsage();
}

// Normalize target file path (strip repo prefix if present)
// e.g., Projects/pageel-crm/repo/src/pages/api/webhook/sepay.ts -> src/pages/api/webhook/sepay.ts
let normalizedTarget = targetFile.replace(/\\/g, '/');
if (normalizedTarget.includes('/repo/')) {
  normalizedTarget = normalizedTarget.substring(normalizedTarget.indexOf('/repo/') + 6);
} else if (normalizedTarget.startsWith('repo/')) {
  normalizedTarget = normalizedTarget.substring(5);
}

const graphDir = path.resolve(projectPath, '.beads/graph');
const entitiesPath = path.join(graphDir, 'entities.jsonl');
const relationsPath = path.join(graphDir, 'relations.jsonl');

// Fallback if graph data does not exist
if (!fs.existsSync(entitiesPath) || !fs.existsSync(relationsPath)) {
  console.log(JSON.stringify({
    error: 'Graph data not found. Please run /para-graph build first.',
    graphAvailable: false
  }, null, 2));
  process.exit(0);
}

// Load Nodes (Entities)
const nodes = new Map(); // id -> node
try {
  const entitiesContent = fs.readFileSync(entitiesPath, 'utf8');
  entitiesContent.split('\n').forEach(line => {
    if (!line.trim()) return;
    try {
      const node = JSON.parse(line);
      nodes.set(node.id, node);
    } catch (e) {
      // Ignore parse errors on partial lines
    }
  });
} catch (err) {
  console.error('Error reading entities:', err.message);
  process.exit(1);
}

// Load Edges (Relations)
const edges = [];
try {
  const relationsContent = fs.readFileSync(relationsPath, 'utf8');
  relationsContent.split('\n').forEach(line => {
    if (!line.trim()) return;
    try {
      const relation = JSON.parse(line);
      edges.push(relation);
    } catch (e) {
      // Ignore parse errors
    }
  });
} catch (err) {
  console.error('Error reading relations:', err.message);
  process.exit(1);
}

// 1. Locate all start nodes belonging to the target file
const startNodeIds = [];
for (const [id, node] of nodes.entries()) {
  if (node.filePath && node.filePath.replace(/\\/g, '/') === normalizedTarget) {
    startNodeIds.push(id);
  }
}

if (startNodeIds.length === 0) {
  // Try fallback substring match on id
  for (const [id, node] of nodes.entries()) {
    if (id.includes(normalizedTarget)) {
      startNodeIds.push(id);
    }
  }
}

if (startNodeIds.length === 0) {
  // If not found in graph, return clean fallback
  console.log(JSON.stringify({
    file: normalizedTarget,
    graphAvailable: true,
    targetFound: false,
    callerCount: 0,
    severityBoost: "NO_BOOST",
    mermaid: "",
    remediationPoints: []
  }, null, 2));
  process.exit(0);
}

// 2. Trace upstream callers (recursively up to depth 3)
const visited = new Set();
const upstreamEdges = [];
const callerNodes = new Set();

function traceUpstream(nodeId, depth = 0) {
  if (depth >= 3 || visited.has(nodeId)) return;
  visited.add(nodeId);

  // Find all edges where targetId is the current nodeId (someone calls/imports us)
  edges.forEach(edge => {
    if (edge.targetId === nodeId) {
      const srcNode = nodes.get(edge.sourceId);
      const tgtNode = nodes.get(edge.targetId);
      // Skip self-references within the same file to prevent noise
      if (srcNode && tgtNode && srcNode.filePath === tgtNode.filePath) {
        return;
      }
      upstreamEdges.push(edge);
      callerNodes.add(edge.sourceId);
      traceUpstream(edge.sourceId, depth + 1);
    }
  });
}

startNodeIds.forEach(id => traceUpstream(id));

// 3. Filter callers that are files or main entrypoints
const uniqueCallers = Array.from(callerNodes).map(id => nodes.get(id) || { id, type: 'unknown' });
const callerFiles = new Set();
uniqueCallers.forEach(c => {
  if (c.filePath) {
    callerFiles.add(c.filePath);
  }
});

// Calculate severity boost: if node has callers, boost is recommended
const callerCount = callerFiles.size;
let severityBoost = "NO_BOOST";
if (callerCount > 5) {
  severityBoost = "CRITICAL";
} else if (callerCount > 0) {
  severityBoost = "HIGH";
}

// 4. Generate Mermaid representation of the upstream sub-graph
let mermaid = '';
if (upstreamEdges.length > 0) {
  mermaid = 'graph TD\n';
  // Deduplicate edges to avoid rendering redundant lines
  const renderedEdges = new Set();
  upstreamEdges.forEach(edge => {
    const srcLabel = nodes.get(edge.sourceId)?.name || edge.sourceId;
    const tgtLabel = nodes.get(edge.targetId)?.name || edge.targetId;
    const edgeKey = `"${srcLabel}" --> "${tgtLabel}"`;
    if (!renderedEdges.has(edgeKey)) {
      renderedEdges.add(edgeKey);
      mermaid += `  ${edgeKey}\n`;
    }
  });
}

// 5. Suggest Remediation / Mitigation Points
// These are common callers, middleware, or endpoints in the upstream call tree
const remediationPoints = new Set();
// Always include the file itself as the primary remediation point
remediationPoints.add(normalizedTarget);

uniqueCallers.forEach(caller => {
  const name = caller.id.toLowerCase();
  // If it's a middleware or authentication file, it is an excellent remediation point
  if (name.includes('middleware') || name.includes('auth') || name.includes('session')) {
    if (caller.filePath) remediationPoints.add(caller.filePath);
  }
  // If it's an API route or page gateway
  if (name.includes('pages/api/') || name.includes('/api/')) {
    if (caller.filePath) remediationPoints.add(caller.filePath);
  }
});

console.log(JSON.stringify({
  file: normalizedTarget,
  graphAvailable: true,
  targetFound: true,
  callerCount: callerCount,
  severityBoost: severityBoost,
  mermaid: mermaid.trim(),
  remediationPoints: Array.from(remediationPoints)
}, null, 2));
