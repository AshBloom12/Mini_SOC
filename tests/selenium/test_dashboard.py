import os
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options

SELENIUM_URL = "http://localhost:4444/wd/hub"  # Selenium container
DASHBOARD_URL = os.environ["WAZUH_DASHBOARD_URL"]  # must be set in CI

@pytest.fixture(scope="module")
def browser():
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Remote(command_executor=SELENIUM_URL, options=options)
    yield driver
    driver.quit()

def test_dashboard_https(browser):
    browser.get(DASHBOARD_URL)
    assert browser.current_url.startswith("https://")

def test_dashboard_title(browser):
    browser.get(DASHBOARD_URL)
    assert "Wazuh" in browser.title

def test_login_form_elements(browser):
    browser.get(DASHBOARD_URL)
    assert browser.find_element(By.NAME, "username")
    assert browser.find_element(By.NAME, "password")
    assert browser.find_element(By.TAG_NAME, "button")
