import os
import requests

def test_manager_api_health():
    api_url = os.getenv("WAZUH_API_URL", "https://manager.example.com:55000")
    user = os.getenv("WAZUH_API_USER")
    password = os.getenv("WAZUH_API_PASS")

    assert user and password, "API credentials not set!"

    r = requests.get(f"{api_url}/security/user/authenticate", auth=(user, password), verify=False)
    assert r.status_code == 200
    assert "token" in r.json()
