# syntax=docker/dockerfile:1

FROM node:22-bookworm-slim

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=5174

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates tini \
  && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci && npm cache clean --force

COPY . .

RUN npm run build \
  && chmod +x /app/docker-entrypoint.sh

# OPENAI_API_KEY is supplied at runtime — never baked into the image.
EXPOSE 5174

ENTRYPOINT ["/usr/bin/tini", "--", "/app/docker-entrypoint.sh"]
