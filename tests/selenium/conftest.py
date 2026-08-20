import os
import json
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions

CONFIG_PATH = os.path.join(os.path.dirname(__file__), '../../config/selenium_config.json')

@pytest.fixture(scope="session")
def selenium_config():
    if os.path.exists(CONFIG_PATH):
        with open(CONFIG_PATH, 'r') as f:
            return json.load(f)
    return {
        "web_url": "http://localhost:49390",
        "browser": "chrome",
        "headless": True
    }

@pytest.fixture(scope="function")
def driver(selenium_config):
    chrome_options = ChromeOptions()
    if selenium_config.get("headless", True):
        chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument(f"--window-size={selenium_config.get('window_width', 1920)},{selenium_config.get('window_height', 1080)}")
    
    driver_instance = webdriver.Chrome(options=chrome_options)
    driver_instance.implicitly_wait(selenium_config.get("implicit_wait", 10))
    driver_instance.get(selenium_config.get("web_url", "http://localhost:49390"))
    
    yield driver_instance
    
    driver_instance.quit()
