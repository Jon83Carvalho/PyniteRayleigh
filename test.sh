#!/bin/bash

# Test runner for PyNite Rayleigh Damping Challenge
#
# Usage:
#   ./test.sh [--output_path <junit.xml>] <base|new>

# Force matplotlib to use a non-interactive backend for headless environments
export MPLBACKEND=Agg

# Default output path
OUTPUT_PATH="results.xml"

# Parse arguments
MODE=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --output_path) 
            if [[ -n "$2" ]]; then
                OUTPUT_PATH="$2"
                shift 2
            else
                echo "Error: --output_path requires an argument" >&2
                exit 1
            fi
            ;;
        base) MODE="base" ; shift ;;
        new) MODE="new" ; shift ;;
        *) echo "Unknown argument: $1" >&2 ; exit 1 ;;
    esac
done

if [ -z "$MODE" ]; then
    echo "Usage: ./test.sh [--output_path results.xml] {base|new}"
    exit 1
fi

# Sanity check: Verify pytest is available
if ! command -v pytest &> /dev/null && ! python3 -m pytest --version &> /dev/null; then
    echo "Error: pytest not found. Please install it via 'pip install pytest'." >&2
    exit 1
fi

# Define the test runner command to be more robust
# Use 'python3 -m pytest' if available, as it's more reliable across environments
if python3 -m pytest --version &> /dev/null; then
    RUNNER="python3 -m pytest"
else
    RUNNER="pytest"
fi

if [ "$MODE" == "base" ]; then
    echo "Running regression tests (base mode)..."
    $RUNNER Testing/ --junitxml="$OUTPUT_PATH"
    EXIT_CODE=$?
fi

if [ "$MODE" == "new" ]; then
    echo "Running new Rayleigh Damping tests..."
    $RUNNER Testing/test_rayleigh_damping.py --junitxml="$OUTPUT_PATH"
    EXIT_CODE=$?
fi

exit $EXIT_CODE
