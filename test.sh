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

# Define the test runner command
if python3 -m pytest --version &> /dev/null; then
    RUNNER="python3 -m pytest"
else
    RUNNER="pytest"
fi

if [ "$MODE" == "base" ]; then
    echo "Running regression tests (base mode)..."
    
    # Explicitly list all tests except test_pushover.py and T Matrix Test.py (which might also use GUI/Tk)
    TESTS=(
        "Testing/test_2D_frames.py"
        "Testing/test_AISC_PDelta_benchmarks.py"
        "Testing/test_TC_analysis.py"
        "Testing/test_analysis_regeneration.py"
        "Testing/test_continuous_beam.py"
        "Testing/test_delete_mesh.py"
        "Testing/test_end_releases.py"
        "Testing/test_instability.py"
        "Testing/test_loads.py"
        "Testing/test_material_section_coverage.py"
        "Testing/test_member_internal_results.py"
        "Testing/test_member_rotation.py"
        "Testing/test_mesh_regen_simple.py"
        "Testing/test_mesh_regeneration.py"
        "Testing/test_meshes.py"
        "Testing/test_modal_analysis.py"
        "Testing/test_needs_update_flag.py"
        "Testing/test_node_merge.py"
        "Testing/test_node_spring_coverage.py"
        "Testing/test_reactions.py"
        "Testing/test_reanalysis.py"
        "Testing/test_reporting.py"
        "Testing/test_shear_wall.py"
        "Testing/test_sloped_beam.py"
        "Testing/test_spring_support.py"
        "Testing/test_springs.py"
        "Testing/test_support_settlement.py"
        "Testing/test_torsion.py"
        "Testing/test_unstable_structure.py"
        "Testing/test_vtkwriter.py"
    )
    
    $RUNNER "${TESTS[@]}" --junitxml="$OUTPUT_PATH"
    EXIT_CODE=$?
fi

if [ "$MODE" == "new" ]; then
    echo "Running new Rayleigh Damping tests..."
    $RUNNER Testing/test_rayleigh_damping.py --junitxml="$OUTPUT_PATH"
    EXIT_CODE=$?
fi

exit $EXIT_CODE
