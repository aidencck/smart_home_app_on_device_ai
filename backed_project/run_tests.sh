#!/bin/bash
pip install pytest pytest-asyncio > /dev/null 2>&1
export SERVICE_ROLE=all
pytest -v tests/test_api.py::test_device_binding tests/test_api.py::test_device_heartbeat tests/test_api.py::test_device_state_conflict > test_output.txt 2>&1
cat test_output.txt
