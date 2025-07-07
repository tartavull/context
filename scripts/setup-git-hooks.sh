#!/bin/bash

# Setup script for SwiftLint Git hooks
# Run this script to install pre-commit and pre-push hooks that run SwiftLint

echo "🔧 Setting up SwiftLint Git hooks..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint is not installed. Please install it with: brew install swiftlint"
    exit 1
fi

# Create the hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# SwiftLint pre-commit hook
# This hook runs SwiftLint on the staged files before allowing a commit

echo "Running SwiftLint..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint is not installed. Please install it with: brew install swiftlint"
    exit 1
fi

# Get list of staged Swift files
STAGED_SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(swift)$')

if [ -z "$STAGED_SWIFT_FILES" ]; then
    echo "✅ No Swift files staged for commit"
    exit 0
fi

echo "Linting staged Swift files..."
echo "$STAGED_SWIFT_FILES"

# Run SwiftLint on staged files
# Note: SwiftLint doesn't have a direct way to lint only staged files,
# so we'll run it on the entire project but check for violations
SWIFTLINT_OUTPUT=$(swiftlint 2>&1)
SWIFTLINT_EXIT_CODE=$?

# Display the output
echo "$SWIFTLINT_OUTPUT"

if [ $SWIFTLINT_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ SwiftLint found violations. Please fix them before committing."
    echo "💡 Run 'swiftlint --fix' to auto-fix some issues"
    exit 1
fi

echo "✅ SwiftLint passed! Proceeding with commit..."
exit 0
EOF

# Create pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

# SwiftLint pre-push hook
# This hook runs SwiftLint before allowing a push to remote repository

echo "Running SwiftLint before push..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint is not installed. Please install it with: brew install swiftlint"
    exit 1
fi

# Run SwiftLint on the entire project
SWIFTLINT_OUTPUT=$(swiftlint 2>&1)
SWIFTLINT_EXIT_CODE=$?

# Display the output
echo "$SWIFTLINT_OUTPUT"

if [ $SWIFTLINT_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ SwiftLint found violations. Please fix them before pushing."
    echo "💡 Run 'swiftlint --fix' to auto-fix some issues"
    exit 1
fi

echo "✅ SwiftLint passed! Proceeding with push..."
exit 0
EOF

# Make hooks executable
chmod +x .git/hooks/pre-commit .git/hooks/pre-push

echo "✅ SwiftLint Git hooks have been installed successfully!"
echo ""
echo "Hooks installed:"
echo "  • pre-commit: Runs SwiftLint before each commit"
echo "  • pre-push: Runs SwiftLint before each push"
echo ""
echo "To bypass hooks (not recommended):"
echo "  • git commit --no-verify"
echo "  • git push --no-verify"
echo ""
echo "To auto-fix SwiftLint issues:"
echo "  • swiftlint --fix" 