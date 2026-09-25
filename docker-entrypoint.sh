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

npm run db:migrate:local

exec npx wrangler dev \
  --config dist/yard_sale_gold/wrangler.json \
  --ip 0.0.0.0 \
  --port "${PORT}" \
  --local \
  --show-interactive-dev-session=false
