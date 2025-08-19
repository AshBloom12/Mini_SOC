import os
import requests

def test_manager_api_health():
    """Validate manager API returns 200 and JSON"""
    api_url = os.getenv("WAZUH_API_URL", "https://manager.cires.com:55000")
    user = os.getenv("WAZUH_API_USER")
    password = os.getenv("WAZUH_API_PASS")

    r = requests.get(f"{api_url}/security/user/authenticate",
                     auth=(user, password),
                     verify=False)  # ignore self-signed in CI

    assert r.status_code == 200
    data = r.json()
    assert "data" in data or "token" in data
