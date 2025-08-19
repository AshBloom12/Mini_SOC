import os
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options

@pytest.fixture(scope="module")
def browser():
    options = Options()
    options.add_argument("--headless")  # run headless for CI
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Chrome(options=options)
    yield driver
    driver.quit()

def test_dashboard_reachable(browser):
    dashboard_url = os.getenv("WAZUH_DASHBOARD_URL", "https://dashboard.example.com")
    browser.get(dashboard_url)
    assert "Wazuh" in browser.title

def test_login_form_present(browser):
    dashboard_url = os.getenv("WAZUH_DASHBOARD_URL", "https://dashboard.example.com")
    browser.get(dashboard_url)
    username_input = browser.find_element(By.NAME, "username")
    password_input = browser.find_element(By.NAME, "password")
    login_button = browser.find_element(By.TAG_NAME, "button")
    assert username_input and password_input and login_button

def test_login_with_test_user(browser):
    """Optional bonus: use non-admin creds stored in GitHub Secrets"""
    dashboard_url = os.getenv("WAZUH_DASHBOARD_URL", "https://dashboard.example.com")
    test_user = os.getenv("WAZUH_TEST_USER")
    test_pass = os.getenv("WAZUH_TEST_PASS")
    if not test_user or not test_pass:
        pytest.skip("Test user credentials not provided")

    browser.get(dashboard_url)
    browser.find_element(By.NAME, "username").send_keys(test_user)
    browser.find_element(By.NAME, "password").send_keys(test_pass)
    browser.find_element(By.TAG_NAME, "button").click()

    # After login, check landing page
    assert "Overview" in browser.page_source
