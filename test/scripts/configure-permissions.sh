#!/bin/bash

# Script to configure repository permissions and tokens
# Sets up necessary secrets and permissions for testing

set -e

echo "🔐 Configuring repository permissions..."

# Check for required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is not set"
    exit 1
fi

if [ -z "$PROJECT_TOKEN" ]; then
    echo "⚠️ Warning: PROJECT_TOKEN environment variable is not set"
    echo "  PROJECT_TOKEN is required for project operations"
    echo "  Please set it and run this script again"
fi

# Configuration
ORG="atriumn"
REPO="atriumn-github-actions-test-repo"

echo "📋 Repository: $ORG/$REPO"
echo ""

# Function to add or update a secret
add_secret() {
    local SECRET_NAME=$1
    local SECRET_VALUE=$2
    
    echo "Adding secret: $SECRET_NAME"
    
    # Create or update the secret
    gh secret set "$SECRET_NAME" \
        --repo "$ORG/$REPO" \
        --body "$SECRET_VALUE" \
        2>/dev/null || echo "  Secret might already exist, updating..."
}

# Add secrets
echo "🔑 Adding repository secrets..."

if [ -n "$PROJECT_TOKEN" ]; then
    add_secret "PROJECT_TOKEN" "$PROJECT_TOKEN"
    echo "✅ PROJECT_TOKEN added"
else
    echo "⚠️ Skipping PROJECT_TOKEN (not provided)"
fi

# Add GitHub token as a secret (for workflow use)
if [ -n "$GITHUB_TOKEN" ]; then
    add_secret "WORKFLOW_TOKEN" "$GITHUB_TOKEN"
    echo "✅ WORKFLOW_TOKEN added"
fi

# Configure repository settings
echo ""
echo "⚙️ Configuring repository settings..."

# Enable features via API
echo "Enabling repository features..."

# Update repository settings
UPDATE_REPO=$(cat <<EOF
{
  "has_issues": true,
  "has_projects": true,
  "has_wiki": false,
  "has_downloads": false
}
EOF
)

gh api "repos/$ORG/$REPO" \
    --method PATCH \
    --input - <<< "$UPDATE_REPO" \
    > /dev/null

echo "✅ Repository features configured"

# Check current permissions
echo ""
echo "👥 Checking current permissions..."

# Get current user
CURRENT_USER=$(gh api user --jq '.login')
echo "Current user: $CURRENT_USER"

# Check user permissions on the repo
USER_PERMS=$(gh api "repos/$ORG/$REPO/collaborators/$CURRENT_USER/permission" --jq '.permission' 2>/dev/null || echo "none")
echo "Your permission level: $USER_PERMS"

if [ "$USER_PERMS" != "admin" ] && [ "$USER_PERMS" != "write" ]; then
    echo "⚠️ Warning: You don't have write access to the repository"
    echo "  Some operations may fail"
fi

# Token validation
echo ""
echo "🔍 Validating token permissions..."

# Check token scopes
TOKEN_SCOPES=$(gh api user -i | grep "x-oauth-scopes:" | cut -d' ' -f2-)
echo "Token scopes: $TOKEN_SCOPES"

# Required scopes
REQUIRED_SCOPES=("repo" "project")
MISSING_SCOPES=()

for scope in "${REQUIRED_SCOPES[@]}"; do
    if [[ ! "$TOKEN_SCOPES" =~ $scope ]]; then
        MISSING_SCOPES+=("$scope")
    fi
done

if [ ${#MISSING_SCOPES[@]} -eq 0 ]; then
    echo "✅ All required token scopes are present"
else
    echo "⚠️ Missing token scopes: ${MISSING_SCOPES[*]}"
    echo "  Some operations may not work correctly"
fi

# Summary
echo ""
echo "📊 Configuration Summary"
echo "======================="
echo "Repository: $ORG/$REPO"
echo "User: $CURRENT_USER"
echo "Permission Level: $USER_PERMS"
echo ""
echo "Secrets configured:"
[ -n "$PROJECT_TOKEN" ] && echo "  ✅ PROJECT_TOKEN"
echo "  ✅ WORKFLOW_TOKEN"
echo ""
echo "Repository features:"
echo "  ✅ Issues enabled"
echo "  ✅ Projects enabled"
echo ""

if [ ${#MISSING_SCOPES[@]} -eq 0 ] && [ "$USER_PERMS" = "admin" ] || [ "$USER_PERMS" = "write" ]; then
    echo "✅ Permissions configured successfully!"
else
    echo "⚠️ Some permissions may need attention"
    echo "  Ensure your token has the required scopes"
fi

echo ""
echo "Next steps:"
echo "1. Run ./test/scripts/verify-test-setup.sh to verify configuration"
echo "2. Create test workflows that use the configured secrets"
echo "3. Test the composite actions with the configured permissions"