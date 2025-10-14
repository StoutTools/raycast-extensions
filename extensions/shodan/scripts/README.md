# Pre-Push Checks Script

This script runs comprehensive checks before pushing changes to ensure your extension meets Raycast's quality standards.

## Usage

```bash
# Run all checks
npm run check-all

# Or run the script directly
./scripts/pre-push-checks.sh
```

## Checks Performed

1. **Extension Build** - Ensures the extension compiles successfully
2. **Linting** - Runs ESLint and Prettier checks
3. **Changelog** - Validates changelog presence and format
4. **Package.json** - Validates required fields
5. **NPM Dependencies** - Checks for outdated dependencies (if npm-check is installed)
6. **TypeScript** - Runs TypeScript compilation check
7. **Security** - Basic npm audit check (if available)
8. **File Structure** - Ensures all required files exist
9. **Metadata** - Checks for metadata screenshots

## GitHub Actions Equivalents

This script mimics the following GitHub Actions workflows:
- `extensions_build_publish.yml` - Extension build and validation
- `changelog_enforcer.yml` - Changelog validation
- `npm_check.yml` - NPM dependency checks

## Installation

The script is automatically available via npm scripts. For additional tools:

```bash
# Install npm-check for dependency analysis
npm install -g npm-check
```

## Exit Codes

- `0` - All checks passed
- `1` - One or more checks failed

## Integration

You can integrate this into your git workflow:

```bash
# Add to .git/hooks/pre-push
#!/bin/bash
cd extensions/shodan && npm run check-all
```

Or use it manually before pushing:

```bash
npm run check-all && git push origin your-branch
```
