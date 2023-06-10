#!/bin/env python3
import json
import sys
import yaml

payload = yaml.safe_load(sys.stdin)
print(json.dumps(payload, indent=2))
