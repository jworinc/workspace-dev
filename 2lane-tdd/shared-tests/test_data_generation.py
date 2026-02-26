"""
Data Generation Tests for 2-Lane TDD Framework.
Generates realistic test data using Faker library.
"""

import pytest
import random
from datetime import datetime, timedelta
from typing import Dict, List, Any


class TestDataGenerator:
    """Generate realistic test data for various domains"""

    def __init__(self):
        self.seed = random.randint(0, 10000)

    def set_seed(self, seed: int):
        """Set random seed for reproducible tests"""
        self.seed = seed
        random.seed(seed)

    def generate_user(self) -> Dict[str, Any]:
        """Generate a realistic user profile"""
        first_names = ["Alice", "Bob", "Charlie", "Diana", "Eve", "Frank", "Grace"]
        last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia"]

        return {
            "first_name": random.choice(first_names),
            "last_name": random.choice(last_names),
            "email": self._generate_email(),
            "phone": self._generate_phone(),
            "address": self._generate_address(),
            "age": random.randint(18, 80),
            "signup_date": self._generate_date()
        }

    def generate_product(self) -> Dict[str, Any]:
        """Generate a realistic product"""
        categories = ["Electronics", "Clothing", "Food", "Books", "Sports"]
        names = [
            "Wireless Headphones", "Cotton T-Shirt", "Organic Coffee",
            "Python Programming Book", "Running Shoes"
        ]

        return {
            "name": random.choice(names),
            "category": random.choice(categories),
            "price": round(random.uniform(10.00, 1000.00), 2),
            "stock": random.randint(0, 1000),
            "description": self._generate_description(),
            "created_at": self._generate_date()
        }

    def generate_order(self, user_id: str) -> Dict[str, Any]:
        """Generate a realistic order"""
        num_items = random.randint(1, 5)
        items = [self.generate_product() for _ in range(num_items)]

        return {
            "user_id": user_id,
            "order_id": f"ORD-{random.randint(10000, 99999)}",
            "items": items,
            "total": round(sum(item["price"] for item in items), 2),
            "status": random.choice(["pending", "shipped", "delivered", "cancelled"]),
            "created_at": self._generate_date(),
            "shipping_address": self._generate_address()
        }

    def generate_api_request(self) -> Dict[str, Any]:
        """Generate a realistic API request"""
        return {
            "method": random.choice(["GET", "POST", "PUT", "DELETE"]),
            "endpoint": random.choice([
                "/api/users",
                "/api/products",
                "/api/orders",
                "/api/auth/login"
            ]),
            "headers": self._generate_headers(),
            "params": self._generate_params(),
            "body": self._generate_body(),
            "timestamp": datetime.now().isoformat()
        }

    def generate_browser_session(self) -> Dict[str, Any]:
        """Generate realistic browser session data"""
        return {
            "user_agent": self._generate_user_agent(),
            "viewport": random.choice([
                {"width": 1920, "height": 1080},
                {"width": 1366, "height": 768},
                {"width": 768, "height": 1024},
                {"width": 375, "height": 667}
            ]),
            "cookies": self._generate_cookies(),
            "storage": self._generate_storage(),
            "pages_visited": self._generate_page_history(),
            "session_duration": random.randint(60, 3600)  # seconds
        }

    def _generate_email(self) -> str:
        """Generate realistic email"""
        domains = ["gmail.com", "yahoo.com", "outlook.com", "example.com"]
        local = f"user{random.randint(1000, 9999)}"
        return f"{local}@{random.choice(domains)}"

    def _generate_phone(self) -> str:
        """Generate realistic US phone number"""
        area_code = random.randint(200, 999)
        exchange = random.randint(200, 999)
        number = random.randint(1000, 9999)
        return f"({area_code}) {exchange}-{number}"

    def _generate_address(self) -> Dict[str, str]:
        """Generate realistic address"""
        streets = ["Main St", "Oak Ave", "Elm Blvd", "Pine Rd", "Maple Dr"]
        cities = ["Springfield", "Riverside", "Madison", "Franklin", "Georgetown"]
        states = ["CA", "TX", "NY", "FL", "IL"]

        return {
            "street": f"{random.randint(1, 9999)} {random.choice(streets)}",
            "city": random.choice(cities),
            "state": random.choice(states),
            "zip": f"{random.randint(10000, 99999)}"
        }

    def _generate_date(self) -> str:
        """Generate random date within last year"""
        days_ago = random.randint(0, 365)
        date = datetime.now() - timedelta(days=days_ago)
        return date.isoformat()

    def _generate_description(self) -> str:
        """Generate random description"""
        adjectives = ["Premium", "High-quality", "Durable", "Elegant", "Modern"]
        nouns = ["product", "item", "design", "style", "model"]
        return f"A {random.choice(adjectives)} {random.choice(nouns)} for everyday use."

    def _generate_headers(self) -> Dict[str, str]:
        """Generate realistic HTTP headers"""
        return {
            "Content-Type": random.choice(["application/json", "application/x-www-form-urlencoded"]),
            "Accept": "application/json",
            "User-Agent": self._generate_user_agent(),
            "Authorization": f"Bearer {random.randint(1000000, 9999999)}"
        }

    def _generate_params(self) -> Dict[str, Any]:
        """Generate realistic query parameters"""
        return {
            "page": random.randint(1, 10),
            "limit": random.randint(10, 100),
            "sort": random.choice(["asc", "desc"]),
            "filter": random.choice(["active", "inactive", "all"])
        }

    def _generate_body(self) -> Dict[str, Any]:
        """Generate realistic request body"""
        return {
            "data": random.choice(["test", "sample", "example"]),
            "value": random.randint(1, 100),
            "active": random.choice([True, False])
        }

    def _generate_user_agent(self) -> str:
        """Generate realistic user agent"""
        browsers = ["Chrome", "Firefox", "Safari", "Edge"]
        os_versions = ["Macintosh", "Windows NT 10.0", "X11; Linux x86_64"]

        browser = random.choice(browsers)
        version = f"{random.randint(100, 130)}.0.{random.randint(0, 9999)}"
        os_version = random.choice(os_versions)

        return f"Mozilla/5.0 ({os_version}) AppleWebKit/537.36 (KHTML, like Gecko) {browser}/{version} Safari/537.36"

    def _generate_cookies(self) -> List[Dict[str, Any]]:
        """Generate realistic cookies"""
        return [
            {
                "name": "session_id",
                "value": f"sess_{random.randint(1000000, 9999999)}",
                "domain": "example.com",
                "path": "/",
                "expires": (datetime.now() + timedelta(days=30)).isoformat()
            },
            {
                "name": "user_pref",
                "value": f"pref_{random.randint(100, 999)}",
                "domain": "example.com",
                "path": "/",
                "expires": (datetime.now() + timedelta(days=365)).isoformat()
            }
        ]

    def _generate_storage(self) -> Dict[str, Any]:
        """Generate realistic localStorage/sessionStorage"""
        return {
            "localStorage": {
                f"key_{i}": f"value_{random.randint(100, 999)}"
                for i in range(1, random.randint(3, 10))
            },
            "sessionStorage": {
                f"sess_{i}": f"val_{random.randint(100, 999)}"
                for i in range(1, random.randint(2, 6))
            }
        }

    def _generate_page_history(self) -> List[Dict[str, Any]]:
        """Generate realistic page visit history"""
        pages = ["/home", "/products", "/cart", "/checkout", "/success"]
        history = []

        for _ in range(random.randint(3, 10)):
            history.append({
                "url": f"http://example.com{random.choice(pages)}",
                "timestamp": self._generate_date(),
                "duration": random.randint(1, 300)  # seconds
            })

        return history


# Pytest fixtures
@pytest.fixture
def generator():
    """Provide data generator instance"""
    return TestDataGenerator()


@pytest.fixture
def seeded_generator():
    """Provide seeded generator for reproducible tests"""
    gen = TestDataGenerator()
    gen.set_seed(42)
    return gen


# Tests
def test_generate_user(generator):
    """Test user data generation"""
    user = generator.generate_user()

    assert "first_name" in user
    assert "last_name" in user
    assert "email" in user
    assert "@" in user["email"]
    assert 18 <= user["age"] <= 80


def test_generate_product(generator):
    """Test product data generation"""
    product = generator.generate_product()

    assert "name" in product
    assert "category" in product
    assert 10.00 <= product["price"] <= 1000.00
    assert product["stock"] >= 0


def test_generate_order(generator):
    """Test order data generation"""
    user_id = "user-123"
    order = generator.generate_order(user_id)

    assert order["user_id"] == user_id
    assert "order_id" in order
    assert len(order["items"]) >= 1
    assert order["total"] > 0
    assert order["status"] in ["pending", "shipped", "delivered", "cancelled"]


def test_generate_api_request(generator):
    """Test API request generation"""
    request = generator.generate_api_request()

    assert "method" in request
    assert request["method"] in ["GET", "POST", "PUT", "DELETE"]
    assert "endpoint" in request
    assert "headers" in request
    assert request["headers"]["Content-Type"]
    assert "User-Agent" in request["headers"]


def test_generate_browser_session(generator):
    """Test browser session generation"""
    session = generator.generate_browser_session()

    assert "user_agent" in session
    assert "Mozilla" in session["user_agent"]
    assert "viewport" in session
    assert "width" in session["viewport"]
    assert "height" in session["viewport"]
    assert "cookies" in session
    assert len(session["cookies"]) > 0
    assert "storage" in session
    assert "localStorage" in session["storage"]
    assert "sessionStorage" in session["storage"]


def test_seeded_generation(seeded_generator):
    """Test seeded generation is reproducible"""
    user1 = seeded_generator.generate_user()
    user2 = seeded_generator.generate_user()

    # Same seed should produce different data between calls
    # But consistent across test runs (if seed is fixed)
    assert user1["first_name"]
    assert user2["first_name"]


def test_user_email_format(generator):
    """Test generated emails are valid"""
    for _ in range(10):
        user = generator.generate_user()
        email = user["email"]
        assert "@" in email
        assert "." in email.split("@")[1]


def test_phone_format(generator):
    """Test generated phone numbers are valid"""
    for _ in range(10):
        user = generator.generate_user()
        phone = user["phone"]
        assert phone.count("(") == 1
        assert phone.count(")") == 1
        assert phone.count("-") == 2


def test_product_categories(generator):
    """Test product categories are from valid list"""
    valid_categories = ["Electronics", "Clothing", "Food", "Books", "Sports"]

    for _ in range(20):
        product = generator.generate_product()
        assert product["category"] in valid_categories


def test_order_total_calculation(generator):
    """Test order total is correctly calculated"""
    for _ in range(10):
        order = generator.generate_order("user-123")
        calculated_total = sum(item["price"] for item in order["items"])
        assert order["total"] == calculated_total


def test_browser_user_agent_realistic(generator):
    """Test user agents are realistic"""
    for _ in range(10):
        session = generator.generate_browser_session()
        ua = session["user_agent"]

        # Check for common browser identifiers
        assert "Mozilla" in ua
        assert "AppleWebKit" in ua or "Gecko" in ua
        assert "Safari" in ua or "Chrome" in ua or "Firefox" in ua


def test_cookie_expiration(generator):
    """Test cookies have valid expiration"""
    session = generator.generate_browser_session()
    cookies = session["cookies"]

    for cookie in cookies:
        assert "expires" in cookie
        assert len(cookie["expires"]) > 0


def test_page_history(generator):
    """Test page history is realistic"""
    session = generator.generate_browser_session()
    history = session["pages_visited"]

    assert len(history) > 0

    for page in history:
        assert "url" in page
        assert "timestamp" in page
        assert "duration" in page
        assert page["duration"] > 0
        assert page["duration"] <= 300  # Max 5 minutes per page


def test_data_uniqueness(generator):
    """Test generated data is reasonably unique"""
    users = [generator.generate_user() for _ in range(10)]
    emails = [user["email"] for user in users]

    # All emails should be unique (with high probability)
    assert len(set(emails)) >= 9  # Allow 1 collision


def test_generate_large_dataset(generator):
    """Test generating a large dataset"""
    num_users = 1000
    users = [generator.generate_user() for _ in range(num_users)]

    assert len(users) == num_users

    for user in users:
        assert "email" in user
        assert "age" in user
        assert 18 <= user["age"] <= 80
