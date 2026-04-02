#!/usr/local/bin/python3

"""
Fetch AdGuard Home dashboard data (status + stats) via the AGH REST API.
Output: single JSON object to stdout.
"""

import base64
import json
import sys
import urllib.request
import urllib.error

APIKEY_PATH = '/usr/local/etc/adguardhome.apikey'
AGH_HOST = '127.0.0.1'
DEFAULT_PORT = 3000


def read_credentials():
    try:
        with open(APIKEY_PATH, 'r') as f:
            lines = f.read().strip().split('\n')
        if len(lines) < 2:
            return None, None
        return lines[0], lines[1]
    except (OSError, IOError):
        return None, None


def api_get(base_url, path, username, password):
    url = base_url + path
    req = urllib.request.Request(url)
    credentials = base64.b64encode(
        '{}:{}'.format(username, password).encode()
    ).decode()
    req.add_header('Authorization', 'Basic ' + credentials)
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read().decode())


def main():
    port = DEFAULT_PORT
    if len(sys.argv) > 1 and sys.argv[1].isdigit():
        port = int(sys.argv[1])
    base_url = 'http://{}:{}'.format(AGH_HOST, port)

    username, password = read_credentials()
    if username is None or password is None:
        print(json.dumps({
            'error': 'API credentials not configured. Please save your password in Settings.'
        }))
        return

    result = {}
    try:
        status = api_get(base_url, '/control/status', username, password)
        result['version'] = status.get('version', '')
        result['running'] = status.get('running', False)
        result['protection_enabled'] = status.get('protection_enabled', False)
    except (urllib.error.URLError, OSError):
        print(json.dumps({
            'error': 'Unable to connect to AdGuard Home. Is the service running?'
        }))
        return

    try:
        stats = api_get(base_url, '/control/stats', username, password)
        result['num_dns_queries'] = stats.get('num_dns_queries', 0)
        result['num_blocked_filtering'] = stats.get('num_blocked_filtering', 0)
        result['num_replaced_safebrowsing'] = stats.get('num_replaced_safebrowsing', 0)
        result['num_replaced_parental'] = stats.get('num_replaced_parental', 0)
        result['num_replaced_safesearch'] = stats.get('num_replaced_safesearch', 0)
        result['avg_processing_time'] = stats.get('avg_processing_time', 0)
        result['top_queried_domains'] = stats.get('top_queried_domains', [])
        result['top_blocked_domains'] = stats.get('top_blocked_domains', [])
        result['top_clients'] = stats.get('top_clients', [])
    except (urllib.error.URLError, OSError, ValueError):
        result['stats_error'] = 'Unable to fetch statistics.'

    print(json.dumps(result))


if __name__ == '__main__':
    main()
