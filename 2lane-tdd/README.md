# 2-Lane TDD Workflow

A parallel development framework for maintaining **AS-IS** (current) and **TO-BE** (refactored) versions simultaneously, using tests to guarantee correctness across both lanes.

## 🎯 Philosophy

**Never break AS-IS while building TO-BE.**

- **Lane 1 (AS-IS)**: Production code, stable, tested
- **Lane 2 (TO-BE)**: Refactored code, improved architecture, tested
- **Shared Tests**: Contract tests that must pass in BOTH lanes
- **Test-Driven**: Write tests first, implement in both lanes

## 📁 Structure

```
2lane-tdd/
├── lanes/
│   ├── asis/           # Current production code
│   │   └── <project>/
│   └── tobe/           # Refactored/improved version
│       └── <project>/
├── shared-tests/        # Contract tests (must pass in both lanes)
│   ├── conftest.py
│   └── test_contract.py
├── scripts/
│   ├── verify-both.sh      # Run tests in both lanes
│   ├── diff-lanes.sh       # Compare implementations
│   └── switch-lane.sh     # Toggle active lane
└── docs/
    ├── TDD-WORKFLOW.md     # Red/Green/Refactor cycle
    └── MIGRATION-GUIDE.md # Moving from AS-IS to TO-BE
```

## 🚀 Quick Start

### 1. Setup Project in Both Lanes

```bash
cd ~/.openclaw/workspace-dev/2lane-tdd

# Copy current code to AS-IS lane
cp -r ~/my-project lanes/asis/

# Initialize TO-BE lane (refactored structure)
mkdir -p lanes/tobe
cp -r ~/my-project lanes/tobe/
```

### 2. Write Contract Test (Shared)

```python
# shared-tests/test_contract.py
import pytest
import sys
sys.path.insert(0, 'lanes/asis')
from my_module import calculate_price

def test_calculate_price_discount():
    """This test MUST pass in both AS-IS and TO-BE"""
    result = calculate_price(100, 0.1)  # $100, 10% discount
    assert result == 90.0
```

### 3. Verify Both Lanes

```bash
./scripts/verify-both.sh
```

**Output:**
```
✅ AS-IS: All tests passed
✅ TO-BE: All tests passed
✅ Both lanes verified
```

## 🧪 TDD Red/Green/Refactor Cycle

### 1. RED (Write Failing Test)

```bash
# Write test in shared-tests/
cat > shared-tests/test_new_feature.py << 'EOF'
def test_new_feature():
    result = my_new_function(42)
    assert result == 84  # Double input
EOF

# Run in both lanes (expect failure)
./scripts/verify-both.sh
```

**Output:**
```
❌ AS-IS: FAILED (function doesn't exist)
❌ TO-BE: FAILED (function doesn't exist)
```

### 2. GREEN (Implement in Both Lanes)

```bash
# Implement in AS-IS
cat > lanes/asis/my_module.py << 'EOF'
def my_new_function(x):
    return x * 2
EOF

# Implement in TO-BE (better architecture)
cat > lanes/tobe/my_module.py << 'EOF'
class Calculator:
    def multiply(self, x, factor=2):
        return x * factor

def my_new_function(x):
    calc = Calculator()
    return calc.multiply(x, 2)
EOF

# Run tests (expect success)
./scripts/verify-both.sh
```

**Output:**
```
✅ AS-IS: All tests passed
✅ TO-BE: All tests passed
```

### 3. REFACTOR (Improve TO-BE Only)

```bash
# Improve TO-BE without breaking tests
cat > lanes/tobe/my_module.py << 'EOF'
class Calculator:
    def __init__(self):
        self._multipliers = {2: self._double}

    def _double(self, x):
        return x * 2

    def multiply(self, x, factor=2):
        multiplier = self._multipliers.get(factor, lambda y: y * factor)
        return multiplier(x)

def my_new_function(x):
    calc = Calculator()
    return calc.multiply(x, 2)
EOF

# Verify (only TO-BE should still pass)
./scripts/verify-both.sh
```

**Output:**
```
✅ AS-IS: All tests passed
✅ TO-BE: All tests passed
```

## 🔄 Lane Switching

### Set Active Lane

```bash
# Switch to TO-BE for development
./scripts/switch-lane.sh tobe

# Now all edits go to TO-BE
vim lanes/tobe/my_module.py

# Switch back to AS-IS
./scripts/switch-lane.sh asis
```

### Compare Lanes

```bash
# See what changed between implementations
./scripts/diff-lanes.sh my_module.py
```

**Output:**
```
lanes/asis/my_module.py vs lanes/tobe/my_module.py
@@ -1,3 +1,15 @@
-def my_new_function(x):
-    return x * 2
+class Calculator:
+    def __init__(self):
+        self._multipliers = {2: self._double}
+
+    def _double(self, x):
+        return x * 2
+
+    def multiply(self, x, factor=2):
+        multiplier = self._multipliers.get(factor, lambda y: y * factor)
+        return multiplier(x)
+
+def my_new_function(x):
+    calc = Calculator()
+    return calc.multiply(x, 2)
```

## 🎓 Integration with Installed Skills

### clean-pytest (Fakes + AAA Pattern)

```python
# shared-tests/test_contract.py
import pytest
from tests.fakes import FakeDatabase

@pytest.fixture
def fake_db():
    return FakeDatabase()

def test_user_creation(fake_db):
    # Arrange
    user_data = {"email": "test@example.com", "name": "Test User"}

    # Act
    result = create_user(user_data, db=fake_db)

    # Assert
    assert result["status"] == "ok"
    assert fake_db.users_count() == 1
```

### agent-browser (UI Testing)

```bash
# Test AS-IS UI
agent-browser --session asis open http://localhost:3000
agent-browser --session asis snapshot -i
agent-browser --session asis click @e1
agent-browser --session asis wait --text "Success"

# Test TO-BE UI (in parallel)
agent-browser --session tobe open http://localhost:3001
agent-browser --session tobe snapshot -i
agent-browser --session tobe click @e1
agent-browser --session tobe wait --text "Success"
```

### test-patterns (TDD Workflow)

```bash
# Watch mode for AS-IS
cd lanes/asis && pytest -x --watch

# Watch mode for TO-BE (in parallel)
cd lanes/tobe && pytest -x --watch
```

## 🧱 Parallel Dev Sessions

### Alternative: Side-by-Side Dev

```bash
# Terminal 1: Work on AS-IS
cd ~/.openclaw/workspace-dev/2lane-tdd/lanes/asis
vim my_module.py
pytest -x --watch

# Terminal 2: Work on TO-BE (simultaneously)
cd ~/.openclaw/workspace-dev/2lane-tdd/lanes/tobe
vim my_module.py
pytest -x --watch

# Terminal 3: Run shared tests
cd ~/.openclaw/workspace-dev/2lane-tdd
./scripts/verify-both.sh
```

### Using Sub-Agent Sessions

```bash
# Spawn sub-agent for TO-BE development
openclaw spawn "Refactor my_module with better architecture" --session tobe

# Continue working on AS-IS in main session
# Sub-agent will report back when TO-BE is ready

# Verify both lanes when ready
./scripts/verify-both.sh
```

## 📊 Migration from AS-IS to TO-BE

### When TO-BE is Production-Ready

1. **Verify Tests Pass**: `./scripts/verify-both.sh`
2. **Compare Behavior**: `./scripts/diff-lanes.sh` (review differences)
3. **Stress Test**: Run integration tests on both
4. **Deploy TO-BE**: Replace AS-IS with TO-BE
5. **Archive AS-IS**: Move to `lanes/archive/asis-v1.0/`
6. **Reset**: Copy TO-BE to new AS-IS lane

```bash
# Migration checklist
./scripts/migration-checklist.sh
```

## 🛠️ Scripts

### verify-both.sh

Run tests in both lanes and report status.

```bash
./scripts/verify-both.sh [--verbose]
```

### diff-lanes.sh

Compare implementations between lanes.

```bash
./scripts/diff-lanes.sh <filename>
```

### switch-lane.sh

Toggle active lane for development.

```bash
./scripts/switch-lane.sh [asis|tobe]
```

## ✅ Best Practices

1. **Write Tests First**: Always start with RED (failing test)
2. **Keep Tests Green**: Never commit failing tests
3. **Refactor Continuously**: Improve TO-BE while keeping tests green
4. **Compare Lanes**: Regularly review differences with `diff-lanes.sh`
5. **Shared Contracts**: All tests in `shared-tests/` must pass in BOTH lanes
6. **Separate Concerns**: AS-IS = stable, TO-BE = experimental
7. **Parallel Dev**: Use multiple terminals or sub-agents for speed
8. **Continuous Verification**: Run `verify-both.sh` after every significant change

## 📚 Related Skills

- **clean-pytest**: Fake-based testing, AAA pattern
- **test-patterns**: TDD workflow, coverage, debugging
- **agent-browser**: UI testing across lanes

---

**Location**: `~/.openclaw/workspace-dev/2lane-tdd/`
**Status**: ✅ Ready to use
