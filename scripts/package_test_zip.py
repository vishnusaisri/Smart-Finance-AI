import os
import zipfile

def package_zip():
    zip_name = "smart_finance_ai_test_suite.zip"
    
    include_dirs = [
        "Smart Finance AI Appium",
        "Smart Finance AI E2E",
        "Smart Finance AI Vulnerability",
        "Smart Finance AI Load",
        "Excel_Reports",
        ".github/workflows",
        "config",
        "tests",
        "reports",
        "scripts"
    ]
    
    include_files = [
        "README.md",
        "README_TESTING.md",
        "requirements.txt",
        "create_master_excel.js",
        "convert_to_csv.js",
        "Android_Appium_Test_Report.xlsx",
        "Web_E2E_Test_Report.xlsx",
        "Vulnerability_Security_Test_Report.xlsx",
        "Load_Performance_Test_Report.xlsx",
        "Android_Appium_Test_Report_Test_Cases.csv",
        "Web_E2E_Test_Report_Selenium_Test_Report.csv",
        "Vulnerability_Security_Test_Report_Test_Cases.csv",
        "Load_Performance_Test_Report_Test_Cases.csv"
    ]

    print(f"Creating ZIP archive: {zip_name}...")

    with zipfile.ZipFile(zip_name, "w", zipfile.ZIP_DEFLATED) as zf:
        for d in include_dirs:
            if os.path.exists(d):
                for root, dirs, files in os.walk(d):
                    # Skip node_modules or large build artifacts in zip to keep fast & clean
                    if "node_modules" in root or ".pytest_cache" in root or "build" in root:
                        continue
                    for file in files:
                        full_path = os.path.join(root, file)
                        arcname = os.path.relpath(full_path, os.getcwd())
                        zf.write(full_path, arcname)

        for f in include_files:
            if os.path.exists(f):
                zf.write(f, f)

    zip_size_mb = os.path.getsize(zip_name) / (1024 * 1024)
    print(f"ZIP package created successfully: {zip_name} ({zip_size_mb:.2f} MB)")

if __name__ == "__main__":
    package_zip()
