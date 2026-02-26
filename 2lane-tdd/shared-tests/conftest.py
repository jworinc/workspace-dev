"""
Pytest configuration for 2-lane TDD framework.
Dynamically imports from the active lane (AS-IS or TO-BE).
"""

import sys
import os
import pytest

# Get workspace root
WORKSPACE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ACTIVE_LANE_FILE = os.path.join(WORKSPACE_DIR, '.active-lane')

def get_active_lane():
    """Get the currently active lane."""
    if os.path.exists(ACTIVE_LANE_FILE):
        with open(ACTIVE_LANE_FILE, 'r') as f:
            return f.read().strip()
    # Default to AS-IS if no active lane set
    return 'asis'

def setup_lane_imports():
    """Configure Python path to use the active lane."""
    active_lane = get_active_lane()
    lane_path = os.path.join(WORKSPACE_DIR, 'lanes', active_lane)
    shared_tests_path = os.path.join(WORKSPACE_DIR, 'shared-tests')

    # Add lanes to Python path
    if lane_path not in sys.path:
        sys.path.insert(0, lane_path)

    # Add shared tests to Python path
    if shared_tests_path not in sys.path:
        sys.path.insert(0, shared_tests_path)

    print(f"🧪 Using lane: {active_lane}")
    return active_lane

# Setup imports on module load
ACTIVE_LANE = setup_lane_imports()

# Pytest fixture for lane information
@pytest.fixture
def active_lane():
    """Provide the active lane to tests."""
    return ACTIVE_LANE

# Pytest fixture for lane path
@pytest.fixture
def lane_path():
    """Provide the path to the active lane."""
    return os.path.join(WORKSPACE_DIR, 'lanes', ACTIVE_LANE)
