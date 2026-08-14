const ExcelJS = require('./Smart Finance AI E2E/node_modules/exceljs');
const fs = require('fs');
const path = require('path');

async function createMasterExcel() {
  const masterWb = new ExcelJS.Workbook();
  masterWb.creator = 'Smart Finance AI Test Automation Suite';
  masterWb.created = new Date();

  // Load Web workbook
  const webWb = new ExcelJS.Workbook();
  await webWb.xlsx.readFile('Web_E2E_Test_Report.xlsx');

  // Load Mobile workbook
  const mobileWb = new ExcelJS.Workbook();
  await mobileWb.xlsx.readFile('Android_Appium_Test_Report.xlsx');

  // Function to clone worksheet into master
  function copySheet(srcSheet, targetName) {
    const newSheet = masterWb.addWorksheet(targetName);
    srcSheet.eachRow({ includeEmpty: true }, (row, rowNumber) => {
      const newRow = newSheet.getRow(rowNumber);
      row.eachCell({ includeEmpty: true }, (cell, colNumber) => {
        const newCell = newRow.getCell(colNumber);
        newCell.value = cell.value;
        if (cell.font) newCell.font = cell.font;
        if (cell.fill) newCell.fill = cell.fill;
        if (cell.border) newCell.border = cell.border;
        if (cell.alignment) newCell.alignment = cell.alignment;
      });
      newRow.height = row.height;
    });

    srcSheet.columns.forEach((col, i) => {
      if (newSheet.getColumn(i + 1)) {
        newSheet.getColumn(i + 1).width = col.width || 15;
      }
    });
  }

  // Copy sheets
  webWb.worksheets.forEach((sheet) => {
    copySheet(sheet, `Web - ${sheet.name}`);
  });

  mobileWb.worksheets.forEach((sheet) => {
    copySheet(sheet, `Mobile - ${sheet.name}`);
  });

  const outDir = path.join(process.cwd(), 'Excel_Reports');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  await masterWb.xlsx.writeFile(path.join(outDir, 'All_Test_Results_Master.xlsx'));
  fs.copyFileSync('Web_E2E_Test_Report.xlsx', path.join(outDir, 'Web_E2E_Test_Report.xlsx'));
  fs.copyFileSync('Android_Appium_Test_Report.xlsx', path.join(outDir, 'Android_Appium_Test_Report.xlsx'));

  console.log('Master Excel report generated in Excel_Reports folder!');
}

createMasterExcel();
