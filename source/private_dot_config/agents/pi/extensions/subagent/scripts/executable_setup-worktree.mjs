#!/usr/bin/env node

import { copyFile, lstat, symlink } from 'node:fs/promises';
import path from 'node:path';

function readStdin() {
  return new Promise((resolve, reject) => {
    let input = '';

    process.stdin.setEncoding('utf8');
    process.stdin.on('data', chunk => {
      input += chunk;
    });
    process.stdin.on('end', () => resolve(input));
    process.stdin.on('error', reject);
  });
}

async function exists(target) {
  try {
    await lstat(target);
    return true;
  } catch (error) {
    if (error.code === 'ENOENT') {
      return false;
    }

    throw error;
  }
}

try {
  const input = JSON.parse(await readStdin());
  const repoRoot = path.resolve(input.repoRoot);
  const worktreePath = path.resolve(input.worktreePath);
  const syntheticPaths = [];

  if (repoRoot !== worktreePath) {
    const vendorSource = path.join(repoRoot, 'vendor');
    const vendorTarget = path.join(worktreePath, 'vendor');
    if (await exists(vendorSource) && ! await exists(vendorTarget)) {
      await symlink(vendorSource, vendorTarget, 'dir');
      syntheticPaths.push('vendor');
    }

    const envSource = path.join(repoRoot, '.env');
    const envTarget = path.join(worktreePath, '.env');
    if (await exists(envSource) && ! await exists(envTarget)) {
      await copyFile(envSource, envTarget);
      syntheticPaths.push('.env');
    }
  }

  process.stdout.write(`${JSON.stringify({ syntheticPaths })}\n`);
} catch (error) {
  process.stderr.write(`Failed to prepare worktree dependencies: ${error.message}\n`);
  process.exitCode = 1;
}
