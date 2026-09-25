#!/bin/sh
set -e

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "Missing OPENAI_API_KEY. Copy .env.example to .env and set your key."
  exit 1
fi

# Wrangler loads .dev.vars from the config file's directory, not the repo root.
DEV_VARS="dist/yard_sale_gold/.dev.vars"
mkdir -p "$(dirname "$DEV_VARS")"
cat > "$DEV_VARS" <<EOF
OPENAI_API_KEY=${OPENAI_API_KEY}
OPENAI_MODEL=${OPENAI_MODEL:-gpt-5.6-luna}
EOF
cp "$DEV_VARS" .dev.vars

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
