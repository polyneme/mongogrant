#!/bin/bash

set -euo pipefail

python server_setup.py
exec gunicorn --worker-tmp-dir /dev/shm --workers=2 \
              --threads=4 --worker-class gthread \
              --log-file=- --bind 0.0.0.0:8000 mongogrant.app:app