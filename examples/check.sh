#!/bin/sh
# Lists the connector's tools. This needs no sign-in and sends nothing: calling a tool needs a token.
curl -s -X POST https://humansfix.ai/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
echo
