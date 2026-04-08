#!/bin/bash
set -e
cd "$(dirname "$0")"
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi
source venv/bin/activate
./venv/bin/python -m pip install --upgrade pip
./venv/bin/pip install -r requirements.txt
echo "OK"
