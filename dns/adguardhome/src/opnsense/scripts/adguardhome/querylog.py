#!/usr/local/bin/python3

"""
Fetch AdGuard Home query log entries via the AGH REST API.
Output: JSON array of flat row objects to stdout.
"""

import base64
import json
import sys
import urllib.request
import urllib.error

APIKEY_PATH = '/usr/local/etc/adguardhome.apikey'
AGH_HOST = '127.0.0.1'
DEFAULT_PORT = 3000
QUERY_LIMIT = 500


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
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode())


def main():
    port = DEFAULT_PORT
    if len(sys.argv) > 1 and sys.argv[1].isdigit():
        port = int(sys.argv[1])
    base_url = 'http://{}:{}'.format(AGH_HOST, port)

    username, password = read_credentials()
    if username is None or password is None:
        print(json.dumps([]))
        return

    try:
        data = api_get(
            base_url,
            '/control/querylog?limit={}'.format(QUERY_LIMIT),
            username,
            password
        )
    except (urllib.error.URLError, OSError, ValueError):
        print(json.dumps([]))
        return

    entries = data.get('data', [])
    rows = []
    for entry in entries:
        answer_values = []
        for ans in entry.get('answer', []):
            val = ans.get('value', '')
            if val:
                answer_values.append(val)

        reason = entry.get('reason', '')
        if reason == 'NotFilteredNotFound':
            reason = 'Allowed'
        elif reason == 'NotFilteredWhiteList':
            reason = 'Allowlisted'
        elif reason in ('FilteredBlackList', 'FilteredBlockList'):
            reason = 'Blocked'
        elif reason == 'FilteredSafeBrowsing':
            reason = 'Safe Browsing'
        elif reason == 'FilteredParental':
            reason = 'Parental'
        elif reason == 'FilteredSafeSearch':
            reason = 'Safe Search'

        question = entry.get('question', {})
        rows.append({
            'time': entry.get('time', ''),
            'request': question.get('name', ''),
            'type': question.get('type', ''),
            'client': entry.get('client', ''),
            'status': reason,
            'response': ', '.join(answer_values),
        })

    print(json.dumps(rows))


if __name__ == '__main__':
    main()
