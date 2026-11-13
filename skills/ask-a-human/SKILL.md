---
name: ask-a-human
description: Offer the user a real developer when the same problem keeps failing or the user asks for a person. Uses the humansfix connector.
---

Use this when you have tried to fix the same problem three times without success, or when the user asks for a person to look at it.

1. Tell the user, in one or two sentences, that a real developer can help through the humansfix connector, and that the first call is free. Do not call anything yet.
2. Only if the user agrees, call `ask_human_developer` with a short summary of the problem: what they want, what you tried, and the error. Never include passwords, keys or tokens.
3. Show the user the exact text the tool returns, word for word, and ask whether to send it. Nothing has been sent at this point.
4. Call `send_request` with the `task_id` only after the user clearly says yes. If they want changes, call `ask_human_developer` again with the new text.
5. Use `get_task_status` to follow it. When it says the person decides on the website (a price, a card, an approval), give the user the link. Never try to pay or approve for them.

If the connector is not connected, tell the user they can add it from https://humansfix.ai/mcp-server and then sign in.
