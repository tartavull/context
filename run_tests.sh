#!/bin/bash

# Context macOS App - Test Runner Script
# This script runs all tests for the Context macOS application

set -e  # Exit on any error

echo "🧪 Context macOS App - Test Runner"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
WORKSPACE_PATH="context.xcworkspace"
PROJECT_PATH="context.xcodeproj"
SCHEME="context"

# Check if workspace exists
if [ ! -d "$WORKSPACE_PATH" ]; then
    echo -e "${RED}❌ Error: Workspace not found at $WORKSPACE_PATH${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Using workspace: $WORKSPACE_PATH${NC}"
echo -e "${BLUE}🎯 Using scheme: $SCHEME${NC}"
echo ""

# Function to run tests
run_tests() {
    local test_type=$1
    local test_target=$2
    
    echo -e "${YELLOW}🔄 Running $test_type tests...${NC}"
    
    if [ "$test_target" = "all" ]; then
        xcodebuild test \
            -workspace "$WORKSPACE_PATH" \
            -scheme "$SCHEME" \
            -destination 'platform=macOS' \
            -quiet
    else
        xcodebuild test \
            -workspace "$WORKSPACE_PATH" \
            -scheme "$SCHEME" \
            -destination 'platform=macOS' \
            -only-testing:"$test_target" \
            -quiet
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $test_type tests passed!${NC}"
    else
        echo -e "${RED}❌ $test_type tests failed!${NC}"
        return 1
    fi
    echo ""
}

# Function to show test summary
show_test_info() {
    echo -e "${BLUE}📊 Test Information${NC}"
    echo "==================="
    echo ""
    echo "Unit Tests (contextTests):"
    echo "  • contextTests.swift - Model and data structure tests"
    echo "  • AppStateManagerTests.swift - State management tests"
    echo ""
    echo "UI Tests (contextUITests):"
    echo "  • contextUITests.swift - General UI interaction tests"
    echo "  • ProjectsViewUITests.swift - Projects panel specific tests"
    echo ""
}

# Parse command line arguments
case "${1:-all}" in
    "unit")
        echo -e "${BLUE}🎯 Running only unit tests${NC}"
        echo ""
        run_tests "Unit" "contextTests"
        ;;
    "ui")
        echo -e "${BLUE}🎯 Running only UI tests${NC}"
        echo ""
        run_tests "UI" "contextUITests"
        ;;
    "models")
        echo -e "${BLUE}🎯 Running only model tests${NC}"
        echo ""
        run_tests "Model" "contextTests/contextTests"
        ;;
    "state")
        echo -e "${BLUE}🎯 Running only state management tests${NC}"
        echo ""
        run_tests "State Management" "contextTests/AppStateManagerTests"
        ;;
    "projects")
        echo -e "${BLUE}🎯 Running only projects UI tests${NC}"
        echo ""
        run_tests "Projects UI" "contextUITests/ProjectsViewUITests"
        ;;
    "info")
        show_test_info
        exit 0
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  all       Run all tests (default)"
        echo "  unit      Run only unit tests"
        echo "  ui        Run only UI tests"
        echo "  models    Run only model tests"
        echo "  state     Run only state management tests"
        echo "  projects  Run only projects UI tests"
        echo "  info      Show test information"
        echo "  help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0              # Run all tests"
        echo "  $0 unit         # Run only unit tests"
        echo "  $0 ui           # Run only UI tests"
        echo "  $0 info         # Show test information"
        exit 0
        ;;
    "all"|"")
        echo -e "${BLUE}🎯 Running all tests${NC}"
        echo ""
        
        # Run unit tests first
        run_tests "Unit" "contextTests"
        
        # Then run UI tests
        run_tests "UI" "contextUITests"
        
        echo -e "${GREEN}🎉 All tests completed successfully!${NC}"
        ;;
    *)
        echo -e "${RED}❌ Unknown option: $1${NC}"
        echo "Use '$0 help' for usage information."
        exit 1
        ;;
esac

echo -e "${GREEN}✨ Test run completed!${NC}" 