#!/bin/bash

set -e

echo "🚀 Git Push Script - Observability Suite"
echo "========================================"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "💡 Initialize git first with: git init"
    exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed or not in PATH"
    exit 1
fi

echo "📂 Current directory: $(pwd)"
echo ""

# Check git status
echo "🔍 Checking git status..."
git status --porcelain

echo ""
echo "📝 Git status summary:"
git status

echo ""
echo "➕ Adding all changes to staging..."
git add .

echo ""
echo "📋 Staged changes:"
git diff --cached --name-status

echo ""
echo "💬 Creating commit with message: 'Updated by Sandeep Kumar'"
git commit -m "Updated by Sandeep Kumar

🔧 Automated commit via gitpPush.sh
📅 Date: $(date '+%Y-%m-%d %H:%M:%S')
🖥️  From: $(whoami)@$(hostname)

📊 Recent changes may include:
- Grafana + Prometheus monitoring stack updates
- Dashboard configurations and JSON files
- Documentation improvements
- Script enhancements and bug fixes

🤖 Generated with automated git push script"

echo ""
echo "🌐 Pushing to remote repository..."

# Check if remote exists
if git remote | grep -q origin; then
    echo "🔗 Pushing to origin..."
    git push origin $(git branch --show-current)
    
    echo ""
    echo "✅ Successfully pushed to remote repository!"
    echo "🌟 Branch: $(git branch --show-current)"
    echo "📊 Remote URL: $(git remote get-url origin)"
else
    echo "⚠️  Warning: No 'origin' remote found"
    echo "💡 Add remote first with: git remote add origin <repository-url>"
    echo "📝 Commit created locally but not pushed to remote"
fi

echo ""
echo "📈 Recent commit history:"
git log --oneline -5

echo ""
echo "🎯 Git push completed!"
echo "📋 Summary:"
echo "   ✅ Changes staged and committed"
echo "   ✅ Commit message: 'Updated by Sandeep Kumar'"
echo "   ✅ Pushed to remote (if origin exists)"
echo ""
echo "🔍 To verify: git log --oneline -3"
