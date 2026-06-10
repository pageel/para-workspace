#!/usr/bin/env bash

# Resolve the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REGISTRY_FILE="${SCRIPT_DIR}/../files/legacy-files.json"

if [ ! -f "$REGISTRY_FILE" ]; then
  echo "Error: Registry file not found at $REGISTRY_FILE"
  exit 1
fi

# We use Python to parse the JSON and check file existence
python3 -c "
import json
import os
import sys

try:
    with open('$REGISTRY_FILE', 'r') as f:
        data = json.load(f)
    
    legacy_files = data.get('legacy_files', [])
    detected_count = 0
    
    # We output a structured output that can be easily parsed or printed
    for item in legacy_files:
        path = item.get('path')
        action = item.get('action')
        reason = item.get('reason')
        
        if os.path.exists(path):
            detected_count += 1
            print(f'FOUND|{path}|{action}|{reason}')
            
    if detected_count == 0:
        print('CLEAN')
except Exception as e:
    print(f'ERROR|{str(e)}')
    sys.exit(1)
"
