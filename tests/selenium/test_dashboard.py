import os
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options

@pytest.fixture(scope="module")
def browser():
    options = Options()
    options.add_argument("--headless")  # needed for CI
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Chrome(options=options)
    yield driver
    driver.quit()

def get_dashboard_url():
    """Fetch dashboard URL from environment, fail if missing"""
    dashboard_url = os.getenv("WAZUH_DASHBOARD_URL")
    assert dashboard_url, "WAZUH_DASHBOARD_URL must be set"
    return dashboard_url

def test_dashboard_https(browser):
    """Validate dashboard is reachable over HTTPS"""
    dashboard_url = get_dashboard_url()
    browser.get(dashboard_url)
    assert browser.current_url.startswith("https://")

def test_dashboard_title(browser):
    """Validate page title contains Wazuh"""
    dashboard_url = get_dashboard_url()
    browser.get(dashboard_url)
    assert "Wazuh" in browser.title

def test_login_form_elements(browser):
    """Validate login form is present"""
    dashboard_url = get_dashboard_url()
    browser.get(dashboard_url)
    assert browser.find_element(By.NAME, "username")
    assert browser.find_element(By.NAME, "password")
    assert browser.find_element(By.TAG_NAME, "button")
