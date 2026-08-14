const path = require('path');
const fs = require('fs');
const xlsxReporter = require('./utils/xlsxReporter');
const { generateHtmlReport } = require('./utils/generateHtmlReport');
const { writeGithubSummary } = require('./utils/generateSummary');

const resultsFile = path.join(process.cwd(), '.wdio-results.jsonl');

exports.config = {
  runner: 'local',
  specs: [
    process.env.WDIO_CI_SPEC || './tests/12_e2e/mega_android_1100.test.js'
  ],
  maxInstances: 1,
  capabilities: [{
    platformName: 'Android',
    'appium:automationName': 'UiAutomator2',
    'appium:deviceName': 'Android Emulator',
    'appium:app': process.env.APK_PATH || path.join(process.cwd(), '../build/app/outputs/flutter-apk/app-debug.apk'),
    'appium:newCommandTimeout': 240,
    'appium:autoGrantPermissions': true,
  }],
  logLevel: 'warn',
  bail: 0,
  baseUrl: 'http://localhost',
  port: 4723,
  waitforTimeout: 10000,
  connectionRetryTimeout: 120000,
  connectionRetryCount: 3,
  services: [],
  framework: 'mocha',
  reporters: ['spec'],
  mochaOpts: {
    ui: 'bdd',
    timeout: 300000,
  },

  onPrepare: function () {
    console.log('[WDIO] Starting Appium test execution...');
    xlsxReporter.startRun();
    if (fs.existsSync(resultsFile)) {
      fs.unlinkSync(resultsFile);
    }
  },

  afterTest: function (test, context, { error, result, duration, passed }) {
    const category = test.parent || 'General';
    const status = passed ? 'PASSED' : 'FAILED';
    const record = {
      category,
      name: test.title,
      status,
      duration: duration || 0,
      timestamp: new Date().toISOString(),
      error: error ? (error.stack || error.message || String(error)) : '',
    };

    fs.appendFileSync(resultsFile, JSON.stringify(record) + '\n', 'utf-8');
  },

  after: function (result, capabilities, specs) {
    if (result !== 0) {
      console.log('[WDIO] Intercepted test run result code:', result);
    }
  },

  onComplete: async function (exitCode, config, capabilities, results) {
    console.log('[WDIO] Processing final report generation...');
    xlsxReporter.startRun();

    if (fs.existsSync(resultsFile)) {
      const lines = fs.readFileSync(resultsFile, 'utf-8').split('\n').filter(l => l.trim().length > 0);
      lines.forEach(line => {
        try {
          const rec = JSON.parse(line);
          xlsxReporter.recordTest(rec);
        } catch (e) {}
      });
    }

    const excelPath = path.join(process.cwd(), 'Test_Results', 'Excel', 'excel-report.xlsx');
    const htmlPath = path.join(process.cwd(), 'Test_Results', 'HTML', 'execution-report.html');

    const summary = await xlsxReporter.generateReport(excelPath);
    generateHtmlReport(summary.results, summary.catList, htmlPath);
    writeGithubSummary(summary);
  }
};
