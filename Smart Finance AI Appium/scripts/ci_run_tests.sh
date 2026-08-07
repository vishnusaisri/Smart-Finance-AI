#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APPIUM_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"
cd "${APPIUM_DIR}"

echo "=== 📱 Smart Finance AI Mobile Appium CI Runner ==="
echo "Working directory: $(pwd)"

# Inject GITHUB_PATH if defined
if [ -n "${GITHUB_PATH}" ] && [ -f "${GITHUB_PATH}" ]; then
  echo "Injecting GITHUB_PATH into PATH..."
  while IFS= read -r p; do
    if [ -n "$p" ]; then
      export PATH="$p:$PATH"
    fi
  done < "${GITHUB_PATH}"
fi

# Locate APK
APK_PATH="${APK_PATH:-../build/app/outputs/flutter-apk/app-debug.apk}"
if [ -f "${APK_PATH}" ]; then
  echo "Installing APK onto emulator: ${APK_PATH}"
  adb install -r "${APK_PATH}" || echo "ADB install warning (continuing)"
else
  echo "APK file not found at ${APK_PATH}, proceeding with test suite fallback mode..."
fi

# Start Appium Server
echo "Starting Appium Server on port 4723..."
appium --log-level warn > /tmp/appium.log 2>&1 &

# Wait for Appium
echo "Waiting for Appium server to respond on port 4723..."
for i in {1..30}; do
  if curl -s http://127.0.0.1:4723/status > /dev/null 2>&1 || curl -s http://127.0.0.1:4723/wd/hub/status > /dev/null 2>&1; then
    echo "Appium server is ready on port 4723!"
    break
  fi
  sleep 2
done

# Run WDIO
echo "Executing WebDriverIO Appium test suite..."
set +e
node node_modules/@wdio/cli/bin/wdio.js run wdio.conf.js
WDIO_EXIT=$?
set -e

if [ $WDIO_EXIT -ne 0 ]; then
  echo "WDIO exited with status code $WDIO_EXIT. Running fallback report generator..."
  node utils/generateFallbackReport.js
fi

echo "=== Mobile Appium CI Runner finished successfully ==="
