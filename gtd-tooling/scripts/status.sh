#!/bin/bash
# Wrapper for gtd_commands.py status
python3 "$(dirname "$0")/gtd_commands.py" status "$@"
