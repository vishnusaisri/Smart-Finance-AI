import os
import json
import pytest
from appium import webdriver
from appium.options.android import UiAutomator2Options

CONFIG_PATH = os.path.join(os.path.dirname(__file__), '../../config/appium_config.json')

@pytest.fixture(scope="session")
def appium_config():
    if os.path.exists(CONFIG_PATH):
        with open(CONFIG_PATH, 'r') as f:
            return json.load(f)
    return {
        "appium_server_url": "http://127.0.0.1:4723",
        "platformName": "Android",
        "automationName": "UiAutomator2",
        "deviceName": "Android Emulator",
        "appPackage": "com.smartfinance.ai",
        "appActivity": "com.smartfinance.ai.MainActivity"
    }

@pytest.fixture(scope="function")
def driver(appium_config):
    options = UiAutomator2Options()
    options.platform_name = appium_config.get("platformName", "Android")
    options.automation_name = appium_config.get("automationName", "UiAutomator2")
    options.device_name = appium_config.get("deviceName", "Android Emulator")
    if "app" in appium_config and os.path.exists(appium_config["app"]):
        options.app = appium_config["app"]
    
    server_url = appium_config.get("appium_server_url", "http://127.0.0.1:4723")
    driver_instance = webdriver.Remote(command_executor=server_url, options=options)
    driver_instance.implicitly_wait(appium_config.get("implicit_wait", 10))
    
    yield driver_instance
    
    driver_instance.quit()
