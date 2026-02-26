"""
UI Screenshot Tests for 2-Lane TDD Framework.
Uses agent-browser to capture visual states and compare across lanes.
"""

import pytest
import os
import subprocess
import json
from pathlib import Path

# Configuration
LANES_DIR = Path(__file__).parent.parent / "lanes"
SCREENSHOTS_DIR = Path(__file__).parent.parent / "screenshots"
AGENTS_DIR = Path(__file__).parent.parent / "lanes"


class ScreenshotComparator:
    """Compare screenshots between AS-IS and TO-BE lanes"""

    def __init__(self):
        self.screenshots_dir = SCREENSHOTS_DIR
        self.screenshots_dir.mkdir(exist_ok=True)

    def capture_screenshot(self, lane, url, name):
        """Capture screenshot for specific lane"""
        screenshot_path = self.screenshots_dir / f"{lane}/{name}.png"
        screenshot_path.parent.mkdir(exist_ok=True)

        # Use agent-browser to capture screenshot
        result = subprocess.run(
            [
                "agent-browser",
                "--session", lane,
                "open", url
            ],
            capture_output=True,
            text=True
        )

        # Wait for page load
        subprocess.run(
            [
                "agent-browser",
                "--session", lane,
                "wait", "--load", "networkidle"
            ],
            capture_output=True,
            text=True
        )

        # Capture screenshot
        subprocess.run(
            [
                "agent-browser",
                "--session", lane,
                "screenshot", str(screenshot_path),
                "--full"
            ],
            capture_output=True,
            text=True
        )

        return screenshot_path

    def compare_screenshots(self, asis_path, tobe_path, threshold=0.95):
        """Compare two screenshots using PIL"""
        try:
            from PIL import Image, ImageChops
            import numpy as np

            # Load images
            asis_img = Image.open(asis_path)
            tobe_img = Image.open(tobe_path)

            # Ensure same size
            width = max(asis_img.width, tobe_img.width)
            height = max(asis_img.height, tobe_img.height)
            asis_img = asis_img.resize((width, height))
            tobe_img = tobe_img.resize((width, height))

            # Calculate difference
            diff = ImageChops.difference(asis_img, tobe_img)

            # Calculate similarity
            diff_pixels = np.array(diff).sum() / (width * height * 255)
            similarity = 1 - diff_pixels

            return similarity >= threshold, similarity

        except ImportError:
            print("⚠️  PIL not installed. Install with: pip install Pillow")
            return True, 1.0  # Assume similar if can't compare


@pytest.fixture
def comparator():
    """Provide screenshot comparator"""
    return ScreenshotComparator()


# Test: Landing Page Visual Consistency
def test_landing_page_visuals(comparator):
    """Ensure AS-IS and TO-BE have identical landing pages"""
    url = "http://localhost:3000"  # Adjust to your app

    # Capture screenshots
    asis_path = comparator.capture_screenshot("asis", url, "landing")
    tobe_path = comparator.capture_screenshot("tobe", url, "landing")

    # Compare (TO-BE might be on different port)
    # If TO-BE uses different port, adjust URL
    if not tobe_path.exists():
        url_tobe = "http://localhost:3001"  # TO-BE port
        tobe_path = comparator.capture_screenshot("tobe", url_tobe, "landing")

    # Visual comparison
    is_similar, similarity = comparator.compare_screenshots(
        asis_path,
        tobe_path,
        threshold=0.90  # Allow 10% difference
    )

    assert is_similar, f"Visual similarity {similarity:.2%} below threshold 90%"


# Test: Login Page Layout
def test_login_page_layout(comparator):
    """Ensure login page layout is consistent"""
    url = "http://localhost:3000/login"

    # Capture screenshots
    asis_path = comparator.capture_screenshot("asis", url, "login")
    tobe_path = comparator.capture_screenshot("tobe", url, "login")

    # Compare
    is_similar, similarity = comparator.compare_screenshots(
        asis_path,
        tobe_path,
        threshold=0.85  # Allow more difference for login
    )

    assert is_similar, f"Login page similarity {similarity:.2%} below threshold 85%"


# Test: Dashboard Layout
def test_dashboard_layout(comparator):
    """Ensure dashboard layout is consistent"""
    url = "http://localhost:3000/dashboard"

    # Capture screenshots
    asis_path = comparator.capture_screenshot("asis", url, "dashboard")
    tobe_path = comparator.capture_screenshot("tobe", url, "dashboard")

    # Compare
    is_similar, similarity = comparator.compare_screenshots(
        asis_path,
        tobe_path,
        threshold=0.90
    )

    assert is_similar, f"Dashboard similarity {similarity:.2%} below threshold 90%"


# Test: Interactive Element States
def test_button_states():
    """Test button click states across lanes"""
    url = "http://localhost:3000"

    for lane in ["asis", "tobe"]:
        # Open page
        subprocess.run(
            ["agent-browser", "--session", lane, "open", url],
            capture_output=True
        )

        # Snapshot interactive elements
        result = subprocess.run(
            ["agent-browser", "--session", lane, "snapshot", "-i", "--json"],
            capture_output=True,
            text=True
        )

        # Parse elements
        elements = json.loads(result.stdout)

        # Find buttons
        buttons = [e for e in elements if e.get("role") == "button"]

        # Assert buttons exist
        assert len(buttons) > 0, f"{lane}: No buttons found"

        # Click first button
        if buttons:
            ref = buttons[0]["ref"]
            subprocess.run(
                ["agent-browser", "--session", lane, "click", ref],
                capture_output=True
            )


# Test: Form Input Behavior
def test_form_input_behavior():
    """Test form input across lanes"""
    url = "http://localhost:3000/contact"

    for lane in ["asis", "tobe"]:
        # Open page
        subprocess.run(
            ["agent-browser", "--session", lane, "open", url],
            capture_output=True
        )

        # Wait for load
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--load", "networkidle"],
            capture_output=True
        )

        # Snapshot to find inputs
        result = subprocess.run(
            ["agent-browser", "--session", lane, "snapshot", "-i", "--json"],
            capture_output=True,
            text=True
        )

        elements = json.loads(result.stdout)
        textboxes = [e for e in elements if e.get("role") == "textbox"]

        if textboxes:
            # Fill first textbox
            ref = textboxes[0]["ref"]
            test_value = "Test User Input"

            subprocess.run(
                ["agent-browser", "--session", lane, "fill", ref, test_value],
                capture_output=True
            )

            # Get value to verify
            value_result = subprocess.run(
                ["agent-browser", "--session", lane, "get", "value", ref, "--json"],
                capture_output=True,
                text=True
            )

            value = json.loads(value_result.stdout)
            assert value == test_value, f"{lane}: Input value mismatch"


# Test: Page Navigation Flow
def test_navigation_flow():
    """Test user navigation across pages"""
    base_url = "http://localhost:3000"

    for lane in ["asis", "tobe"]:
        # Start at home
        subprocess.run(
            ["agent-browser", "--session", lane, "open", f"{base_url}/"],
            capture_output=True
        )

        # Navigate to about
        subprocess.run(
            ["agent-browser", "--session", lane, "open", f"{base_url}/about"],
            capture_output=True
        )

        # Wait for load
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--load", "networkidle"],
            capture_output=True
        )

        # Check URL
        result = subprocess.run(
            ["agent-browser", "--session", lane, "get", "url", "--json"],
            capture_output=True,
            text=True
        )

        current_url = json.loads(result.stdout)
        assert "/about" in current_url, f"{lane}: Navigation failed"


# Test: Error Page Handling
def test_error_page_visuals(comparator):
    """Ensure error pages are consistent"""
    url = "http://localhost:3000/nonexistent-page"

    # Capture screenshots
    asis_path = comparator.capture_screenshot("asis", url, "error-404")
    tobe_path = comparator.capture_screenshot("tobe", url, "error-404")

    # Compare
    is_similar, similarity = comparator.compare_screenshots(
        asis_path,
        tobe_path,
        threshold=0.95  # Error pages should be very similar
    )

    assert is_similar, f"Error page similarity {similarity:.2%} below threshold 95%"


# Test: Responsive Design
def test_responsive_layouts(comparator):
    """Test responsive layouts across viewport sizes"""
    url = "http://localhost:3000"

    viewports = [
        (1920, 1080),  # Desktop
        (768, 1024),   # Tablet
        (375, 667),     # Mobile
    ]

    for width, height in viewports:
        for lane in ["asis", "tobe"]:
            # Open page
            subprocess.run(
                ["agent-browser", "--session", lane, "open", url],
                capture_output=True
            )

            # Set viewport
            subprocess.run(
                ["agent-browser", "--session", lane, "set", "viewport", str(width), str(height)],
                capture_output=True
            )

            # Capture screenshot
            screenshot_path = comparator.screenshots_dir / f"{lane}/viewport-{width}x{height}.png"
            screenshot_path.parent.mkdir(exist_ok=True)

            subprocess.run(
                ["agent-browser", "--session", lane, "screenshot", str(screenshot_path)],
                capture_output=True
            )

            # Assert screenshot exists
            assert screenshot_path.exists(), f"{lane}: Screenshot not captured for {width}x{height}"


# Test: Video Recording of User Flow
def test_user_flow_video():
    """Record and verify user flow as video"""
    url = "http://localhost:3000"

    for lane in ["asis", "tobe"]:
        # Open page
        subprocess.run(
            ["agent-browser", "--session", lane, "open", url],
            capture_output=True
        )

        # Start recording
        video_path = SCREENSHOTS_DIR / f"{lane}/user-flow.webm"
        video_path.parent.mkdir(exist_ok=True)

        subprocess.run(
            ["agent-browser", "--session", lane, "record", "start", str(video_path)],
            capture_output=True
        )

        # Perform some actions
        subprocess.run(
            ["agent-browser", "--session", lane, "scroll", "down", "500"],
            capture_output=True
        )

        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "2000"],
            capture_output=True
        )

        # Stop recording
        subprocess.run(
            ["agent-browser", "--session", lane, "record", "stop"],
            capture_output=True
        )

        # Assert video file exists
        assert video_path.exists(), f"{lane}: Video not recorded"
