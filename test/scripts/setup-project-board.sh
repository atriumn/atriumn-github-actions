#!/bin/bash

# Script to create and configure a project board for testing
# This creates a standard project with Todo, In Progress, Done columns

set -e

echo "🏗️ Setting up project board..."

# Check for required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is not set"
    exit 1
fi

# Configuration
ORG="atriumn"
REPO="atriumn-github-actions-test-repo"
PROJECT_NAME="atriumn-github-actions-test-repo project"

# Create project using GraphQL API
echo "📋 Creating project: $PROJECT_NAME"

# GraphQL mutation to create project
CREATE_PROJECT_MUTATION=$(cat <<EOF
mutation {
  createProjectV2(input: {
    ownerId: "$ORG"
    title: "$PROJECT_NAME"
    repositoryId: "$REPO"
  }) {
    projectV2 {
      id
      title
    }
  }
}
EOF
)

# Execute GraphQL mutation
RESPONSE=$(gh api graphql -f query="$CREATE_PROJECT_MUTATION" 2>/dev/null || true)

if [ -n "$RESPONSE" ]; then
    PROJECT_ID=$(echo "$RESPONSE" | jq -r '.data.createProjectV2.projectV2.id')
    
    if [ "$PROJECT_ID" != "null" ]; then
        echo "✅ Project created with ID: $PROJECT_ID"
    else
        echo "⚠️ Project might already exist, continuing..."
    fi
else
    echo "⚠️ Could not create project (might already exist)"
fi

# Get project ID if it already exists
echo "🔍 Finding project ID..."
PROJECTS=$(gh api "orgs/$ORG/projects" --jq '.[] | select(.name == "'"$PROJECT_NAME"'") | .id')

if [ -z "$PROJECTS" ]; then
    # Try using GraphQL to find the project
    FIND_PROJECT_QUERY=$(cat <<EOF
{
  organization(login: "$ORG") {
    projectsV2(first: 50, query: "$PROJECT_NAME") {
      nodes {
        id
        title
      }
    }
  }
}
EOF
    )
    
    PROJECT_DATA=$(gh api graphql -f query="$FIND_PROJECT_QUERY")
    PROJECT_ID=$(echo "$PROJECT_DATA" | jq -r ".data.organization.projectsV2.nodes[] | select(.title == \"$PROJECT_NAME\") | .id")
    
    if [ -z "$PROJECT_ID" ]; then
        echo "❌ Error: Could not find or create project"
        exit 1
    fi
fi

# Configure project fields
echo "⚙️ Configuring project fields..."

# Add Status field with options
ADD_STATUS_FIELD_MUTATION=$(cat <<EOF
mutation {
  createProjectV2Field(input: {
    projectId: "$PROJECT_ID"
    name: "Status"
    dataType: SINGLE_SELECT
  }) {
    field {
      id
    }
  }
}
EOF
)

FIELD_RESPONSE=$(gh api graphql -f query="$ADD_STATUS_FIELD_MUTATION" 2>/dev/null || true)

# Add options to the Status field
if [ -n "$FIELD_RESPONSE" ]; then
    FIELD_ID=$(echo "$FIELD_RESPONSE" | jq -r '.data.createProjectV2Field.field.id')
    
    # Add status options
    for STATUS in "Todo" "In Progress" "Done" "Waiting for Review"; do
        echo "Adding status option: $STATUS"
        
        ADD_OPTION_MUTATION=$(cat <<EOF
mutation {
  createProjectV2FieldOption(input: {
    fieldId: "$FIELD_ID"
    name: "$STATUS"
  }) {
    option {
      id
      name
    }
  }
}
EOF
        )
        
        gh api graphql -f query="$ADD_OPTION_MUTATION" 2>/dev/null || echo "  Option might already exist"
    done
fi

echo "✅ Project board setup complete!"
echo ""
echo "Project Information:"
echo "- Organization: $ORG"
echo "- Repository: $REPO"
echo "- Project Name: $PROJECT_NAME"
echo ""
echo "Next steps:"
echo "1. Visit the project board to verify configuration"
echo "2. Add issues to the project using the GitHub UI or API"
echo "3. Test status updates using the composite actions"