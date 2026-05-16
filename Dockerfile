# Render deployment wrapper for MCP Telegram Cloud
# This keeps this repo small while building the upstream server from source.
# Pin UPSTREAM_REF to a release tag or commit for production stability.

FROM node:22-alpine AS telegram-lib
RUN apk add --no-cache git python3 make g++
RUN git clone --depth 1 https://github.com/mcp-telegram/mcp-telegram.git /telegram
WORKDIR /telegram
RUN npm ci && npm run build

FROM node:22-alpine AS builder
WORKDIR /app
ARG UPSTREAM_REPO=https://github.com/mcp-telegram/mcp-telegram-cloud.git
ARG UPSTREAM_REF=main
RUN apk add --no-cache git
RUN git clone --depth 1 --branch ${UPSTREAM_REF} ${UPSTREAM_REPO} /src || \
    (git clone --depth 1 ${UPSTREAM_REPO} /src && cd /src && git fetch --depth 1 origin ${UPSTREAM_REF} && git checkout FETCH_HEAD)
WORKDIR /src
RUN npm install --no-audit --no-fund --omit=dev --ignore-scripts
RUN rm -rf node_modules/@overpod/mcp-telegram
COPY --from=telegram-lib /telegram /src/node_modules/@overpod/mcp-telegram

FROM oven/bun:1.3.13-alpine
WORKDIR /app
COPY --from=builder /src/node_modules ./node_modules
COPY --from=builder /src/package.json ./
COPY --from=builder /src/src ./src
COPY --from=builder /src/scripts ./scripts
COPY --from=builder /src/tsconfig.json ./
RUN mkdir -p /app/data
ENV NODE_ENV=production
ENV PORT=3000
ENV MCP_TELEGRAM_ENABLE_GROUP_CALLS=1
ENV MCP_TELEGRAM_ENABLE_QUICK_REPLIES=1
EXPOSE 3000
VOLUME ["/app/data"]
CMD ["bun", "src/server.tsx"]
