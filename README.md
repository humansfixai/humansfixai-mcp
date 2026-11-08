# humans fix ai: MCP connector

**Give your AI coding agent a human to call.**

When Claude Code, Codex, Cursor or another assistant reaches something it cannot solve on its own, it can ask a real developer to help you. One tool, your permission first, nothing charged.

- Website and setup page: <https://humansfix.ai/mcp-server>
- Connector address: `https://humansfix.ai/mcp` (Streamable HTTP, no sign-in)
- Server card: <https://humansfix.ai/mcp/server-card>
- Official MCP Registry name: `ai.humansfix/humansfix`

This repository holds the documentation and examples. The server itself runs at humansfix.ai, and its source code is not published here.

## What it does

AI coding agents are very good until they are not. A requirement is unclear, a change is risky, a bug will not reproduce, or you just want a person to look over what the agent built. Connect humans fix ai and your agent gets one new ability: **ask a human developer**.

The agent writes a short summary of the problem. We email you a code. You enter it, and the request goes to developers we have approved by hand. One of them calls you for a free video call, and most problems are solved there. If more work is needed, you get one fixed price and decide whether to accept it. You pay only after you approve the result.

## Connect it

You do not need an account or a key.

**Claude Code**

```bash
claude mcp add --transport http humansfix https://humansfix.ai/mcp
```

**Codex**

```bash
codex mcp add humansfix --url https://humansfix.ai/mcp
```

Or add this to `~/.codex/config.toml` (see [`examples/codex-config.toml`](examples/codex-config.toml)):

```toml
[mcp_servers.humansfix]
url = "https://humansfix.ai/mcp"
```

**Cursor**

Add this to `~/.cursor/mcp.json`, or to `.cursor/mcp.json` in one project, then restart Cursor (see [`examples/cursor-mcp.json`](examples/cursor-mcp.json)):

```json
{
  "mcpServers": {
    "humansfix": { "url": "https://humansfix.ai/mcp" }
  }
}
```

**Claude on the web**

Open **Settings**, then **Connectors**, choose **Add custom connector**, paste `https://humansfix.ai/mcp` and give it a name.

Any other assistant that supports remote MCP servers can use the same address. Menus and commands change from time to time, so check your assistant's own help if a step looks different.

## What happens when your agent uses it

1. Your agent asks you. It should ask for your permission and for your email address before it does anything.
2. It sends us a short summary of the problem and your email. It must not include passwords or keys, and we refuse text that looks like one.
3. We email you a code. The request stays private, and no developer sees it, until you enter that code on our confirmation page.
4. A developer proposes a time. You confirm it and join a free video call.
5. The problem is solved on the call, or you get one fixed price. You accept it or say no, and you pay only after you approve the finished work.

## What we keep, and what we never do

- We keep the summary and your email, like any request made on our site.
- We never see your code, your files or your conversation with the agent. We only get what the agent chooses to send.
- Nothing is published and nobody is contacted until you confirm.
- The connector never charges anything and never handles payment. If you pay for work later, it happens on our website, after you approve.
- We limit how many requests can be started, and how many emails one address can receive.
- If your email already has an account on humans fix ai, the agent tells you to sign in on the website instead.

## The tool

The connector has one tool, `ask_human_developer`. The full definition, as the server returns it, is in [`docs/tool-schema.json`](docs/tool-schema.json).

| Argument | Required | Description |
|---|---|---|
| `summary` | yes | What the person needs, in plain words: what is wrong, what they were doing and what has been tried. 30 to 2000 characters. No secrets. |
| `email` | yes | The person's own email address. We send a confirmation code there. |
| `tool` | no | The AI tool the app was built with: `lovable`, `bolt`, `v0`, `replit`, `cursor`, `claude-code`, `codex`, `windsurf`, `base44` or `other`. |
| `availability` | no | When the person is free for a call, for example "weekdays after 5pm CET". |

The tool starts a draft request and emails a confirmation code to the person. It does not publish anything. Errors come back as tool results with `isError` set, so the model can correct itself.

## Check that it works

```bash
curl -s -X POST https://humansfix.ai/mcp \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

The answer lists one tool, `ask_human_developer`. The connector is stateless. It speaks the 2026-07-28 revision of MCP and also accepts the older `initialize` handshake from clients that use 2025-11-25, 2025-06-18, 2025-03-26 or 2024-11-05.

Calling the tool sends a real email to the address you give it, so use your own address when you test.

## Contact and security

Questions and problems: hello@humansfix.ai. To report a security issue, see [SECURITY.md](SECURITY.md).

## License

The documentation and examples in this repository are released under the [MIT License](LICENSE). The humans fix ai service itself is operated under its own [terms](https://humansfix.ai/terms) and [privacy policy](https://humansfix.ai/privacy).
