import { execSync } from 'node:child_process';
import { cwd } from 'node:process';

import { type UserConfig } from '@commitlint/types';
import { RuleConfigSeverity } from '@commitlint/types';

interface TerragruntConfiguration {
  type: 'unit' | 'stack';
  path: string;
}

function findConfigurations(directory: string): string[] {
  const output = execSync('mise exec -- terragrunt find --json', {
    cwd: directory,
    encoding: 'utf-8',
  });

  return (JSON.parse(output) as TerragruntConfiguration[]).map(
    ({ path }) => path
  );
}

export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'header-max-length': [RuleConfigSeverity.Disabled, 'always', Infinity],
    'scope-enum': context => [
      RuleConfigSeverity.Error,
      'always',
      findConfigurations(context?.cwd ?? cwd()),
    ],
  },
} satisfies UserConfig;
