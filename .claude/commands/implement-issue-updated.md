Find and implement gh issue #$ARGUMENTS. Follow these steps:

# STEP 1: PREPARATION [REQUIRED_STEP] [CRITICAL=true]
# -----------------------------------
# !!!! ATTENTION !!!! 
# !!!! YOU MUST EXECUTE THESE COMMANDS FIRST !!!!
# !!!! DO NOT SKIP THIS STEP OR YOU WILL WASTE TOKENS !!!!

# Start from a clean state by checking out main branch
[EXECUTE_COMMAND]
set -e  # Exit on any error
git checkout main
[VERIFY_OUTPUT]

# Verify we are actually on main branch
[EXECUTE_COMMAND]
MAIN_CURRENT=$(git rev-parse --abbrev-ref HEAD)
if [ "$MAIN_CURRENT" != "main" ]; then
  echo "❌ CRITICAL ERROR: Failed to checkout main branch!"
  echo "Current branch: $MAIN_CURRENT"
  exit 1
fi
echo "✅ Confirmed on main branch"
[VERIFY_OUTPUT]

# Pull latest changes
[EXECUTE_COMMAND]
git pull
[VERIFY_OUTPUT]

# Check the issue described in the ticket [REQUIRED_STEP]
[EXECUTE_COMMAND]
gh issue view $ARGUMENTS
[VERIFY_OUTPUT]

# STEP 2: UPDATE ISSUE STATUS TO IN PROGRESS [REQUIRED_STEP] [CRITICAL=true]
# --------------------------------------------------------
# Add a /start comment to the issue to update status to "In Progress"
[EXECUTE_COMMAND]
gh issue comment $ARGUMENTS --body "/start"
echo "✅ Added /start comment to update issue status to In Progress and create branch"
[VERIFY_OUTPUT]

# Wait for workflow to process and create branch
[EXECUTE_COMMAND]
echo "Waiting for GitHub Actions to process /start command..."
sleep 20
[VERIFY_OUTPUT]

# STEP 3: FETCH AND CHECKOUT BRANCH [REQUIRED_STEP] [CRITICAL=true]
# ------------------------------------
# Get the branch created by the /start workflow
[EXECUTE_COMMAND]
git fetch origin
[VERIFY_OUTPUT]

# Find the branch created for this issue
[EXECUTE_COMMAND]
BRANCH_NAME=$(git branch -r | grep -E "origin/issue-$ARGUMENTS-[0-9]+" | sed 's|origin/||' | tail -1)
if [ -z "$BRANCH_NAME" ]; then
  echo "❌ CRITICAL ERROR: Could not find branch created by /start workflow!"
  echo "Make sure the workflow completed successfully"
  exit 1
fi
echo "✅ Found branch created by workflow: $BRANCH_NAME"
[VERIFY_OUTPUT]

# Checkout the branch
[EXECUTE_COMMAND]
git checkout $BRANCH_NAME
[VERIFY_OUTPUT]

# Verify we are on the correct branch
[EXECUTE_COMMAND]
NEW_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$NEW_BRANCH" != issue-$ARGUMENTS-* ]]; then
  echo "❌ CRITICAL ERROR: Failed to checkout branch created by workflow!"
  echo "Current branch: $NEW_BRANCH"
  exit 1
fi
echo "✅ Confirmed on feature branch: $NEW_BRANCH"
[VERIFY_OUTPUT]

# STEP 4: IMPLEMENTATION [REQUIRED_STEP]
# -------------------------------------
# Locate relevant code and implement solution
# Add appropriate tests
# Ensure all acceptance criteria pass
# [IMPLEMENTATION_REQUIRED=true]

# STEP 5: TESTING [REQUIRED_STEP] [CRITICAL=true]
# ------------------------------
# CRITICAL: ALL TESTS MUST PASS - DO NOT PROCEED IF ANY TEST FAILS
# Run tests and verify they pass
[EXECUTE_COMMAND]
echo "Running tests..."
TEST_EXIT_CODE=0
TEST_RESULTS=$(make test-all 2>&1) || TEST_EXIT_CODE=$?
if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo "✅ All tests passed"
  echo "$TEST_RESULTS"
else
  echo "❌ CRITICAL ERROR: Tests failed with exit code $TEST_EXIT_CODE"
  echo "Test output:"
  echo "$TEST_RESULTS"
  echo ""
  echo "YOU MUST FIX ALL FAILING TESTS BEFORE PROCEEDING"
  echo "DO NOT CREATE A PR WITH FAILING TESTS"
  exit 1
fi
[VERIFY_OUTPUT]

# STEP 5.5: VERIFY ACCEPTANCE CRITERIA [REQUIRED_STEP] [CRITICAL=true]
# ------------------------------------------------------------------
# CRITICAL: Verify ALL acceptance criteria are met
# If ANY criterion cannot be verified, STOP and fix it
[EXECUTE_COMMAND]
echo "Verifying all acceptance criteria are met..."
echo "Review the issue requirements and ensure each one is implemented and tested"
echo "If any criterion is not met, YOU MUST implement it before proceeding"
[VERIFY_OUTPUT]

# STEP 6: SUBMIT PR [REQUIRED_STEP]
# --------------------------------
# ONLY proceed if ALL tests pass and acceptance criteria are met
# Stage and commit changes
[EXECUTE_COMMAND]
git add .
[VERIFY_OUTPUT]

[EXECUTE_COMMAND]
git commit -m "Fix issue #$ARGUMENTS: $(gh issue view $ARGUMENTS --json title -q .title)"
[VERIFY_OUTPUT]

[EXECUTE_COMMAND]
git push -u origin HEAD
[VERIFY_OUTPUT]

# Create PR with test results in description [CRITICAL=true]
[EXECUTE_COMMAND]
PR_BODY="Fixes issue #$ARGUMENTS

## Changes
- Implemented solution for $(gh issue view $ARGUMENTS --json title -q .title)
- Added tests

## Test Results
\`\`\`
$TEST_RESULTS
\`\`\`"

PR_URL=$(gh pr create --title "Fix issue #$ARGUMENTS: $(gh issue view $ARGUMENTS --json title -q .title)" --body "$PR_BODY" --base main)
echo "PR created at: $PR_URL"
[VERIFY_OUTPUT]

# Add comment with PR link to issue [CRITICAL=true]
[EXECUTE_COMMAND]
gh issue comment $ARGUMENTS --body "Implementation completed and PR submitted: $PR_URL"
[VERIFY_OUTPUT]

# Note: Issue status will be automatically updated to "Waiting for Review" by GitHub Actions

# STEP 7: VERIFICATION [REQUIRED_STEP]
# -----------------------------------
# Verify all required steps were completed
[EXECUTE_COMMAND]
echo "Implementation process completed successfully."
echo "  - Branch created and code implemented"
echo "  - Tests run and ALL TESTS PASSED"
echo "  - Changes committed and pushed"
echo "  - PR created at: $PR_URL"
echo "  - Comment added to issue with PR link"
echo "  - Issue status updates will be handled automatically by GitHub Actions"
[VERIFY_OUTPUT]