import os
import requests

API_URL = os.environ["WAZUH_API_URL"]
API_USER = os.environ["WAZUH_API_USER"]
API_PASS = os.environ["WAZUH_API_PASS"]

def test_manager_api_health():
    r = requests.get(f"{API_URL}/security/user/authenticate",
                     auth=(API_USER, API_PASS),
                     verify=False)
    assert r.status_code == 200
    data = r.json()
    assert "data" in data or "token" in data
