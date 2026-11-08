#!/bin/sh
# Lists the connector's tools. This does not send any email: only calling the tool itself does.
curl -s -X POST https://humansfix.ai/mcp \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
echo
