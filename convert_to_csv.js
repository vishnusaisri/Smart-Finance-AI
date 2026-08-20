const ExcelJS = require('./Smart Finance AI E2E/node_modules/exceljs');
const fs = require('fs');

async function convertToCsv(xlsxPath, csvPath) {
  if (!fs.existsSync(xlsxPath)) return;
  const wb = new ExcelJS.Workbook();
  await wb.xlsx.readFile(xlsxPath);
  
  wb.worksheets.forEach(ws => {
    let csvContent = '';
    ws.eachRow((row) => {
      const rowValues = row.values.slice(1).map(v => {
        let str = '';
        if (typeof v === 'object' && v !== null) {
          str = v.result || v.text || JSON.stringify(v);
        } else {
          str = String(v || '');
        }
        return '"' + str.replace(/"/g, '""') + '"';
      });
      csvContent += rowValues.join(',') + '\n';
    });

    const sheetNameClean = ws.name.replace(/[^a-zA-Z0-9]/g, '_');
    const outPath = csvPath.replace('.csv', `_${sheetNameClean}.csv`);
    fs.writeFileSync(outPath, csvContent, 'utf-8');
    console.log('Saved CSV sheet to:', outPath);
  });
}

async function main() {
  await convertToCsv('Web_E2E_Test_Report.xlsx', 'Web_E2E_Test_Report.csv');
  await convertToCsv('Android_Appium_Test_Report.xlsx', 'Android_Appium_Test_Report.csv');
  await convertToCsv('Vulnerability_Security_Test_Report.xlsx', 'Vulnerability_Security_Test_Report.csv');
  await convertToCsv('Load_Performance_Test_Report.xlsx', 'Load_Performance_Test_Report.csv');
}

main();
