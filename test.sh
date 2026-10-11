#!/bin/bash

# Exit on error
set -e

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

if [ "$MODE" == "base" ]; then
    echo "Running regression tests (base mode)..."
    # Run existing PyNite tests. 
    # Since PyNite uses unittest, we can use python -m unittest discover
    # We use pytest if available to generate JUnit XML easily, otherwise unittest.
    if command -v pytest &> /dev/null; then
        pytest Testing/ --junitxml="$OUTPUT_PATH"
    else
        # Fallback to unittest and a simple conversion or just run it
        # For shipd, JUnit XML is expected. We'll assume pytest for the harness.
        python3 -m unittest discover Testing/
        echo "Warning: pytest not found. results.xml may not be generated correctly."
    fi
fi

if [ "$MODE" == "new" ]; then
    echo "Running new Rayleigh Damping tests..."
    # Run only the new test file
    if command -v pytest &> /dev/null; then
        pytest Testing/test_rayleigh_damping.py --junitxml="$OUTPUT_PATH"
    else
        python3 -m unittest Testing/test_rayleigh_damping.py
        echo "Warning: pytest not found. results.xml may not be generated correctly."
    fi
fi
