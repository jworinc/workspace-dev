# TDD Workflow with 2-Lane Framework

Complete guide for Test-Driven Development using the 2-lane framework with integrated skills.

## 🎯 TDD Red/Green/Refactor Cycle

### Phase 1: RED (Write Failing Test)

**Goal**: Write a test that describes the desired behavior but fails because the implementation doesn't exist.

```bash
# 1. Create test file
cat > shared-tests/test_user_creation.py << 'EOF'
import pytest

def test_create_user_with_valid_data():
    """Create a user with valid email and name"""
    # Arrange
    user_data = {
        "email": "test@example.com",
        "name": "Test User",
        "password": "secure123"
    }

    # Act
    result = create_user(user_data)

    # Assert
    assert result["status"] == "ok"
    assert result["user"]["email"] == "test@example.com"
    assert result["user"]["name"] == "Test User"
    assert "id" in result["user"]
    assert "password" not in result["user"]  # Never return password!
EOF

# 2. Run tests (expect failure)
./scripts/verify-both.sh
```

**Expected Output:**
```
❌ AS-IS: FAILED
   NameError: name 'create_user' is not defined

❌ TO-BE: FAILED
   NameError: name 'create_user' is not defined
```

### Phase 2: GREEN (Make Tests Pass)

**Goal**: Write the minimum code to make tests pass in BOTH lanes.

```bash
# 1. Implement in AS-IS lane
cat > lanes/asis/user_service.py << 'EOF'
import uuid

def create_user(user_data):
    """Create a new user (AS-IS version - simple)"""
    user_id = str(uuid.uuid4())
    user = {
        "id": user_id,
        "email": user_data["email"],
        "name": user_data["name"],
        "password": user_data["password"]  # Store it
    }
    # In real implementation, save to DB
    return {"status": "ok", "user": user}
EOF

# 2. Implement in TO-BE lane (better architecture)
cat > lanes/tobe/user_service.py << 'EOF'
import uuid
from dataclasses import dataclass

@dataclass
class User:
    id: str
    email: str
    name: str
    password: str  # In real app, this would be hashed

    def to_dict(self):
        """Exclude password from serialization"""
        return {
            "id": self.id,
            "email": self.email,
            "name": self.name
        }

class UserRepository:
    """Repository pattern for better separation"""
    def save(self, user):
        # In real implementation, save to DB
        return user

def create_user(user_data):
    """Create a new user (TO-BE version - better architecture)"""
    user = User(
        id=str(uuid.uuid4()),
        email=user_data["email"],
        name=user_data["name"],
        password=user_data["password"]
    )

    repository = UserRepository()
    saved_user = repository.save(user)

    return {
        "status": "ok",
        "user": saved_user.to_dict()  # Password excluded!
    }
EOF

# 3. Create conftest.py to import from correct lane
cat > shared-tests/conftest.py << 'EOF'
import sys
import os

# Get active lane from .active-lane file
active_lane_file = os.path.join(os.path.dirname(__file__), '..', '.active-lane')

if os.path.exists(active_lane_file):
    active_lane = open(active_lane_file).read().strip()
    lane_path = os.path.join(os.path.dirname(__file__), '..', 'lanes', active_lane)
    sys.path.insert(0, lane_path)
    print(f"🧪 Using lane: {active_lane}")
else
    # Default to AS-IS if no active lane
    lane_path = os.path.join(os.path.dirname(__file__), '..', 'lanes', 'asis')
    sys.path.insert(0, lane_path)
    print("🧪 Using lane: asis (default)")
EOF

# 4. Run tests (expect success)
./scripts/verify-both.sh
```

**Expected Output:**
```
🧪 Using lane: asis
✅ AS-IS: All tests passed

🧪 Using lane: tobe
✅ TO-BE: All tests passed
```

### Phase 3: REFACTOR (Improve TO-BE Only)

**Goal**: Improve TO-BE implementation without breaking tests.

```bash
# 1. Refactor TO-BE with better patterns
cat > lanes/tobe/user_service.py << 'EOF'
import uuid
from dataclasses import dataclass
from typing import Optional

@dataclass
class User:
    id: str
    email: str
    name: str
    password: str

    def to_dict(self):
        return {
            "id": self.id,
            "email": self.email,
            "name": self.name
        }

    def validate_email(self) -> bool:
        return "@" in self.email and "." in self.email

class UserRepository:
    def __init__(self):
        self._users = {}

    def save(self, user):
        self._users[user.id] = user
        return user

    def find_by_email(self, email: str) -> Optional[User]:
        for user in self._users.values():
            if user.email == email:
                return user
        return None

def create_user(user_data):
    """Create user with validation and repository pattern"""
    user = User(
        id=str(uuid.uuid4()),
        email=user_data["email"],
        name=user_data["name"],
        password=user_data["password"]
    )

    # Validate email
    if not user.validate_email():
        return {
            "status": "error",
            "message": "Invalid email address"
        }

    repository = UserRepository()

    # Check for duplicate email
    existing = repository.find_by_email(user.email)
    if existing:
        return {
            "status": "error",
            "message": "Email already exists"
        }

    saved_user = repository.save(user)
    return {
        "status": "ok",
        "user": saved_user.to_dict()
    }
EOF

# 2. Run tests (TO-BE should still pass)
./scripts/verify-both.sh
```

**Expected Output:**
```
🧪 Using lane: asis
✅ AS-IS: All tests passed

🧪 Using lane: tobe
✅ TO-BE: All tests passed
```

## 🧪 Skill Integration Examples

### Example 1: clean-pytest (Fakes + AAA Pattern)

```python
# shared-tests/test_user_service.py
import pytest
from user_service import create_user
from tests.fakes import FakeDatabase, FakeEmailService

@pytest.fixture
def fake_db():
    """In-memory fake database (no real DB)"""
    return FakeDatabase()

@pytest.fixture
def fake_email():
    """Fake email service (no real emails)"""
    return FakeEmailService()

def test_create_user_saves_to_db(fake_db, fake_email):
    # Arrange - Prepare test data
    user_data = {
        "email": "test@example.com",
        "name": "Test User"
    }

    # Act - Execute the function
    result = create_user(user_data, db=fake_db, email_service=fake_email)

    # Assert - Verify behavior
    assert result["status"] == "ok"
    assert fake_db.users_count() == 1  # Fake DB was called
    assert fake_email.sent_count() == 1  # Email was sent
    assert fake_email.last_email_to() == "test@example.com"
```

**Fake Implementation:**
```python
# shared-tests/tests/fakes.py
class FakeDatabase:
    """In-memory fake database"""
    def __init__(self):
        self._users = []

    def save_user(self, user):
        self._users.append(user)

    def users_count(self):
        return len(self._users)

class FakeEmailService:
    """Fake email service (no real emails)"""
    def __init__(self):
        self._emails = []

    def send_welcome_email(self, email):
        self._emails.append(email)

    def sent_count(self):
        return len(self._emails)

    def last_email_to(self):
        return self._emails[-1] if self._emails else None
```

### Example 2: agent-browser (UI Testing Across Lanes)

```bash
# Test AS-IS UI (port 3000)
agent-browser --session asis open http://localhost:3000/register
agent-browser --session asis snapshot -i
agent-browser --session asis fill @e1 "test@example.com"
agent-browser --session asis fill @e2 "Test User"
agent-browser --session asis fill @e3 "password123"
agent-browser --session asis click @e4
agent-browser --session asis wait --text "Registration successful"

# Test TO-BE UI (port 3001)
agent-browser --session tobe open http://localhost:3001/register
agent-browser --session tobe snapshot -i
agent-browser --session tobe fill @e1 "test@example.com"
agent-browser --session tobe fill @e2 "Test User"
agent-browser --session tobe fill @e3 "password123"
agent-browser --session tobe click @e4
agent-browser --session tobe wait --text "Registration successful"
```

### Example 3: test-patterns (Parametrized Tests)

```python
# shared-tests/test_parametrized.py
import pytest
from user_service import create_user

# Test multiple scenarios with parametrization
@pytest.mark.parametrize("email,name,password,expected", [
    ("test@example.com", "Test User", "pass123", "ok"),    # Valid
    ("invalid-email", "Test User", "pass123", "error"),    # Invalid email
    ("", "Test User", "pass123", "error"),                # Empty email
])
def test_create_user_validation(email, name, password, expected):
    result = create_user({"email": email, "name": name, "password": password})
    assert result["status"] == expected

# Test with fixtures
@pytest.fixture
def sample_users():
    return [
        {"email": "alice@example.com", "name": "Alice"},
        {"email": "bob@example.com", "name": "Bob"},
    ]

def test_create_multiple_users(sample_users):
    for user_data in sample_users:
        result = create_user(user_data)
        assert result["status"] == "ok"
```

### Example 4: ai-api-test (API Contract Testing)

```python
# shared-tests/test_api_contract.py
import pytest
import requests

def test_health_endpoint_asis():
    """Test AS-IS API health endpoint"""
    response = requests.get("http://localhost:8000/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_health_endpoint_tobe():
    """Test TO-BE API health endpoint"""
    response = requests.get("http://localhost:8001/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_api_contract_consistency():
    """Ensure both APIs return same structure"""
    asis_resp = requests.get("http://localhost:8000/api/v1/health").json()
    tobe_resp = requests.get("http://localhost:8001/api/v1/health").json()

    assert asis_resp.keys() == tobe_resp.keys()
    assert "status" in asis_resp
    assert "services" in tobe_resp
```

## 🔄 Parallel Development Workflow

### Option 1: Multiple Terminals (Side-by-Side)

```bash
# Terminal 1: Work on AS-IS
cd ~/.openclaw/workspace-dev/2lane-tdd
./scripts/switch-lane.sh asis
cd $(./scripts/switch-lane.sh --path)
vim user_service.py
pytest shared-tests/ -x --watch

# Terminal 2: Work on TO-BE (simultaneously)
cd ~/.openclaw/workspace-dev/2lane-tdd
./scripts/switch-lane.sh tobe
cd $(./scripts/switch-lane.sh --path)
vim user_service.py
pytest shared-tests/ -x --watch

# Terminal 3: Verify both lanes
cd ~/.openclaw/workspace-dev/2lane-tdd
watch -n 5 './scripts/verify-both.sh'
```

### Option 2: Sub-Agent Sessions (Parallel AI Agents)

```bash
# Main session: Manage tests
cd ~/.openclaw/workspace-dev/2lane-tdd
./scripts/verify-both.sh

# Spawn sub-agent for TO-BE refactoring
sessions_spawn --task "Refactor user_service.py with repository pattern and validation" \
  --mode session \
  --label "tobe-refactor" \
  --model vibeproxy/glm-4.7

# Continue working on AS-IS in main session
vim lanes/asis/user_service.py

# Sub-agent will report back when TO-BE is ready
```

### Option 3: Split-Pane Tmux (Single Terminal)

```bash
# Setup tmux session for 2-lane dev
tmux new-session -d -s 2lane

# Pane 0: AS-IS (top)
tmux send-keys -t 2lane:0 "cd ~/.openclaw/workspace-dev/2lane-tdd && ./scripts/switch-lane.sh asis" Enter
tmux send-keys -t 2lane:0 "cd \$(./scripts/switch-lane.sh --path)" Enter
tmux send-keys -t 2lane:0 "vim user_service.py" Enter

# Pane 1: TO-BE (bottom)
tmux split-window -h -t 2lane:0
tmux send-keys -t 2lane:1 "cd ~/.openclaw/workspace-dev/2lane-tdd && ./scripts/switch-lane.sh tobe" Enter
tmux send-keys -t 2lane:1 "cd \$(./scripts/switch-lane.sh --path)" Enter
tmux send-keys -t 2lane:1 "vim user_service.py" Enter

# Pane 2: Tests (right)
tmux split-window -v -t 2lane:1
tmux send-keys -t 2lane:2 "cd ~/.openclaw/workspace-dev/2lane-tdd" Enter
tmux send-keys -t 2lane:2 "watch -n 2 './scripts/verify-both.sh'" Enter

# Attach to session
tmux attach-session -t 2lane
```

## 📊 Test Coverage

```bash
# Check coverage for AS-IS
cd lanes/asis && pytest --cov=. --cov-report=html shared-tests/

# Check coverage for TO-BE
cd lanes/tobe && pytest --cov=. --cov-report=html shared-tests/

# Compare coverage between lanes
diff -u <(cd lanes/asis && coverage report) <(cd lanes/tobe && coverage report)
```

## 🚀 Quick Reference

```bash
# Switch lanes
./scripts/switch-lane.sh asis    # Switch to AS-IS
./scripts/switch-lane.sh tobe    # Switch to TO-BE
./scripts/switch-lane.sh current # Show current lane

# Verify both lanes
./scripts/verify-both.sh         # Run tests in both lanes
./scripts/verify-both.sh --verbose  # With verbose output

# Compare implementations
./scripts/diff-lanes.sh user_service.py      # Compare file
./scripts/diff-lanes.sh user_service.py --stats  # With statistics

# Jump to active lane
cd $(./scripts/switch-lane.sh --path)
```

---

**Location**: `~/.openclaw/workspace-dev/2lane-tdd/docs/TDD-WORKFLOW.md`
