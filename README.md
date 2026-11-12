# humans fix ai: MCP connector

**Give your AI coding agent a human to call.**

When Claude Code, Codex, Cursor or another assistant reaches something it cannot solve on its own, it can ask a real developer to help you, and follow the request through to the free call. You connect once, you stay in charge, and nothing is charged.

- Website and setup page: <https://humansfix.ai/mcp-server>
- Connector address: `https://humansfix.ai/mcp` (Streamable HTTP, sign in once with Google)
- Server card: <https://humansfix.ai/mcp/server-card>
- Official MCP Registry name: `ai.humansfix/humansfix`

This repository holds the documentation and examples. The server itself runs at humansfix.ai, and its source code is not published here.

## What it does

AI coding agents are very good until they are not. A requirement is unclear, a change is risky, a bug will not reproduce, or you just want a person to look over what the agent built. Connect humans fix ai and your agent can do three things:

- **Ask a human developer.** It writes a short summary of the problem.
- **See where your request stands** and what happens next.
- **Answer a call time**: accept the time a developer proposed, say it does not work, or propose another time for a booked call.

Your agent asks you first. Nothing reaches a developer until it has shown you the exact text and you have said yes. A developer then proposes a time for a free video call, and most problems are solved there. If more work is needed, you get one fixed price and decide whether to accept it on our website. You pay only after you approve the result.

## Connect it

The first time your assistant uses the connector, it opens a page on our site: choose **Continue with Google** and press Allow. That is the whole sign-in. No password, no key.

**Claude Code**

```bash
claude mcp add --transport http humansfix https://humansfix.ai/mcp
```

Then run `/mcp` in Claude Code, choose **humansfix** and sign in.

**Codex**

```bash
codex mcp add humansfix --url https://humansfix.ai/mcp
codex mcp login humansfix
```

Or add this to `~/.codex/config.toml` (see [`examples/codex-config.toml`](examples/codex-config.toml)) and then run the login command:

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

Open **Settings**, then **Connectors**, choose **Add custom connector**, paste `https://humansfix.ai/mcp` and give it a name. Under Authentication choose **Sign in now**. The detected "No sign-in" is not right for this connector, because calling a tool needs you to be signed in.

Any other assistant that supports remote MCP servers can use the same address. Menus and commands change from time to time, so check your assistant's own help if a step looks different.

## What happens when your agent uses it

1. Your agent asks for your permission before it does anything.
2. It sends us a short summary of the problem. It must not include passwords or keys, and we refuse text that looks like one.
3. Your agent shows you the exact text it saved. The request stays private, and no developer sees it, until you say yes and your agent sends it. We email you a copy with a link to cancel it.
4. A developer proposes a time. Your agent can show it to you, and you confirm it, or say it does not work, right in the chat. You get a calendar invite and reminders by email.
5. The free video call. The problem is solved there, or you get one fixed price. Accepting a price, adding a card and approving the work always happen on our website, and your agent gives you the link.

## What your agent can and cannot do

**It can** start a request for you, show where your requests stand and what happens next, accept a call time, say a time does not work, and propose another time for a booked call.

**It cannot** pay, accept a price, approve work, send a thank-you, report a problem, see anyone else's requests, or see anything on your account beyond your own requests.

You can disconnect it at any time in **Settings**, under **Connected assistants**. It stops working at once. We also email you whenever a new assistant is connected, so you notice one you did not expect.

## What we keep, and what we never do

- We keep the summary and your email, like any request made on our site.
- We keep a record that you connected your assistant: its name, when you connected it, when it last used the connection, and what it may do. It lasts until you disconnect it. Its access keys are stored only in a form nobody can read back.
- We never see your code, your files or your conversation with the agent. We only get what the agent chooses to send.
- Nothing is published and nobody is contacted until you have read the text and said yes.
- The connector never charges anything and never handles payment.
- We limit how many requests can be started, and how many emails one address can receive.

## For people building assistants

The connector is a stateless MCP server over Streamable HTTP that answers with JSON. It speaks the 2026-07-28 revision and also accepts the older `initialize` handshake from clients that use 2025-11-25, 2025-06-18, 2025-03-26 or 2024-11-05. `initialize` and `tools/list` need no token, so the tools can be discovered. Calling a tool needs one.

### Signing in

A call without a valid token gets `401` with a `WWW-Authenticate` header whose `resource_metadata` points to `/.well-known/oauth-protected-resource/mcp` (RFC 9728). That names the authorization server, whose metadata is at `/.well-known/oauth-authorization-server` (RFC 8414).

- OAuth 2.1 authorization code with PKCE, `S256` only. Public clients: there is no client secret.
- An app identifies itself either with a **Client ID Metadata Document** (the `client_id` is an https address that serves a small JSON document naming the app and its redirect addresses) or by registering at `/oauth/register` (RFC 7591).
- Redirect addresses must be https, an address on the person's own computer (any port), or a private app scheme such as `cursor://`.
- Send the `resource` parameter (RFC 8707) with the connector's address. Scopes are `tasks.read` and `tasks.write`.
- Access tokens last an hour. A refresh token works once and is replaced when used. Using one a second time ends the permission.
- A missing permission is `403` with `insufficient_scope`.

### The tools

The full definitions, as the server returns them, are in [`docs/tool-schema.json`](docs/tool-schema.json).

| Tool | Needs | Arguments | What it does |
|---|---|---|---|
| `ask_human_developer` | `tasks.write` | `summary` (required, 30 to 2000 characters, no secrets); `tool`, `availability` (optional) | Only saves a draft and returns the exact text, which the agent shows the person. Nothing reaches a developer. |
| `send_request` | `tasks.write` | `task_id` (required) | Sends the draft this connection saved in the last 30 minutes, after the person said yes. A person can send a few per day, and we email them a copy with a link to cancel. |
| `get_task_status` | `tasks.read` | `task_id` (optional) | Returns a fixed `state`, a `next_action`, the call time in the person's own time zone, and a link to our page. It never returns text a developer wrote. |
| `respond_to_call_time` | `tasks.write` | `task_id`, `action` (`accept`, `decline`, `propose_other_time`), `time` (ISO 8601 with an offset, only for `propose_other_time`) | Answers a proposed call time, or proposes a new one for a booked call. |

`next_action` is one of `send_request`, `respond_to_call_time`, `person_decides_on_website`, `join_call`, `wait` or `none`. Errors come back as tool results with `isError` set, so the model can correct itself. Prices, cards, approvals and tips are not part of the connector.

### Check that it works

```bash
curl -s -X POST https://humansfix.ai/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

The answer lists four tools. Calling one without a token returns `401` with the sign-in pointer described above.

## Contact and security

Questions and problems: hello@humansfix.ai. To report a security issue, see [SECURITY.md](SECURITY.md).

## License

The documentation and examples in this repository are released under the [MIT License](LICENSE). The humans fix ai service itself is operated under its own [terms](https://humansfix.ai/terms) and [privacy policy](https://humansfix.ai/privacy).
