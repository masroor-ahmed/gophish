#!/bin/bash

# Adjust the config.json for dynamic port binding
if [ -n "$PORT" ]; then
  jq --arg port "$PORT" '.phish_server.listen_url = "0.0.0.0:" + $port' config.json > config.json.tmp && mv config.json.tmp config.json
fi

# Start Gophish
./gophish -config config.json
