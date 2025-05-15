#!/bin/bash

# Test Data Generation Script for Atriumn GitHub Actions
# This script creates sample issues and test data for validation

set -e

echo "🚀 Starting test data generation..."

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
    echo "❌ Error: gh CLI is not authenticated. Run 'gh auth login' first"
    exit 1
fi

# Configuration
REPO="atriumn/atriumn-github-actions-test-repo"
PROJECT_NAME="atriumn-github-actions-test-repo project"

# Sample issue templates
declare -a ISSUES=(
    "Implement user authentication,enhancement,Create a secure user authentication system with JWT tokens"
    "Fix navigation menu bug,bug,The navigation menu doesn't close on mobile devices"
    "Add dark mode support,enhancement,Implement dark mode theme across the application"
    "Update documentation,documentation,Update README and API documentation for new features"
    "Optimize database queries,enhancement,Improve database query performance for large datasets"
    "Fix memory leak in service,bug,Memory leak detected in the background service"
    "Add unit tests for API,test,Create comprehensive unit tests for API endpoints"
    "Implement CI/CD pipeline,enhancement,Set up automated deployment pipeline"
    "Fix security vulnerability,security,Address security vulnerability in dependency"
    "Add feature flags system,enhancement,Implement feature toggle system for gradual rollouts"
)

echo "📝 Creating sample issues..."

for issue_data in "${ISSUES[@]}"; do
    IFS=',' read -r title label description <<< "$issue_data"
    
    echo "Creating issue: $title"
    
    gh issue create \
        --repo "$REPO" \
        --title "$title" \
        --body "$description" \
        --label "$label" \
        || echo "Failed to create issue: $title"
    
    sleep 1  # Rate limiting
done

echo "✅ Test data generation complete!"
echo ""
echo "Next steps:"
echo "1. Visit https://github.com/$REPO/issues to view created issues"
echo "2. Create project board if not already created"
echo "3. Run test workflows to validate composite actions"