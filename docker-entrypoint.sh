#!/bin/sh
set -e

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "Missing OPENAI_API_KEY. Copy .env.example to .env and set your key."
  exit 1
fi

# Wrangler reads secrets from .dev.vars during local dev.
cat > .dev.vars <<EOF
OPENAI_API_KEY=${OPENAI_API_KEY}
OPENAI_MODEL=${OPENAI_MODEL:-gpt-5.6-luna}
EOF

# Migrations must use the same wrangler config as the running server.
# Applying against the root wrangler.jsonc targets a different local D1 file.
npx wrangler d1 migrations apply yard-sale-gold-db \
  --local \
  --config dist/yard_sale_gold/wrangler.json

exec npx wrangler dev \
  --config dist/yard_sale_gold/wrangler.json \
  --ip 0.0.0.0 \
  --port "${PORT}" \
  --local \
  --show-interactive-dev-session=false
