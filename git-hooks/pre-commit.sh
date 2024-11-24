#!/bin/sh

# Exit on any command failure
set -e

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo "${GREEN}Running pre-commit checks...${NC}"

# 1. Run Python linter (flake8)
echo "${GREEN}Running flake8...${NC}"
flake8
if [ $? -ne 0 ]; then
  echo "${RED}Linting failed. Please fix the errors.${NC}"
  exit 1
fi

# 2. Check for sensitive data using git-secrets
echo "${GREEN}Running git-secrets scan...${NC}"
git secrets --scan
if [ $? -ne 0 ]; then
  echo "${RED}Sensitive data detected. Commit aborted.${NC}"
  exit 1
fi

# 3. Format code using Black
echo "${GREEN}Running Black to format code...${NC}"
black .
if [ $? -ne 0 ]; then
  echo "${RED}Code formatting failed. Please recheck.${NC}"
  exit 1
fi

# 4. Run tests with pytest
echo "${GREEN}Running tests...${NC}"
pytest
if [ $? -ne 0 ]; then
  echo "${RED}Tests failed. Commit aborted.${NC}"
  exit 1
fi

echo "${GREEN}All checks passed. Proceeding with commit.${NC}"
exit 0
