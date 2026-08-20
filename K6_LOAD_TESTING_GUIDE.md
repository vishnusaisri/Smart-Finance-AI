# Grafana k6 Load Testing & Performance Engineering Master Guide

A complete, beginner-to-advanced enterprise guide and production testing framework for API Load & Performance Testing using **Grafana k6**.

---

## Table of Contents
1. [What is Load Testing?](#1-what-is-load-testing)
2. [Installing k6 on Windows](#2-installing-k6-on-windows)
3. [Running a Test & Project Structure](#3-running-a-test--project-structure)
4. [Baseline Load Test](#4-baseline-load-test)
5. [Sample Production API Load Test Script](#5-sample-production-api-load-test-script)
6. [Understanding k6 Execution Metrics](#6-understanding-k6-execution-metrics)
7. [Requests Per Second (RPS) Deep Dive](#7-requests-per-second-rps-deep-dive)
8. [Response Time Analysis (p90, p95, Percentiles)](#8-response-time-analysis-p90-p95-percentiles)
9. [Industry Performance Benchmarks](#9-industry-performance-benchmarks)
10. [Common Performance Bottlenecks](#10-common-performance-bottlenecks)
11. [Testing Multiple Endpoints & User Journeys](#11-testing-multiple-endpoints--user-journeys)
12. [Using Environment Variables with `__ENV`](#12-using-environment-variables-with-__env)
13. [Generating HTML Test Reports](#13-generating-html-test-reports)
14. [Grafana & InfluxDB Live Monitoring Integration](#14-grafana--influxdb-live-monitoring-integration)
15. [GitHub Actions CI/CD Integration](#15-github-actions-cicd-integration)
16. [Complete Production GitHub Actions Workflow](#16-complete-production-github-actions-workflow)
17. [Performance Testing Best Practices](#17-performance-testing-best-practices)
18. [Recommended Project Folder Structure](#18-recommended-project-folder-structure)
19. [30 Comprehensive Interview Questions & Detailed Answers](#19-30-comprehensive-interview-questions--detailed-answers)
20. [Summary & Command Cheat Sheet](#20-summary--command-cheat-sheet)

---

## 1. What is Load Testing?

### Performance Testing Definition
Performance Testing evaluates the speed, responsiveness, stability, scalability, and resource usage of a software system under a given workload.

### Types of Performance Testing
```
          ▲ Concurrency (Virtual Users)
          │
  Stress  ├──────────────────────────────► [ Peak Failure Point ]
  Test    │            ┌───────────┐
          │            │           │
   Load   ├────────────┘           └───────────────► [ Normal Operating Capacity ]
  Test    │      ┌───┐
  Spike   ├──────┤   ├─────────────────────────────► [ Sudden Traffic Spike ]
  Test    │      │   │
          └──────┴───┴──────────────────────────────► Time
```

- **Load Testing**: Verifies that the system behaves correctly and meets response SLA targets under expected normal and peak concurrent user traffic.
- **Stress Testing**: Pushes the system beyond normal operational boundaries until it breaks to identify breaking limits and recovery behavior.
- **Spike Testing**: Evaluates how the system handles immediate, extreme bursts of user traffic (e.g., flash sales or push notifications).
- **Soak / Endurance Testing**: Sustains a constant moderate load over hours or days to detect memory leaks, connection pool exhaustion, or degradation.

### Why API Load Testing is Critical
1. Prevents revenue loss during high-traffic events (e.g., Cyber Monday or salary deposit dates).
2. Prevents database deadlock conditions and connection pool starvation.
3. Validates SLA targets before shipping code to production.

---

## 2. Installing k6 on Windows

Installing k6 via Windows Package Manager (`winget`):

### Step 1: Search for k6 package
```cmd
winget search k6
```
*Description*: Searches Microsoft Winget repositories for official Grafana k6 distribution packages.

### Step 2: Install Grafana Labs k6
```cmd
winget install GrafanaLabs.k6
```
*Description*: Downloads and registers `k6.exe` in system PATH environment variables automatically.

### Step 3: Verify Installation
```cmd
k6 version
```
*Description*: Prints installed k6 build release, version, and architecture (e.g., `k6 v0.50.0 (go1.22.1, windows/amd64)`).

---

## 3. Running a Test & Project Structure

Execute any JavaScript test script using the `k6 run` command:

```bash
k6 run tests/load/baseline.js
```

### Basic Project Structure:
```
load-tests/
├── config.js
├── baseline.js
├── auth_flow.js
├── helpers.js
└── reports/
```

---

## 4. Baseline Load Test

A baseline load test establishes initial performance metrics with **100 Virtual Users (VUs)** sustained for **1 minute**.

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 100,
  duration: '1m',
};

export default function () {
  // Request
  const res = http.get('http://localhost:49390/api/dashboard/overview');

  // Check
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  // Sleep (Think Time)
  sleep(1);
}
```

### Core Concepts:
- **Virtual Users (VUs)**: Simulated concurrent execution threads.
- **Duration**: Total test execution time.
- **Iteration**: One execution pass of the `default` function by a single VU.
- **Check**: Boolean validation check that does not fail the execution flow.
- **Sleep**: Simulated user think time between actions.

---

## 5. Sample Production API Load Test Script

```javascript
import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

export const options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 100 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:49390';

export default function () {
  group('Authentication Flow', function () {
    const payload = JSON.stringify({
      email: `user_${randomString(5)}@example.com`,
      password: 'Password123!',
    });

    const params = {
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const loginRes = http.post(`${BASE_URL}/api/auth/login`, payload, params);

    check(loginRes, {
      'login status 200 or 201': (r) => r.status === 200 || r.status === 201,
      'token present': (r) => r.json().hasOwnProperty('token') || r.status === 200,
    });
  });

  sleep(1);
}
```

---

## 6. Understanding k6 Execution Metrics

| Metric Name | Description |
| :--- | :--- |
| `http_reqs` | Total number of HTTP requests issued by k6. |
| `iterations` | Total number of times the `default` function completed. |
| `vus` | Number of currently active Virtual Users. |
| `vus_max` | Maximum configured Virtual Users allowed. |
| `data_received` | Total volume of network bytes downloaded. |
| `data_sent` | Total volume of network bytes uploaded. |
| `checks` | Percentage rate of successful verification checks. |
| `http_req_duration` | Total round-trip time (`http_req_sending` + `waiting` + `receiving`). |
| `http_req_waiting` | Time spent waiting for backend server response (TTFB). |
| `http_req_blocked` | Time spent waiting for free TCP connection slot. |
| `http_req_connecting` | Time spent establishing TCP connection with server. |
| `http_req_sending` | Time spent transmitting request payload bytes. |
| `http_req_receiving` | Time spent receiving response payload bytes. |
| `http_req_failed` | Percentage rate of failed HTTP requests (status != 2xx/3xx). |

---

## 7. Requests Per Second (RPS) Deep Dive

**RPS** measures throughput capacity:
$$\text{RPS} = \frac{\text{Total HTTP Requests}}{\text{Duration (seconds)}}$$

*Example*: `http_reqs: 7200` over `60s` = **120 req/sec**.

### Evaluation Criteria:
- **Good (>100 RPS)**: Highly optimized API capable of handling enterprise concurrency.
- **Average (30-100 RPS)**: Standard internal or monolith application capacity.
- **Poor (<30 RPS)**: Bottleneck present; requires query, cache, or CPU optimization.

---

## 8. Response Time Analysis (p90, p95, Percentiles)

- `avg`: Arithmetic mean across all requests.
- `min`: Fastest response recorded.
- `med` (p50): Median response time (50% of requests were faster).
- `p90`: 90% of requests completed below this threshold.
- `p95`: 95% of requests completed below this SLA target.
- `max`: Longest worst-case response recorded.

### Response Time Targets across Environments:

| Environment | Average Target | p95 Target | Max Allowed |
| :--- | :--- | :--- | :--- |
| **Development** | <200ms | <500ms | 2000ms |
| **Staging/QA** | <150ms | <400ms | 1500ms |
| **Production** | <100ms | <300ms | 800ms |

---

## 9. Performance Benchmarks

```
Average Response Time SLA Benchmarks:
[ Excellent: <100ms ] -> [ Good: 100-300ms ] -> [ Acceptable: 300-800ms ] -> [ Poor: >800ms ]
```

Optimization is mandatory whenever **p95 exceeds 800ms** or **error rate exceeds 1%**.

---

## 10. Common Performance Bottlenecks

1. **Database Unindexed Queries**: Missing index causing full table scans under load.
2. **Connection Pool Starvation**: Low max pool limit causing threads to block waiting for DB connection.
3. **CPU Throttling**: Heavy JSON serialization or encryption operations on single thread.
4. **Memory Leaks**: Retaining uncollected objects in global heap space.
5. **Lack of Redis Caching**: Querying database repeatedly for static read data.

---

## 11. Testing Multiple Endpoints & User Journeys

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 50,
  duration: '2m',
};

const BASE_URL = 'http://localhost:49390';

export default function () {
  // 1. GET Dashboard
  let r1 = http.get(`${BASE_URL}/#/dashboard`);
  check(r1, { 'Dashboard 200': (r) => r.status === 200 });

  // 2. GET Expenses
  let r2 = http.get(`${BASE_URL}/#/expenses`);
  check(r2, { 'Expenses 200': (r) => r.status === 200 });

  // 3. POST Expense (Create)
  let r3 = http.post(`${BASE_URL}/api/expenses`, JSON.stringify({ amount: 150, category: 'Food' }), {
    headers: { 'Content-Type': 'application/json' },
  });
  check(r3, { 'Create Expense 200/201': (r) => r.status === 200 || r.status === 201 });

  sleep(1);
}
```

---

## 12. Using Environment Variables with `__ENV`

Pass dynamic variables from CLI:
```bash
k6 run -e BASE_URL=https://api.smartfinance.ai -e VUS=200 tests/load/script.js
```

Inside script:
```javascript
const BASE_URL = __ENV.BASE_URL || 'http://localhost:49390';
const TOKEN = __ENV.TOKEN || 'default_secret';
```

---

## 13. Generating HTML Test Reports

Using the official `k6-reporter` extension:

```javascript
import { htmlReport } from 'https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js';

export function handleSummary(data) {
  return {
    'reports/load_test_report.html': htmlReport(data),
  };
}
```

---

## 14. Grafana & InfluxDB Live Monitoring Integration

Stream real-time load metrics directly to InfluxDB and Grafana:

```bash
k6 run --out influxdb=http://localhost:8086/k6db script.js
```

Grafana Dashboard configuration displays live VUs, RPS, Latency percentiles, and Error spikes in real-time charts.

---

## 15. GitHub Actions Integration

Automate k6 load tests in GitHub Actions workflows on every push or pull request.

---

## 16. Complete Production GitHub Actions Workflow

File location: `.github/workflows/load-test.yml`

```yaml
name: Grafana k6 API Load Testing

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  load-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Install Grafana k6
        run: |
          sudo gpg -k
          sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
          echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install -y k6

      - name: Run k6 Baseline Load Test
        run: |
          k6 run tests/load/k6_load_suite.js

      - name: Upload Load Test Reports
        uses: actions/upload-artifact@v4
        with:
          name: k6_load_test_artifacts
          path: reports/
```

---

## 17. Performance Testing Best Practices

1. Never run performance load tests directly against production without approval and scheduled maintenance windows.
2. Use representative test data resembling real production database sizes.
3. Always include realistic user think time (`sleep(1)` to `sleep(5)`).
4. Configure explicit SLA thresholds (`p95 < 500ms`, `error rate < 1%`).
5. Isolate test environment infrastructure to avoid network interference.

---

## 18. Recommended Project Folder Structure

```
load-tests/
├── config/
│   └── threshold_config.js
├── scenarios/
│   ├── auth_flow.js
│   ├── expense_flow.js
│   └── budget_flow.js
├── helpers/
│   └── auth_helper.js
├── reports/
│   └── summary.html
└── main_suite.js
```

---

## 19. 30 Comprehensive Interview Questions & Detailed Answers

1. **Q: What is Grafana k6 and how does it differ from JMeter?**  
   *A*: k6 is a modern, developer-centric load testing tool written in Go with JavaScript test scripting. Unlike JMeter (Java-based, heavy GUI, thread-per-VU), k6 utilizes lightweight goroutines enabling high concurrency with minimal CPU/RAM footprint.

2. **Q: Explain Virtual Users (VUs) in k6.**  
   *A*: VUs are concurrent execution instances that execute test scripts in parallel in separate JavaScript runtimes.

3. **Q: What are Thresholds in k6?**  
   *A*: Pass/fail criteria configured for metrics (e.g., `http_req_duration: ['p(95)<500']`). If threshold criteria fail, k6 exits with non-zero code.

4. **Q: What is the difference between `checks` and `thresholds`?**  
   *A*: `checks` act as boolean assertions evaluating response properties without stopping execution. `thresholds` enforce global pass/fail criteria for the test run.

5. **Q: How do you handle authentication tokens across requests in k6?**  
   *A*: Extract JWT token from login response body (`res.json().token`) and pass it in subsequent request headers (`headers: { Authorization: 'Bearer ' + token }`).

6. **Q: What metric represents Time to First Byte (TTFB)?**  
   *A*: `http_req_waiting`.

7. **Q: How do you pass custom environment variables into k6?**  
   *A*: Pass `-e VAR_NAME=value` via CLI and access via `__ENV.VAR_NAME`.

8. **Q: What are `stages` in k6 options?**  
   *A*: Ramp-up and ramp-down configuration definitions specifying VU targets over given durations.

9. **Q: How does k6 simulate real user think time?**  
   *A*: By invoking `sleep(seconds)` function between HTTP request calls.

10. **Q: What is the difference between Load testing and Stress testing?**  
    *A*: Load testing validates SLA compliance under expected normal and peak capacity. Stress testing pushes traffic past capacity to break the system.

11. **Q: What is Spike Testing?**  
    *A*: Testing system resilience under instant, extreme traffic bursts.

12. **Q: How do you generate HTML reports in k6?**  
    *A*: Using `handleSummary(data)` export with `k6-reporter`.

13. **Q: What does `p95` response time mean?**  
    *A*: 95% of all executed requests completed faster than that specified time.

14. **Q: Why is Average response time insufficient for performance evaluation?**  
    *A*: Averages hide extreme latency outliers. Percentiles (p95, p99) accurately reflect user SLA experience.

15. **Q: How do you parameterize unique test data in k6?**  
    *A*: Use execution iteration index or libraries like `k6-utils` to generate random strings, UUIDs, or read CSV datasets.

16. **Q: Can k6 test WebSocket connections?**  
    *A*: Yes, using k6's built-in `k6/ws` module.

17. **Q: What does `http_req_failed` measure?**  
    *A*: The percentage rate of failed HTTP requests (status codes outside 2xx/3xx or network errors).

18. **Q: How do you integrate k6 with Grafana for live monitoring?**  
    *A*: Stream metrics output to InfluxDB or Prometheus using `--out` flag and connect Grafana dashboards.

19. **Q: What is dynamic correlation in API testing?**  
    *A*: Capturing dynamic values (session IDs, tokens) from one API response and passing them into subsequent requests.

20. **Q: How do you fail a CI/CD build if k6 performance thresholds fail?**  
    *A*: k6 automatically exits with non-zero exit code when a threshold fails, causing GitHub Actions to fail the step.

21. **Q: What is Soak Testing?**  
    *A*: Sustained load testing over prolonged time periods (hours/days) to detect memory leaks and resource degradation.

22. **Q: How do you group related requests in k6?**  
    *A*: Using the `group('Group Name', function() { ... })` wrapper.

23. **Q: What is the purpose of `setup()` and `teardown()` functions in k6?**  
    *A*: `setup()` runs once before VUs start (e.g. generating test data). `teardown()` runs once after test completion (e.g. cleanup).

24. **Q: How do you test gRPC services using k6?**  
    *A*: Using the native `k6/net/grpc` module.

25. **Q: What is RPS (Requests Per Second)?**  
    *A*: Total HTTP throughput executed per second by the target system.

26. **Q: What are common database bottlenecks in load tests?**  
    *A*: Unindexed table queries, high disk I/O wait times, and connection pool saturation.

27. **Q: How do you execute k6 tests in headless CI servers?**  
    *A*: Execute `k6 run script.js` in standard Ubuntu runners via GitHub Actions or Docker containers.

28. **Q: What is the maximum VUs a single k6 instance can run?**  
    *A*: Depending on system hardware, tens of thousands of VUs on a single machine due to Go goroutines efficiency.

29. **Q: What is `http_req_blocked`?**  
    *A*: Time spent waiting for free TCP connection or DNS resolution before sending request.

30. **Q: What is the recommended strategy for baseline load testing?**  
    *A*: Establish 100 VUs for 1-5 minutes on a stable staging environment to determine initial SLA benchmarks.

---

## 20. Summary & Command Cheat Sheet

### Installation & Execution Commands:
- **Install (Windows)**: `winget install GrafanaLabs.k6`
- **Verify Version**: `k6 version`
- **Run Simple Test**: `k6 run script.js`
- **Run with 100 VUs for 2m**: `k6 run --vus 100 --duration 2m script.js`
- **Pass Env Vars**: `k6 run -e BASE_URL=http://localhost:49390 script.js`
- **Stream to InfluxDB**: `k6 run --out influxdb=http://localhost:8086/k6db script.js`

### Performance SLA Threshold Targets:
- **p95 Response Time**: `< 500ms`
- **Error Rate**: `< 1.0%`
- **Throughput Target**: `> 100 RPS`
