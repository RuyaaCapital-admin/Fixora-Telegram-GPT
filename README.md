# Fixora Telegram GPT

Deployable wrapper for [`mcp-telegram/mcp-telegram-cloud`](https://github.com/mcp-telegram/mcp-telegram-cloud) on Render.

This repo intentionally stays small: the Docker build pulls the upstream MCP Telegram Cloud source and builds it into a production container.

## What this gives you

- ChatGPT custom MCP server endpoint at `/mcp`
- Telegram QR login through OAuth
- Read/search/summarize Telegram tools
- Safe-state-change tools only by upstream default
- No Telegram send/post tools enabled by default

## Important limitation

This cloud server is **not for posting to Telegram channels by default**. It is mainly for reading/searching Telegram safely from ChatGPT/Claude. If you want posting later, add a separate reviewed write tool with approval gates.

## Required environment variables

Copy `.env.example` and fill these in Render:

```env
TELEGRAM_API_ID=
TELEGRAM_API_HASH=
ISSUER=https://your-render-service.onrender.com
ADMIN_TOKEN=
DATABASE_PATH=/app/data/cloud.db
MCP_TELEGRAM_TELEMETRY=local-only
LOG_HASH_SALT=
```

Get `TELEGRAM_API_ID` and `TELEGRAM_API_HASH` from: https://my.telegram.org/apps

Generate secrets locally:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Use one value for `ADMIN_TOKEN` and another value for `LOG_HASH_SALT`.

## Render deployment

1. Render -> **New** -> **Web Service**
2. Connect this GitHub repo: `RuyaaCapital-admin/Fixora-Telegram-GPT`
3. Environment: **Docker**
4. Branch: `main`
5. Root directory: leave empty
6. Add a persistent disk:
   - Mount path: `/app/data`
   - Size: 1GB minimum
7. Add environment variables from `.env.example`
8. Deploy

After deploy, check:

```text
https://your-render-service.onrender.com/
https://your-render-service.onrender.com/mcp
```

The `/mcp` endpoint is the URL you add inside ChatGPT custom MCP server settings.

## ChatGPT connection URL

```text
https://your-render-service.onrender.com/mcp
```

## Production notes

- Do not commit `.env`.
- Keep `DATABASE_PATH=/app/data/cloud.db` on Render with a persistent disk.
- Keep telemetry as `local-only` unless you intentionally configure OTLP/SigNoz.
- Do not expose write/post Telegram tools without approval flow.
- For production stability, pin `UPSTREAM_REF` in the Dockerfile to a specific release tag/commit later.
