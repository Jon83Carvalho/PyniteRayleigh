#!/bin/bash

# Test runner for PyNite Rayleigh Damping Challenge
#
# Usage:
#   ./test.sh [--output_path <junit.xml>] <base|new>
#
#   base  run the existing repository tests as a regression check.
#         Must pass both before and after the solution is applied.
#   new   run the new challenge tests; these fail before the solution
#         and pass after it.

# Set default output path
OUTPUT_PATH="results.xml"

# Parse arguments
MODE=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --output_path) OUTPUT_PATH="$2"; shift ;;
        base) MODE="base" ;;
        new) MODE="new" ;;
    esac
    shift
done

if [ -z "$MODE" ]; then
    echo "Usage: ./test.sh [--output_path results.xml] {base|new}"
    exit 1
fi

# Run tests using pytest to ensure JUnit XML output for Shipd/Olympus
if [ "$MODE" == "base" ]; then
    echo "Running regression tests (base mode)..."
    # Run all tests in the Testing folder
    pytest Testing/ --junitxml="$OUTPUT_PATH"
    EXIT_CODE=$?
fi

if [ "$MODE" == "new" ]; then
    echo "Running new Rayleigh Damping tests..."
    # Run only the specific challenge test file
    pytest Testing/test_rayleigh_damping.py --junitxml="$OUTPUT_PATH"
    EXIT_CODE=$?
fi

exit $EXIT_CODE
