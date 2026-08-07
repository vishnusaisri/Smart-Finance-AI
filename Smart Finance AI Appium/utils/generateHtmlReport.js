const fs = require('fs');
const path = require('path');

function generateHtmlReport(testData, summaryData, outputPath) {
  const total = testData.length;
  const passed = testData.filter(t => t.status === 'PASSED').length;
  const failed = testData.filter(t => t.status === 'FAILED').length;
  const passRate = total > 0 ? ((passed / total) * 100).toFixed(1) : '0.0';
  const totalDuration = testData.reduce((sum, t) => sum + (t.duration || 0), 0);

  const dirPath = path.dirname(outputPath);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }

  const categoryRowsHtml = summaryData.map((cat, idx) => `
    <tr>
      <td>${idx + 1}</td>
      <td><strong>${cat.category}</strong></td>
      <td>${cat.total}</td>
      <td><span class="badge pass">${cat.passed}</span></td>
      <td><span class="badge ${cat.failed > 0 ? 'fail' : 'zero'}">${cat.failed}</span></td>
      <td>
        <div class="progress-bar-bg">
          <div class="progress-bar-fill" style="width: ${cat.passRate}%"></div>
        </div>
        <span class="rate-text">${cat.passRate}%</span>
      </td>
      <td>${cat.avgDuration} ms</td>
    </tr>
  `).join('');

  const detailRowsHtml = testData.map((t, idx) => `
    <tr class="test-row ${t.status.toLowerCase()}" data-category="${t.category.replace(/"/g, '&quot;')}">
      <td>${idx + 1}</td>
      <td><span class="cat-pill">${t.category}</span></td>
      <td>${t.name}</td>
      <td><span class="badge ${t.status.toLowerCase()}">${t.status}</span></td>
      <td>${t.duration} ms</td>
      <td class="time-col">${t.timestamp}</td>
      <td>${t.error ? `<details><summary class="err-summary">View Stack</summary><pre class="err-stack">${t.error}</pre></details>` : '<span class="text-muted">-</span>'}</td>
    </tr>
  `).join('');

  const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Smart Finance AI — 1,111 Mobile Appium E2E Test Report</title>
  <style>
    :root {
      --bg-dark: #090d16;
      --card-bg: #111827;
      --border-color: #1f2937;
      --text-main: #f9fafb;
      --text-muted: #9ca3af;
      --accent-purple: #8b5cf6;
      --accent-emerald: #10b981;
      --pass-color: #10b981;
      --fail-color: #ef4444;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--bg-dark);
      color: var(--text-main);
      padding: 30px;
      line-height: 1.5;
    }
    header {
      margin-bottom: 30px;
      padding-bottom: 20px;
      border-bottom: 1px solid var(--border-color);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    h1 {
      font-size: 1.8rem;
      background: linear-gradient(135deg, #10b981, #3b82f6);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    .subtitle { color: var(--text-muted); font-size: 0.95rem; margin-top: 5px; }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      margin-bottom: 35px;
    }
    .stat-card {
      background: var(--card-bg);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      padding: 20px;
      text-align: center;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }
    .stat-value { font-size: 2rem; font-weight: 700; margin-top: 5px; }
    .stat-card.total .stat-value { color: #60a5fa; }
    .stat-card.pass .stat-value { color: var(--pass-color); }
    .stat-card.fail .stat-value { color: var(--fail-color); }
    .stat-card.rate .stat-value { color: #a78bfa; }
    .stat-card.time .stat-value { color: #f59e0b; }

    .section-title {
      font-size: 1.3rem;
      margin-bottom: 15px;
      color: #e5e7eb;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .filter-controls {
      display: flex;
      gap: 10px;
      margin-bottom: 15px;
    }
    .btn-filter {
      background: var(--card-bg);
      border: 1px solid var(--border-color);
      color: var(--text-main);
      padding: 6px 14px;
      border-radius: 6px;
      cursor: pointer;
      font-size: 0.85rem;
    }
    .btn-filter.active {
      background: var(--accent-emerald);
      border-color: var(--accent-emerald);
      color: #000;
      font-weight: 600;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 40px;
      background: var(--card-bg);
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid var(--border-color);
    }
    th, td {
      padding: 12px 16px;
      text-align: left;
      border-bottom: 1px solid var(--border-color);
      font-size: 0.9rem;
    }
    th {
      background-color: rgba(255, 255, 255, 0.03);
      color: var(--text-muted);
      font-weight: 600;
      text-transform: uppercase;
      font-size: 0.75rem;
      letter-spacing: 0.5px;
    }
    tr:hover { background-color: rgba(255, 255, 255, 0.02); }

    .badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 4px;
      font-size: 0.75rem;
      font-weight: 700;
      text-transform: uppercase;
    }
    .badge.pass, .badge.passed { background: rgba(16, 185, 129, 0.2); color: var(--pass-color); border: 1px solid var(--pass-color); }
    .badge.fail, .badge.failed { background: rgba(239, 68, 68, 0.2); color: var(--fail-color); border: 1px solid var(--fail-color); }
    .badge.zero { color: var(--text-muted); }

    .cat-pill {
      background: rgba(16, 185, 129, 0.15);
      color: #34d399;
      padding: 2px 8px;
      border-radius: 12px;
      font-size: 0.8rem;
    }
    .progress-bar-bg {
      background: #1f2937;
      height: 8px;
      border-radius: 4px;
      width: 100px;
      display: inline-block;
      vertical-align: middle;
      margin-right: 8px;
      overflow: hidden;
    }
    .progress-bar-fill {
      height: 100%;
      background: linear-gradient(90deg, #10b981, #3b82f6);
    }
    .rate-text { font-size: 0.85rem; color: var(--text-muted); }
    .err-summary { color: #f87171; cursor: pointer; font-size: 0.8rem; }
    .err-stack { background: #000; padding: 10px; border-radius: 6px; color: #fca5a5; margin-top: 6px; white-space: pre-wrap; font-size: 0.75rem; }
    .time-col { color: var(--text-muted); font-size: 0.8rem; }
    .text-muted { color: var(--text-muted); }
  </style>
</head>
<body>

  <header>
    <div>
      <h1>Smart Finance AI — Mobile Appium E2E Execution Report</h1>
      <div class="subtitle">1,111 Android Parametric Test Cases across 11 Testing Categories</div>
    </div>
    <div class="subtitle">Generated: ${new Date().toLocaleString()}</div>
  </header>

  <section class="stats-grid">
    <div class="stat-card total">
      <div>Total Appium Tests</div>
      <div class="stat-value">${total}</div>
    </div>
    <div class="stat-card pass">
      <div>Passed</div>
      <div class="stat-value">${passed}</div>
    </div>
    <div class="stat-card fail">
      <div>Failed</div>
      <div class="stat-value">${failed}</div>
    </div>
    <div class="stat-card rate">
      <div>Pass Rate</div>
      <div class="stat-value">${passRate}%</div>
    </div>
    <div class="stat-card time">
      <div>Total Duration</div>
      <div class="stat-value">${(totalDuration / 1000).toFixed(2)}s</div>
    </div>
  </section>

  <h2 class="section-title">Mobile Testing Categories (11 Categories)</h2>
  <table>
    <thead>
      <tr>
        <th>#</th>
        <th>Category</th>
        <th>Total Tests</th>
        <th>Passed</th>
        <th>Failed</th>
        <th>Pass Rate</th>
        <th>Avg Duration</th>
      </tr>
    </thead>
    <tbody>
      ${categoryRowsHtml}
    </tbody>
  </table>

  <div class="section-title">
    <span>Detailed Test Case Results (${total})</span>
    <div class="filter-controls">
      <button class="btn-filter active" onclick="filterTests('all')">All (${total})</button>
      <button class="btn-filter" onclick="filterTests('passed')">Passed (${passed})</button>
      <button class="btn-filter" onclick="filterTests('failed')">Failed (${failed})</button>
    </div>
  </div>

  <table id="details-table">
    <thead>
      <tr>
        <th>#</th>
        <th>Category</th>
        <th>Test Description</th>
        <th>Status</th>
        <th>Duration</th>
        <th>Timestamp</th>
        <th>Error Stack</th>
      </tr>
    </thead>
    <tbody>
      ${detailRowsHtml}
    </tbody>
  </table>

  <script>
    function filterTests(status) {
      document.querySelectorAll('.btn-filter').forEach(btn => btn.classList.remove('active'));
      event.target.classList.add('active');

      const rows = document.querySelectorAll('#details-table tbody .test-row');
      rows.forEach(row => {
        if (status === 'all') {
          row.style.display = '';
        } else if (row.classList.contains(status)) {
          row.style.display = '';
        } else {
          row.style.display = 'none';
        }
      });
    }
  </script>

</body>
</html>`;

  fs.writeFileSync(outputPath, htmlContent, 'utf-8');
  console.log(`[HTML Reporter] Mobile Appium HTML report generated at: ${outputPath}`);
}

module.exports = { generateHtmlReport };
