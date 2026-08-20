const ExcelJS = require('../Smart Finance AI E2E/node_modules/exceljs');
const fs = require('fs');
const path = require('path');

async function inspectReports() {
  const baseDir = path.join(__dirname, '..');
  const files = [
    'Web_E2E_Test_Report.xlsx',
    'Android_Appium_Test_Report.xlsx',
    'Vulnerability_Security_Test_Report.xlsx',
    'Load_Performance_Test_Report.xlsx',
    'Excel_Reports/All_Test_Results_Master.xlsx'
  ];

  for (const f of files) {
    const filePath = path.join(baseDir, f);
    if (fs.existsSync(filePath)) {
      const wb = new ExcelJS.Workbook();
      await wb.xlsx.readFile(filePath);
      console.log(`\n=== File: ${f} ===`);
      wb.worksheets.forEach(ws => {
        console.log(`  Sheet: "${ws.name}" (RowCount: ${ws.rowCount})`);
      });
    } else {
      console.log(`❌ File missing: ${filePath}`);
    }
  }
}

inspectReports();
