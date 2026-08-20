const ExcelJS = require('./Smart Finance AI E2E/node_modules/exceljs');
const fs = require('fs');
const path = require('path');

async function createMasterExcel() {
  const masterWb = new ExcelJS.Workbook();
  masterWb.creator = 'Smart Finance AI Test Automation Suite';
  masterWb.created = new Date();

  function copySheet(srcSheet, targetName) {
    const cleanName = targetName.substring(0, 31);
    const newSheet = masterWb.addWorksheet(cleanName);
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

  const reports = [
    { file: 'Web_E2E_Test_Report.xlsx', prefix: 'Web' },
    { file: 'Android_Appium_Test_Report.xlsx', prefix: 'Mobile' },
    { file: 'Vulnerability_Security_Test_Report.xlsx', prefix: 'Sec' },
    { file: 'Load_Performance_Test_Report.xlsx', prefix: 'Load' }
  ];

  for (const r of reports) {
    if (fs.existsSync(r.file)) {
      const wb = new ExcelJS.Workbook();
      await wb.xlsx.readFile(r.file);
      wb.worksheets.forEach(sheet => {
        copySheet(sheet, `${r.prefix} - ${sheet.name}`);
      });
    }
  }

  const outDir = path.join(process.cwd(), 'Excel_Reports');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

  await masterWb.xlsx.writeFile(path.join(outDir, 'All_Test_Results_Master.xlsx'));

  reports.forEach(r => {
    if (fs.existsSync(r.file)) {
      fs.copyFileSync(r.file, path.join(outDir, r.file));
    }
  });

  console.log('Master Excel report generated in Excel_Reports folder for all 4 test categories!');
}

createMasterExcel();
