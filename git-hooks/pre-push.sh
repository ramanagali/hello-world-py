#!/bin/sh

# Exit on any command failure
set -e

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo "${GREEN}Running pre-push checks...${NC}"

# 1. Verify commit messages
echo "${GREEN}Verifying commit messages...${NC}"
INVALID_COMMITS=$(git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD --pretty=format:%s | grep -vE "^SHK-\d{5}")
if [ -n "$INVALID_COMMITS" ]; then
  echo "${RED}Invalid commit messages detected:${NC}"
  echo "$INVALID_COMMITS"
  echo "${RED}Each commit message must start with 'SHK-' followed by a 5-digit number.${NC}"
  exit 1
fi

# 2. Run Python linter (flake8)
echo "${GREEN}Running flake8 for code style compliance...${NC}"
flake8
if [ $? -ne 0 ]; then
  echo "${RED}Code style check failed. Push aborted.${NC}"
  exit 1
fi

# 3. Run Python tests
echo "${GREEN}Running tests...${NC}"
pytest
if [ $? -ne 0 ]; then
  echo "${RED}Tests failed. Push aborted.${NC}"
  exit 1
fi

# 4. Enforce code coverage threshold
COVERAGE_THRESHOLD=80
echo "${GREEN}Checking code coverage...${NC}"
coverage run -m pytest
coverage report --fail-under=$COVERAGE_THRESHOLD
if [ $? -ne 0 ]; then
  echo "${RED}Code coverage below ${COVERAGE_THRESHOLD}%. Push aborted.${NC}"
