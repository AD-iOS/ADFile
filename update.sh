#!/bin/bash

sudo cd /var/mobile/Opensource/ADFile

# 提交更新
git add .
git commit -m "Auto-update $(date +'%Y-%m-%d %H:%M')"
git pull --rebase
git push origin main