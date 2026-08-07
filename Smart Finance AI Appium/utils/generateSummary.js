const fs = require('fs');

function writeGithubSummary(stats) {
  const summaryFile = process.env.GITHUB_STEP_SUMMARY;
  if (!summaryFile) {
    console.log('[Summary Info] GITHUB_STEP_SUMMARY environment variable not set.');
    return;
  }

  const { total, passed, failed, passRate, totalDuration } = stats;

  const content = `
### 📱 Mobile Appium E2E (1,111 Android Tests) Execution Summary

| Metric | Value |
| --- | --- |
| **Total Appium Assertions** | ${total} |
| **Mobile Categories** | 11 |
| **Passed Tests** | ✅ ${passed} |
| **Failed Tests** | ${failed > 0 ? `❌ ${failed}` : '0'} |
| **Overall Pass Rate** | **${passRate}%** |
| **Total Execution Time** | ${(totalDuration / 1000).toFixed(2)}s |

#### 📊 Live Mobile Reports:
- 🌐 **Latest Execution Report**: [View Live Report](\${{ steps.deployment.outputs.page_url }}reports/latest/execution-report.html)
- 📜 **Build History Report**: [View Build Report](\${{ steps.deployment.outputs.page_url }}reports/history/build-${process.env.GITHUB_RUN_NUMBER || '1'}/execution-report.html)
`;

  try {
    fs.appendFileSync(summaryFile, content, 'utf-8');
    console.log('[Summary Info] Appended mobile metrics to $GITHUB_STEP_SUMMARY');
  } catch (err) {
    console.error('[Summary Error] Failed to write to GITHUB_STEP_SUMMARY:', err.message);
  }
}

module.exports = { writeGithubSummary };
