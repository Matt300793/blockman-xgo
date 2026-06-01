# -*- coding: utf-8 -*-
from qiniu import Auth, QiniuMacAuth, http
import requests
import json
import sys
url = 'http://ai.qiniuapi.com/v3/image/censor'
access_key = 'pHC4IE2wGOLBsN5p7w50GZVtBf1mtMocPw9_dEbK'
secret_key = 'bYDaT71OQPJiF-ZzyiZpLCzmzXH_rxjQNxvwIodx'
auth = QiniuMacAuth(access_key, secret_key)
body = {
    "data": {
        "uri": "http://static.sandboxol.cn/avatar/1511507174245947.jpg"
    },
    "params": {
        "scenes": ['pulp']
    }
}
scenes = {
    'censor': ['pulp', 'terror', 'politician', 'ads'],
    'pulp': ['pulp'],
    'terror': ['terror'],
    'politician': ['politician'],
    'ads': ['ads']
}
# body["params"]["scenes"] = scenes[sys.argv[1]]
# body["data"]["uri"] = sys.argv[2]
ret, res = http._post_with_qiniu_mac(url, body, auth)
headers = {"code": res.status_code, "reqid": res.req_id, "xlog": res.x_log}
print json.dumps(headers, indent=4, ensure_ascii=False)
print json.dumps(ret, indent=4, ensure_ascii=False)
print res
