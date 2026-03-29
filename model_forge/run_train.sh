#!/bin/bash
set -e
cd "$(dirname "$0")"
./setup_env.sh
./venv/bin/python scripts/train.py
