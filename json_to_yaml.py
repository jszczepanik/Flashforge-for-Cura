#!/bin/env python3
import json
import sys
import yaml

payload = json.load(sys.stdin)
print(yaml.dump(payload))
