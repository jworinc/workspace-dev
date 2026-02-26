# OSS Test Suite (TestSprite-style)

This repository provides a self-hosted, local-first AI testing framework for Web UIs and HTTP APIs, mimicking the TestSprite workflow without the cloud dependency.

## Architecture

| Component | Tool | Responsibility |
| :--- | :--- | :--- |
| **Web UI Testing** | [LaVague QA](https://github.com/lavague-ai/LaVague) | Natural language specs $\rightarrow$ Pytest-BDD/Selenium |
| **API Testing** | AI Testing Agent | LangChain-based autonomous endpoint validation |
| **Core Runner** | `pytest` | Unified test execution and reporting |
| **CI/CD** | GitHub Actions | Local-to-Remote pipeline orchestration |

## Directory Structure

```
.
├── api/                # AI-driven API tests
│   ├── conftest.py
│   └── test_endpoints.py
├── web/                # Natural language Web UI tests
│   ├── features/       # Gherkin .feature files
│   └── test_flows.py   # LaVague-generated selenium code
├── infra/              # Shared configuration and local runners
│   └── docker-compose.yml
└── pytest.ini          # Global pytest configuration
```

## Getting Started

### 1. Prerequisites
- Python 3.14+
- `export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1`
- VibeProxy (for reasoning)
- Ollama (for embeddings)

### 2. Installation
```bash
pip install lavague-qa langchain pytest pytest-bdd selenium
```

### 3. Running Tests
```bash
pytest web/
pytest api/
```
