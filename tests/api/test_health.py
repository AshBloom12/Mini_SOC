import os
import requests

def test_manager_api_health():
    """Validate manager API returns 200 and JSON"""
    api_url = os.getenv("WAZUH_API_URL")
    user = os.getenv("WAZUH_API_USER")
    password = os.getenv("WAZUH_API_PASS")

    # Fail early if required env vars are missing
    assert api_url, "WAZUH_API_URL must be set"
    assert user, "WAZUH_API_USER must be set"
    assert password, "WAZUH_API_PASS must be set"

    r = requests.get(f"{api_url}/security/user/authenticate",
                     auth=(user, password),
                     verify=False)  # ignore self-signed in CI

    assert r.status_code == 200
    data = r.json()
    assert "data" in data or "token" in data

