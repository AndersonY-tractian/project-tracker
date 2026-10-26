#!/bin/bash
PORT=8765
cd ~/project-tracker

# Kill any existing server on that port
lsof -ti:$PORT | xargs kill -9 2>/dev/null

echo "Starting Project Tracker on http://localhost:$PORT"
python3 -m http.server $PORT --bind 127.0.0.1 &>/dev/null &
sleep 0.5
open "http://localhost:$PORT/dashboard.html"
