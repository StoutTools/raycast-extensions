#!/bin/bash

# Pre-push checks for Shodan Raycast Extension
# Mimics the GitHub Actions workflows to catch issues before pushing

set -e

echo "🔍 Running pre-push checks for Shodan extension..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Not in extension directory. Please run from extensions/shodan/"
    exit 1
fi

# 1. Extension Build Check (mimics extensions_build_publish.yml)
print_status "1. Running extension build check..."
if npm run build; then
    print_success "Extension builds successfully"
else
    print_error "Extension build failed"
    exit 1
fi

# 2. Linting Check
print_status "2. Running linting check..."
if npm run lint; then
    print_success "Linting passed"
else
    print_error "Linting failed. Run 'npm run fix-lint' to auto-fix issues"
    exit 1
fi

# 3. Changelog Check (mimics changelog_enforcer.yml)
print_status "3. Checking changelog..."
if [ -f "CHANGELOG.md" ]; then
    # Check if changelog has recent entries or unreleased section
    if grep -q "## \[Unreleased\]" CHANGELOG.md || grep -q "## \[.*\]" CHANGELOG.md; then
        print_success "Changelog is present and has version entries"
    else
        print_warning "Changelog may need updating. Consider adding recent changes."
    fi
else
    print_error "CHANGELOG.md is missing"
    exit 1
fi

# 4. Package.json Validation
print_status "4. Validating package.json..."
if [ -f "package.json" ]; then
    # Check for required fields using grep (more portable than jq)
    if grep -q '"name"' package.json && \
       grep -q '"version"' package.json && \
       grep -q '"commands"' package.json; then
        print_success "package.json structure is valid"
    else
        print_error "package.json is missing required fields"
        exit 1
    fi
else
    print_error "package.json is missing"
    exit 1
fi

# 5. NPM Check (mimics npm_check.yml)
print_status "5. Running npm dependency check..."
if command -v npm-check >/dev/null 2>&1; then
    if npm-check --skip-unused; then
        print_success "NPM dependencies are up to date"
    else
        print_warning "NPM dependencies may need updates"
    fi
else
    print_warning "npm-check not installed. Install with: npm install -g npm-check"
fi

# 6. TypeScript Check
print_status "6. Running TypeScript check..."
if npx tsc --noEmit; then
    print_success "TypeScript compilation successful"
else
    print_error "TypeScript compilation failed"
    exit 1
fi

# 7. Security Check (basic)
print_status "7. Running basic security check..."
if command -v npm-audit >/dev/null 2>&1; then
    if npm audit --audit-level=moderate; then
        print_success "No security vulnerabilities found"
    else
        print_warning "Security vulnerabilities detected. Run 'npm audit fix' to resolve"
    fi
else
    print_warning "npm audit not available"
fi

# 8. File Structure Check
print_status "8. Checking file structure..."
required_files=("package.json" "README.md" "src" "extension-icon.png")
for file in "${required_files[@]}"; do
    if [ -e "$file" ]; then
        print_success "✓ $file exists"
    else
        print_error "✗ $file is missing"
        exit 1
    fi
done

# 9. Metadata Check
print_status "9. Checking metadata..."
if [ -d "metadata" ]; then
    metadata_files=$(find metadata -name "*.png" | wc -l)
    if [ "$metadata_files" -gt 0 ]; then
        print_success "Metadata screenshots found ($metadata_files files)"
    else
        print_warning "No metadata screenshots found"
    fi
else
    print_warning "Metadata directory not found"
fi

print_success "🎉 All pre-push checks passed! Ready to push."
echo ""
echo "Next steps:"
echo "1. Commit your changes: git add . && git commit -m 'Your commit message'"
echo "2. Push to your fork: git push origin update-shodan-pr-22023"
echo "3. Update your PR on GitHub"
