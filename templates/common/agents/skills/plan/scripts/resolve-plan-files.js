import fs from 'node:fs';
import path from 'node:path';

function findProjectFile(dir) {
  const projectPath = path.join(dir, 'project.md');
  if (fs.existsSync(projectPath)) return projectPath;
  const parent = path.dirname(dir);
  if (parent === dir) return null;
  return findProjectFile(parent);
}

const projectFile = findProjectFile(process.cwd());
if (!projectFile) {
  process.exit(0);
}

try {
  const projectContent = fs.readFileSync(projectFile, 'utf8');
  const match = projectContent.match(/active_plan:\s*["']?(.+?)["']?\s*$/m);
  if (!match) {
    process.exit(0);
  }

  const projectDir = path.dirname(projectFile);
  const planPath = path.resolve(projectDir, match[1]);
  if (!fs.existsSync(planPath)) {
    process.exit(0);
  }

  const planContent = fs.readFileSync(planPath, 'utf8');
  const pathRegex = /(?:^|\s|`|file:\/\/|\[)(repo\/[a-zA-Z0-9_\-\.\/]+|src\/[a-zA-Z0-9_\-\.\/]+|bin\/[a-zA-Z0-9_\-\.\/]+|test\/[a-zA-Z0-9_\-\.\/]+|packages\/[a-zA-Z0-9_\-\.\/]+)/g;
  const files = new Set();
  let m;
  while ((m = pathRegex.exec(planContent)) !== null) {
    let matchedPath = m[1];
    matchedPath = matchedPath.replace(/[`\]\)\s]/g, '');
    
    let absPath = '';
    if (matchedPath.startsWith('repo/')) {
      absPath = path.resolve(projectDir, matchedPath);
    } else {
      absPath = path.resolve(projectDir, 'repo', matchedPath);
    }

    if (fs.existsSync(absPath) && fs.statSync(absPath).isFile()) {
      if (absPath.endsWith('.md') || absPath.endsWith('package-lock.json')) {
        continue;
      }
      files.add(absPath);
    }
  }

  console.log(Array.from(files).join('\n'));
} catch (err) {
  console.error(err);
  process.exit(1);
}
