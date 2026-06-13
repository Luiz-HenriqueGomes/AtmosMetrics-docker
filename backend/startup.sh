#!/bin/bash
rm -rf /home/site/wwwroot/antenv
export PYTHONPATH=/home/site/wwwroot/python_packages/lib/site-packages:/home/site/wwwroot
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
