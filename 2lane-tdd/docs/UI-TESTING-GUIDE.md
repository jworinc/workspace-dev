# UI Testing & Data Generation Guide

Complete guide for screenshot testing, user action simulation, and data generation in the 2-lane TDD framework.

## 🎯 What You Can Do Now

| Capability | Implementation | Skills Used |
|------------|-----------------|--------------|
| **Screenshot Testing** | `test_ui_screenshots.py` | agent-browser |
| **Visual Comparison** | PIL-based diff | Pillow |
| **User Actions** | Click, type, scroll | agent-browser |
| **Data Generation** | `test_data_generation.py` | Faker-style generator |
| **Browser Sessions** | Multi-session testing | agent-browser |

## 📦 Required Dependencies

```bash
cd ~/.openclaw/workspace-dev/2lane-tdd

# Install PIL for image comparison
python3 -m pip install Pillow --break-system-packages --user

# agent-browser should already be installed (skill integration)
# If not: clawhub install agent-browser
```

## 🖼️ Screenshot Testing

### Basic Screenshot Comparison

```python
# shared-tests/test_landing_visuals.py
import pytest
from test_ui_screenshots import ScreenshotComparator

@pytest.fixture
def comparator():
    return ScreenshotComparator()

def test_landing_page_visuals(comparator):
    """Ensure AS-IS and TO-BE have identical landing pages"""

    # Capture screenshots
    asis_path = comparator.capture_screenshot("asis", "http://localhost:3000", "landing")
    tobe_path = comparator.capture_screenshot("tobe", "http://localhost:3001", "landing")

    # Compare (allow 10% difference)
    is_similar, similarity = comparator.compare_screenshots(
        asis_path,
        tobe_path,
        threshold=0.90
    )

    assert is_similar, f"Similarity {similarity:.2%} below 90%"
```

### Run Screenshot Tests

```bash
cd ~/.openclaw/workspace-dev/2lane-tdd

# Run all screenshot tests
python3 -m pytest shared-tests/test_ui_screenshots.py -v

# Run specific test
python3 -m pytest shared-tests/test_ui_screenshots.py::test_landing_page_visuals -v

# Run with verbose output
python3 -m pytest shared-tests/test_ui_screenshots.py -vv -s
```

## 🎬 User Action Simulation

### Click, Type, Navigate

```python
# shared-tests/test_user_actions.py
import subprocess
import json

def test_user_login_flow():
    """Test complete login flow in both lanes"""

    for lane in ["asis", "tobe"]:
        # 1. Open login page
        subprocess.run(
            ["agent-browser", "--session", lane, "open", "http://localhost:3000/login"],
            capture_output=True
        )

        # 2. Wait for page load
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--load", "networkidle"],
            capture_output=True
        )

        # 3. Snapshot to find elements
        result = subprocess.run(
            ["agent-browser", "--session", lane, "snapshot", "-i", "--json"],
            capture_output=True,
            text=True
        )

        elements = json.loads(result.stdout)

        # 4. Find username field
        username_fields = [e for e in elements if e.get("name") == "username"]
        assert len(username_fields) > 0, f"{lane}: Username field not found"

        username_ref = username_fields[0]["ref"]

        # 5. Type username
        subprocess.run(
            ["agent-browser", "--session", lane, "fill", username_ref, "testuser@example.com"],
            capture_output=True
        )

        # 6. Find and fill password
        password_fields = [e for e in elements if e.get("type") == "password"]
        if password_fields:
            password_ref = password_fields[0]["ref"]
            subprocess.run(
                ["agent-browser", "--session", lane, "fill", password_ref, "password123"],
                capture_output=True
            )

        # 7. Click submit button
        submit_buttons = [e for e in elements if e.get("type") == "submit"]
        if submit_buttons:
            button_ref = submit_buttons[0]["ref"]
            subprocess.run(
                ["agent-browser", "--session", lane, "click", button_ref],
                capture_output=True
            )

        # 8. Wait for redirect
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--text", "Welcome"],
            capture_output=True
        )

        # 9. Verify current URL
        result = subprocess.run(
            ["agent-browser", "--session", lane, "get", "url", "--json"],
            capture_output=True,
            text=True
        )

        current_url = json.loads(result.stdout)
        assert "/dashboard" in current_url, f"{lane}: Login failed - not redirected to dashboard"


def test_shopping_cart_flow():
    """Test add-to-cart flow"""

    for lane in ["asis", "tobe"]:
        # Open product page
        subprocess.run(
            ["agent-browser", "--session", lane, "open", "http://localhost:3000/product/123"],
            capture_output=True
        )

        # Wait for load
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--load", "networkidle"],
            capture_output=True
        )

        # Click "Add to Cart" button
        subprocess.run(
            ["agent-browser", "--session", lane, "click", "@e1"],
            capture_output=True
        )

        # Wait for cart update
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--text", "Added to cart"],
            capture_output=True
        )

        # Navigate to cart
        subprocess.run(
            ["agent-browser", "--session", lane, "open", "http://localhost:3000/cart"],
            capture_output=True
        )

        # Verify item in cart
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--text", "Product 123"],
            capture_output=True
        )


def test_form_submission():
    """Test contact form submission"""

    for lane in ["asis", "tobe"]:
        # Open contact form
        subprocess.run(
            ["agent-browser", "--session", lane, "open", "http://localhost:3000/contact"],
            capture_output=True
        )

        # Wait for load
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--load", "networkidle"],
            capture_output=True
        )

        # Fill form
        subprocess.run(
            ["agent-browser", "--session", lane, "fill", "@e1", "John Doe"],
            capture_output=True
        )

        subprocess.run(
            ["agent-browser", "--session", lane, "fill", "@e2", "john@example.com"],
            capture_output=True
        )

        subprocess.run(
            ["agent-browser", "--session", lane, "fill", "@e3", "Hello, this is a test message."],
            capture_output=True
        )

        # Submit
        subprocess.run(
            ["agent-browser", "--session", lane, "click", "@e4"],
            capture_output=True
        )

        # Verify success
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "--text", "Message sent"],
            capture_output=True
        )


def test_navigation_and_scrolling():
    """Test navigation and scrolling"""

    for lane in ["asis", "tobe"]:
        # Open homepage
        subprocess.run(
            ["agent-browser", "--session", lane, "open", "http://localhost:3000/"],
            capture_output=True
        )

        # Scroll down
        subprocess.run(
            ["agent-browser", "--session", lane, "scroll", "down", "500"],
            capture_output=True
        )

        # Wait for content to load
        subprocess.run(
            ["agent-browser", "--session", lane, "wait", "2000"],
            capture_output=True
        )

        # Scroll up
        subprocess.run(
            ["agent-browser", "--session", lane, "scroll", "up", "250"],
            capture_output=True
        )

        # Click footer link
        subprocess.run(
            ["agent-browser", "--session", lane, "click", "@e5"],
            capture_output=True
        )

        # Verify navigation
        result = subprocess.run(
            ["agent-browser", "--session", lane, "get", "url", "--json"],
            capture_output=True,
            text=True
        )

        current_url = json.loads(result.stdout)
        assert "/about" in current_url or "/privacy" in current_url
```

## 📊 Data Generation

### Generate Realistic Test Data

```python
# shared-tests/test_data_integration.py
import pytest
from test_data_generation import TestDataGenerator

@pytest.fixture
def generator():
    return TestDataGenerator()

def test_create_users_with_generated_data(generator):
    """Test user creation with realistic data"""

    # Generate 10 test users
    users = [generator.generate_user() for _ in range(10)]

    for user in users:
        # Test AS-IS lane
        result_asis = create_user(user, lane="asis")
        assert result_asis["status"] == "ok"

        # Test TO-BE lane
        result_tobe = create_user(user, lane="tobe")
        assert result_tobe["status"] == "ok"


def test_create_orders_with_generated_data(generator):
    """Test order creation with realistic data"""

    # Generate test orders
    orders = [generator.generate_order(user_id="user-123") for _ in range(5)]

    for order in orders:
        # Test AS-IS
        result_asis = process_order(order, lane="asis")
        assert result_asis["status"] in ["pending", "confirmed"]

        # Test TO-BE
        result_tobe = process_order(order, lane="tobe")
        assert result_tobe["status"] in ["pending", "confirmed"]


def test_api_requests_with_generated_data(generator):
    """Test API with generated requests"""

    # Generate API requests
    requests = [generator.generate_api_request() for _ in range(10)]

    for request in requests:
        # Send to AS-IS
        response_asis = send_request(request, port=8000)
        assert response_asis["status_code"] < 500

        # Send to TO-BE
        response_tobe = send_request(request, port=8001)
        assert response_tobe["status_code"] < 500
```

### Run Data Generation Tests

```bash
cd ~/.openclaw/workspace-dev/2lane-tdd

# Run all data generation tests
python3 -m pytest shared-tests/test_data_generation.py -v

# Test specific data type
python3 -m pytest shared-tests/test_data_generation.py::test_generate_user -v

# Test data integration
python3 -m pytest shared-tests/test_data_integration.py -v
```

## 🎥 Video Recording

### Record User Flows

```python
# shared-tests/test_video_recording.py
import subprocess
from pathlib import Path

def test_record_user_flow():
    """Record and verify user flow as video"""

    screenshots_dir = Path(__file__).parent.parent / "screenshots"
    screenshots_dir.mkdir(exist_ok=True)

    for lane in ["asis", "tobe"]:
        video_path = screenshots_dir / f"{lane}/user-flow.webm"
        video_path.parent.mkdir(exist_ok=True)

        # Open page
        subprocess.run(
            ["agent-browser", "--session", lane, "open", "http://localhost:3000/"],
            capture_output=True
        )

        # Start recording
        subprocess.run(
            ["agent-browser", "--session", lane, "record", "start", str(video_path)],
            capture_output=True
        )

        # Perform user flow
        subprocess.run(
            ["agent-browser", "--session", lane, "scroll", "down", "500"],
            capture_output=True
        )

        subprocess.run(
            ["agent-browser", "--session", lane, "click", "@e1"],
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

        # Verify video file exists
        assert video_path.exists(), f"{lane}: Video not recorded"
        assert video_path.stat().st_size > 0, f"{lane}: Video file is empty"
```

## 📱 Responsive Design Testing

### Test Multiple Viewports

```python
# shared-tests/test_responsive.py

def test_responsive_layouts():
    """Test responsive layouts across viewport sizes"""

    viewports = [
        (1920, 1080),  # Desktop
        (1366, 768),   # Laptop
        (768, 1024),    # Tablet portrait
        (375, 667),     # Mobile
    ]

    for width, height in viewports:
        for lane in ["asis", "tobe"]:
            # Open page
            subprocess.run(
                ["agent-browser", "--session", lane, "open", "http://localhost:3000/"],
                capture_output=True
            )

            # Set viewport
            subprocess.run(
                ["agent-browser", "--session", lane, "set", "viewport", str(width), str(height)],
                capture_output=True
            )

            # Wait for layout update
            subprocess.run(
                ["agent-browser", "--session", lane, "wait", "1000"],
                capture_output=True
            )

            # Capture screenshot
            screenshot_path = Path(__file__).parent.parent / f"screenshots/{lane}/viewport-{width}x{height}.png"
            screenshot_path.parent.mkdir(exist_ok=True)

            subprocess.run(
                ["agent-browser", "--session", lane, "screenshot", str(screenshot_path)],
                capture_output=True
            )

            # Assert screenshot captured
            assert screenshot_path.exists()
```

## 🧪 Complete Test Workflow

### Full End-to-End Test

```bash
#!/bin/bash
# scripts/run-e2e-tests.sh

set -e

echo "🧪 Running End-to-End Tests"
echo "================================"

# 1. Screenshot Tests
echo "📸 Running screenshot tests..."
python3 -m pytest shared-tests/test_ui_screenshots.py -v

# 2. User Action Tests
echo "🎯 Running user action tests..."
python3 -m pytest shared-tests/test_user_actions.py -v

# 3. Data Generation Tests
echo "📊 Running data generation tests..."
python3 -m pytest shared-tests/test_data_generation.py -v

# 4. Video Recording Tests
echo "🎥 Running video recording tests..."
python3 -m pytest shared-tests/test_video_recording.py -v

# 5. Responsive Tests
echo "📱 Running responsive tests..."
python3 -m pytest shared-tests/test_responsive.py -v

echo ""
echo "================================"
echo "✅ All E2E tests passed!"
```

## 🎯 Best Practices

### 1. Visual Testing

- **Use appropriate thresholds**: 90-95% for identical pages, 80-85% for different content
- **Test critical pages**: Landing, login, checkout, error pages
- **Multiple viewports**: Test desktop, tablet, mobile
- **Avoid dynamic content**: Timestamps, random IDs, etc.

### 2. User Action Testing

- **Wait for stability**: Always wait for `networkidle` before interacting
- **Use refs, not coordinates**: Use `@e1`, `@e2` not absolute positions
- **Test error cases**: Invalid inputs, missing fields, etc.
- **Verify outcomes**: Check URL, text, element state after actions

### 3. Data Generation

- **Set seeds for reproducibility**: Use `generator.set_seed(42)` for consistent tests
- **Validate realistic data**: Email formats, phone numbers, age ranges
- **Test edge cases**: Empty data, maximum values, invalid types
- **Generate large datasets**: Test performance with 1000+ records

### 4. Video Recording

- **Keep recordings short**: 5-10 seconds per flow
- **Test critical paths**: Login, checkout, signup
- **Verify file size**: Ensure videos are not empty
- **Clean up old recordings**: Delete videos after test run

## 🚀 Quick Start

```bash
cd ~/.openclaw/workspace-dev/2lane-tdd

# 1. Install dependencies
python3 -m pip install Pillow --break-system-packages --user

# 2. Run all UI tests
python3 -m pytest shared-tests/test_ui_screenshots.py -v

# 3. Run user action tests
python3 -m pytest shared-tests/test_user_actions.py -v

# 4. Run data generation tests
python3 -m pytest shared-tests/test_data_generation.py -v

# 5. Run complete E2E test suite
./scripts/run-e2e-tests.sh
```

## 📚 Additional Skills to Consider

### If You Need More Capabilities:

| Capability | Potential Skill | Why |
|------------|-----------------|-----|
| **Visual Regression** | `visual-regression` | More advanced diff, ignore dynamic content |
| **API Mocking** | `api-mock` | Mock external APIs for isolated testing |
| **Performance Testing** | `perf-test` | Load testing, response time metrics |
| **Accessibility Testing** | `a11y-test` | WCAG compliance, screen reader support |
| **Security Testing** | `security-scan` | XSS, CSRF, SQL injection detection |
| **GraphQL Testing** | `graphql-test` | GraphQL query/mutation testing |
| **Mobile Testing** | `mobile-test` | Real device testing, app automation |

---

**Location**: `~/.openclaw/workspace-dev/2lane-tdd/docs/UI-TESTING-GUIDE.md`
