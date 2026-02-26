# OSS Test Suite - Complete Setup Guide

## ✅ Status: Ready to Test

Your TestSprite-style OSS testing framework is now set up at `~/.openclaw/workspace-dev/oss-test-suite/`

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd ~/.openclaw/workspace-dev/oss-test-suite

# Web UI Testing (LaVague QA)
pip install lavague-qa pytest-bdd selenium

# API Testing (LangChain-based)
pip install langchain openai pytest

# Core Test Runner
pip install pytest pytest-html
```

### 2. Generate AI Test Plans

```bash
# Ensure VibeProxy is running (port 8318)
cd ~/.openclaw/workspace-dev/oss-test-suite
python scripts/generate_test_plans.py

# Output: output/test-plans/*.md
```

### 3. Run Tests

```bash
# All tests
pytest

# Web UI tests only
pytest web/ -v

# API tests only
pytest api/ -v

# With HTML report
pytest --html=report.html
```

## 📁 Project Structure

```
oss-test-suite/
├── .github/workflows/test.yml    # CI/CD pipeline (GitHub Actions)
├── api/                          # API testing (AI-driven)
│   └── test_ai_agent.py         # Example API test
├── web/                          # Web UI testing (LaVague QA)
│   └── features/                # Gherkin feature files
│       └── login.feature        # Example login flow
├── specs/                        # Natural language specifications
│   ├── mission-control-api.txt  # API spec for health endpoint
│   └── mission-control-login.txt # Web UI login spec
├── scripts/                      # Utility scripts
│   └── generate_test_plans.py   # AI test plan generator
├── infra/                        # Infrastructure
│   └── docker-compose.yml       # Local services (optional)
└── pytest.ini                   # Pytest configuration
```

## 🧪 Test Types

### 1. Web UI Testing (LaVague QA)

**How it works:**
1. Write Gherkin `.feature` files in `web/features/`
2. LaVague QA generates Selenium tests from `.feature` files
3. Run with standard `pytest`

**Example:**
```gherkin
Feature: Mission Control Login
  Scenario: Successful login
    Given I am on "http://localhost:3000/login"
    When I enter "admin" in the username field
    Then I should see "Welcome, Admin"
```

### 2. API Testing (AI Testing Agent)

**How it works:**
1. Write natural language specs in `specs/`
2. AI generates comprehensive test plans
3. Test plans can be converted to pytest code

**Example:**
```python
def test_health_endpoint():
    response = requests.get("http://localhost:8000/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
```

## 🔧 Configuration

### Local AI Models (Optional)

For AI-driven test planning, configure local models:

```bash
# Start VibeProxy (for reasoning)
# Edit ~/.cli-proxy-api/config.yaml to enable zai/glm-4.7

# Start Ollama (for embeddings)
ollama serve

# Set environment variables
export VIBEPROXY_BASE_URL="http://localhost:8318/v1"
export VIBEPROXY_API_KEY="local-token"
export VIBEPROXY_MODEL="zai/glm-4.7"
```

### GitHub Actions CI/CD

The workflow in `.github/workflows/test.yml` will:

1. Run Web UI tests in isolated environment
2. Run API tests with Postgres service
3. Generate AI test plans
4. Upload test artifacts

## 📊 Test Reports

### HTML Report
```bash
pytest --html=report.html --self-contained-html
```

### Coverage Report
```bash
pytest --cov=. --cov-report=html
```

## 🔗 Integrations

### With Mission Control

```bash
# Test Mission Control API
pytest api/test_ai_agent.py

# Test Mission Control Web UI
pytest web/features/
```

### With OpenClaw

```bash
# Test OpenClaw Gateway endpoints
pytest api/test_gateway.py
```

## 📚 Next Steps

1. **Add More Specs**: Create `.txt` files in `specs/` for new features
2. **Generate Tests**: Run `scripts/generate_test_plans.py`
3. **Write Gherkin Features**: Add `.feature` files to `web/features/`
4. **Configure CI**: Push to GitHub to trigger automated tests
5. **Customize**: Modify `pytest.ini` for your project needs

## 🐛 Troubleshooting

### Selenium Driver Issues
```bash
# Install ChromeDriver
brew install chromedriver

# Or use geckodriver for Firefox
brew install geckodriver
```

### VibeProxy Connection Failed
```bash
# Check VibeProxy status
curl http://localhost:8318/health

# Restart if needed
openclaw gateway restart
```

### Ollama Connection Failed
```bash
# Check Ollama status
curl http://localhost:11434/api/tags

# Restart if needed
ollama serve
```

## 💡 Tips

- **Start Small**: Test one endpoint or page at a time
- **Use Natural Language**: Write specs that describe the user journey
- **Leverage AI**: Let the AI agent generate test plans for complex scenarios
- **Run Locally First**: Always test locally before pushing to CI
- **Keep Tests Fast**: Mock external services when possible

## 📞 Support

- **LaVague QA Docs**: https://github.com/lavague-ai/LaVague
- **LangChain Docs**: https://python.langchain.com/
- **Pytest Docs**: https://docs.pytest.org/

---

**Generated**: 2026-02-25
**Framework**: TestSprite-style OSS
**Status**: ✅ Ready to Test
