# 🚀 2-Lane TDD - Quick Start Guide

## ✅ Status: READY TO USE!

Your 2-lane TDD framework is set up and **already working** with a calculator example!

## 📊 Current Status

```
✅ Scripts: verify-both.sh, diff-lanes.sh, switch-lane.sh (executable)
✅ Tests: 13 tests passing in BOTH lanes (asis + tobe)
✅ Example: Calculator implemented in both lanes
✅ Skills: clean-pytest, agent-browser, test-patterns, ai-api-test installed
```

## 🎯 Try It Now (30 Seconds)

### 1. Run Verification (Both Lanes)

```bash
cd ~/.openclaw/workspace-dev/2lane-tdd
./scripts/verify-both.sh
```

**Output:**
```
🧪 2-Lane TDD Verification
================================
Testing asis lane...
.............                            [100%]
13 passed in 0.01s
✅ asis: All tests passed

Testing tobe lane...
.............                            [100%]
13 passed in 0.00s
✅ tobe: All tests passed

================================
✅ Both lanes verified successfully!
```

### 2. See Differences Between Lanes

```bash
./scripts/diff-lanes.sh calculator.py
```

**You'll see:**
- **AS-IS**: Simple functions (18 lines)
- **TO-BE**: Calculator class with history (62 lines)

### 3. Switch Lanes

```bash
./scripts/switch-lane.sh asis     # Work on AS-IS
./scripts/switch-lane.sh tobe     # Work on TO-BE
./scripts/switch-lane.sh current   # Show current lane
```

### 4. Jump to Active Lane

```bash
cd $(./scripts/switch-lane.sh --path)
vim calculator.py
```

## 📁 Project Structure

```
2lane-tdd/
├── lanes/
│   ├── asis/
│   │   └── calculator.py         # Simple implementation (18 lines)
│   └── tobe/
│       └── calculator.py         # Refactored with history (62 lines)
├── shared-tests/
│   ├── conftest.py              # Pytest config (auto-switches lanes)
│   └── test_calculator.py       # 13 contract tests
├── scripts/
│   ├── verify-both.sh            # ✅ Run tests in both lanes
│   ├── diff-lanes.sh            # ✅ Compare implementations
│   └── switch-lane.sh          # ✅ Toggle active lane
├── docs/
│   └── TDD-WORKFLOW.md         # Detailed TDD guide (13KB)
└── README.md                   # Project overview
```

## 🧪 TDD Red/Green/Refactor Example

### Step 1: RED (Write Failing Test)

```bash
cat > shared-tests/test_power.py << 'EOF'
import pytest
from calculator import power

def test_power():
    result = power(2, 3)
    assert result == 8
EOF

./scripts/verify-both.sh
```

**Expected:**
```
❌ AS-IS: FAILED (power function doesn't exist)
❌ TO-BE: FAILED (power function doesn't exist)
```

### Step 2: GREEN (Implement in Both Lanes)

```bash
# AS-IS implementation
cat >> lanes/asis/calculator.py << 'EOF'

def power(a, b):
    """Calculate a to the power of b"""
    return a ** b
EOF

# TO-BE implementation (better)
cat >> lanes/tobe/calculator.py << 'EOF'

def power(a, b, calculator=_default_calculator):
    """Calculate power (wrapper)"""
    result = a ** b
    calculator._record_operation("power", a, b, result)
    return result
EOF

./scripts/verify-both.sh
```

**Expected:**
```
✅ AS-IS: All tests passed
✅ TO-BE: All tests passed
```

### Step 3: REFACTOR (Improve TO-BE Only)

```bash
# Refactor with better error handling
cat > lanes/tobe/calculator.py << 'EOF'
class Calculator:
    # ... (keep existing code)

    def power(self, a, b):
        """Calculate a to the power of b with validation"""
        if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
            raise TypeError("Operands must be numbers")
        if a < 0 and not b.is_integer():
            raise ValueError("Complex numbers not supported")

        result = a ** b
        self._record_operation("power", a, b, result)
        return result

def power(a, b):
    """Power function (wrapper)"""
    return _default_calculator.power(a, b)
EOF

./scripts/verify-both.sh
```

## 🔄 Parallel Development Workflows

### Option 1: Multiple Terminals

```bash
# Terminal 1: AS-IS
cd ~/.openclaw/workspace-dev/2lane-tdd
./scripts/switch-lane.sh asis
cd $(./scripts/switch-lane.sh --path)
python3 -m pytest shared-tests/ -x --watch

# Terminal 2: TO-BE
cd ~/.openclaw/workspace-dev/2lane-tdd
./scripts/switch-lane.sh tobe
cd $(./scripts/switch-lane.sh --path)
python3 -m pytest shared-tests/ -x --watch

# Terminal 3: Verify Both
cd ~/.openclaw/workspace-dev/2lane-tdd
watch -n 5 './scripts/verify-both.sh'
```

### Option 2: Sub-Agent Sessions

```bash
# Main session: Work on AS-IS
cd ~/.openclaw/workspace-dev/2lane-tdd
./scripts/switch-lane.sh asis
cd $(./scripts/switch-lane.sh --path)
vim calculator.py

# Spawn sub-agent for TO-BE
sessions_spawn \
  --task "Refactor calculator with history tracking and validation" \
  --mode session \
  --label "tobe-refactor"

# Sub-agent will report back when ready
```

### Option 3: Side-by-Side Dev (3+ Lanes)

```bash
# Create more lanes
mkdir -p lanes/alt1 lanes/alt2

# Copy current code to new lanes
cp -r lanes/tobe/* lanes/alt1/
cp -r lanes/asis/* lanes/alt2/

# Implement different approaches in each lane
# alt1: OOP approach
# alt2: Functional approach
# asis: Simple approach
# tobe: Architecture approach

# Test all lanes
for lane in asis tobe alt1 alt2; do
    echo "Testing lane: $lane"
    export LANE=$lane
    python3 -m pytest shared-tests/
done
```

## 🎓 Skill Integration Examples

### clean-pytest (Fakes + AAA Pattern)

```python
# shared-tests/test_calculator.py
import pytest
from calculator import Calculator
from tests.fakes import FakeHistoryStorage

@pytest.fixture
def fake_storage():
    """Fake storage (no real DB)"""
    return FakeHistoryStorage()

def test_calculator_saves_history(fake_storage):
    # Arrange - Create calculator with fake storage
    calc = Calculator(storage=fake_storage)
    calc.add(2, 3)

    # Act - Check history
    history = calc.get_history()

    # Assert - Verify storage was called
    assert len(history) == 1
    assert fake_storage.save_count == 1
```

### agent-browser (UI Testing)

```bash
# Test AS-IS UI
agent-browser --session asis open http://localhost:3000
agent-browser --session asis snapshot -i
agent-browser --session asis fill @e1 "5"
agent-browser --session asis fill @e2 "3"
agent-browser --session asis click @e3  # Add button
agent-browser --session asis wait --text "8"

# Test TO-BE UI
agent-browser --session tobe open http://localhost:3001
# Same flow, verify same result
```

### test-patterns (Parametrized Tests)

```python
# shared-tests/test_calculator.py
@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (-1, -2, -3),
    (0, 0, 0),
    (100, -50, 50),
])
def test_add_various_inputs(a, b, expected):
    result = add(a, b)
    assert result == expected
```

### ai-api-test (API Contract Testing)

```python
# shared-tests/test_api.py
import requests

def test_calculator_api_consistency():
    """Ensure both APIs return same results"""
    asis = requests.get("http://localhost:8000/add?a=2&b=3").json()
    tobe = requests.get("http://localhost:8001/add?a=2&b=3").json()

    assert asis["result"] == tobe["result"]
    assert asis["result"] == 5
```

## 📊 What Makes This Special

### 1. Contract Testing
- **Same tests run in both lanes**
- **Guarantees behavior compatibility**
- **Catch regressions immediately**

### 2. Refactor Safety
- **AS-IS stays stable**
- **TO-BE experiments safely**
- **Rollback is instant**

### 3. Parallel Development
- **Work on both lanes simultaneously**
- **Or use sub-agents for parallel AI work**
- **Faster delivery without breaking things**

### 4. Skill Integration
- **clean-pytest**: AAA pattern, fakes
- **agent-browser**: UI testing
- **test-patterns**: Parametrization, coverage
- **ai-api-test**: API contracts

## 🎯 Common Workflows

### "I want to refactor this function"
```bash
# 1. Write tests first (RED)
cat > shared-tests/test_refactor.py << 'EOF'
def test_old_behavior():
    # Describe current behavior
    assert my_function(1, 2) == 3

def test_new_feature():
    # Describe desired behavior
    assert my_function(1, 2, extra=True) == 4
EOF

# 2. Implement in AS-IS (minimal)
# 3. Implement in TO-BE (refactored)
# 4. Verify both: ./scripts/verify-both.sh
```

### "I want to try 3 different implementations"
```bash
# 1. Create 3 lanes
mkdir -p lanes/option1 lanes/option2 lanes/option3

# 2. Copy tests (same for all)
cp -r shared-tests/* lanes/option1/tests/
cp -r shared-tests/* lanes/option2/tests/
cp -r shared-tests/* lanes/option3/tests/

# 3. Implement different approaches
# option1: OOP
# option2: Functional
# option3: Procedural

# 4. Test all
for lane in option1 option2 option3; do
    cd lanes/$lane
    python3 -m pytest tests/ -v
done
```

### "I want to migrate from AS-IS to TO-BE"
```bash
# 1. Ensure both lanes pass
./scripts/verify-both.sh

# 2. Compare differences
./scripts/diff-lanes.sh calculator.py --summary

# 3. Stress test TO-BE
python3 -m pytest shared-tests/ --cov=. --cov-report=html

# 4. If all good, replace AS-IS
rm -rf lanes/asis
cp -r lanes/tobe lanes/asis

# 5. Start new TO-BE
```

## 📚 Next Steps

1. **Explore the example**: `ls lanes/asis/ lanes/tobe/`
2. **Read the tests**: `cat shared-tests/test_calculator.py`
3. **Try TDD cycle**: Add `power()` function following RED/GREEN/REFACTOR
4. **Integrate with your project**: Copy your code to both lanes
5. **Add more lanes**: Try different implementations side-by-side

## 📞 Documentation

- **`README.md`** - Project overview
- **`docs/TDD-WORKFLOW.md`** - Detailed TDD guide (13KB)
- **`docs/MIGRATION-GUIDE.md`** - Migrating AS-IS to TO-BE (coming soon)

---

**Location**: `~/.openclaw/workspace-dev/2lane-tdd/`
**Status**: ✅ Ready to use
**Tests**: 13 passing (both lanes)
**Skills**: 4 integrated (clean-pytest, agent-browser, test-patterns, ai-api-test)
