# Smart-Finance-AI Automated Testing Suite

This repository contains the complete automated test project for **Smart-Finance-AI-main**, covering 4 core categories:

1. **Appium Mobile Automation Test Cases**
2. **Selenium Web Automation Test Cases**
3. **Vulnerability / Security Test Cases**
4. **300 Unique Load / Performance Test Cases**

---

## 📁 Directory Structure

```
tests/
  ├── appium/            # Mobile automation Page Object Models & pytest scripts
  ├── selenium/          # Web UI automation Page Object Models & pytest scripts
  ├── vulnerability/     # Header, XSS, SQLi, IDOR & auth security tests
  └── load/              # 300 unique load test scenarios (JSON, Locust, k6)
.github/workflows/       # Automated CI/CD GitHub Action pipeline YAML files
config/                  # Environment, Appium, Selenium & Load configuration JSONs
reports/                 # Master CSV matrix & generated HTML test reports
scripts/                 # Automation & packaging scripts
requirements.txt         # Python dependencies
```

---

## 🚀 Quickstart & Running Tests Locally

### Prerequisites
- Python 3.10+
- Node.js & npm (for Appium & k6)

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Generate Scenarios & Master CSV Matrix
```bash
python scripts/generate_load_scenarios.py
```

### 3. Run All Test Suites
```bash
pytest tests/ --html=reports/master_test_report.html --self-contained-html
```

### 4. Run Specific Categories
- **Appium Mobile Tests**: `pytest tests/appium/`
- **Selenium Web Tests**: `pytest tests/selenium/`
- **Security Tests**: `pytest tests/vulnerability/`
- **Load Test Verification**: `pytest tests/load/`

### 5. Run Locust Load Engine
```bash
locust -f tests/load/locustfile.py --host=http://localhost:49390
```

### 6. Build Downloadable ZIP Artifact
```bash
python scripts/package_test_zip.py
```

---

## 📊 Reports & Master Matrix

The test framework produces:
- `reports/master_test_cases.csv`: Full spreadsheet listing all 320 test cases with ID, Category, Step Details, Expected Results, Priority, and Status.
- `reports/master_test_report.html`: Comprehensive HTML execution report with step details.
