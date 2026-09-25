# Yard Sale Gold

An installable browser/PWA scanner that samples frames from a live camera or uploaded garage-sale footage, sends them to GPT-5.6 Luna through the OpenAI Agents SDK, values visible items, and streams finds into a mobile-first UI.

## Stack

- React 19 + Vite + TypeScript
- TanStack Router for URL-driven navigation and TanStack Query for server-state caching
- Cloudflare Workers and the Cloudflare Vite plugin
- OpenAI Agents SDK with `gpt-5.6-luna` (OpenAI or OpenRouter keys supported)
- Drizzle ORM + Cloudflare D1
- Cloudflare R2 thumbnails
- Vite PWA service worker and manifest

## Run locally

1. Copy `.dev.vars.example` to `.dev.vars` and set your API key:

   ```dotenv
   OPENAI_API_KEY=your_real_project_key
   ```

2. Install dependencies and apply local D1 migrations:

   ```bash
   npm install
   npm run db:migrate:local
   ```

3. Start the dev server:

   ```bash
   npm run dev
   ```

4. Open `http://127.0.0.1:5174/scan`. Select a camera for live scanning or snapshots, or upload a photo/video. You can keep garage-sale clips in the ignored local `yard-sale-footage/` folder; footage is not included in this repository.

The browser samples compressed frames at a configurable 1–30 second interval and allows up to 100 analyses in flight. Frame images are not bundled with the app.

### Dev over Tailscale or a tunnel

If you access the Vite dev server through another hostname, copy `.env.example` to `.env` and set:

```dotenv
VITE_ALLOWED_HOSTS=your-hostname.example.com,.tailscale.net
```

API keys stay in `.dev.vars`, not `.env`.

## Docker (incl. Synology)

Uses the same `.dev.vars` file as local development:

```bash
cp .dev.vars.example .dev.vars   # add OPENAI_API_KEY
docker compose up -d --build
# → http://localhost:5174   (health: /api/health)
```

On a Synology (Container Manager / DSM 7.2+):

1. Clone this repo to the NAS (e.g. `/volume1/docker/yard-sale-gold`).
2. Copy `.dev.vars.example` to `.dev.vars` and add your API key.
3. Create a project from `docker-compose.yml` (or set `OPENAI_API_KEY` in the project environment instead of using a file).
4. Expose host port **5174**. Change only the left side of `"5174:5174"` if needed.
5. For HTTPS + a custom domain: DSM **Reverse Proxy** → forward the hostname to `localhost:5174`.

## Routes and state

- `/scan` — camera, snapshots, uploads, and the live findings feed
- `/history` — saved inventory
- `/finds/:itemId?from=scan|history` — shareable item detail modal with its originating view preserved
- `/finds/:itemId/activity?from=scan|history` — the persisted agent activity for the item's latest frame

TanStack Query owns remote stats and inventory data. Camera streams, capture timers, in-flight frame work, and the current live feed remain local React state because they are ephemeral browser state.

## Useful commands

```bash
npm test                 # deterministic unit tests
npm run build            # type-check and production build
npm run dev:fresh        # kill stale dev server, migrate, restart
npm run cf-typegen       # regenerate Worker binding types
npm run db:generate      # generate a migration after schema changes
npm run db:migrate:local # apply migrations to local D1
npm run docker:up        # build and start Docker stack
```

## Agent workflow

Each frame starts one bounded agent run. The agent:

1. Identifies distinct sellable objects and reads visible price tags.
2. Calls `check_previous_scans` against D1 for semantic fingerprint matches.
3. Searches manufacturers and retailers alongside eBay active listings, using store evidence as the primary retail baseline and eBay as secondary market evidence.
4. Returns structured retail, active-listing, sold-comparable, and resale-range data.
5. Returns normalized item coordinates and draws bounding boxes over saved frames.
6. Persists new or repeated detections atomically. Exact fingerprints are unique, with conservative token-overlap matching to absorb wording changes such as “metal-and-glass console table” versus “glass-top console table.”
7. Stores a sanitized per-frame audit record containing prompts, ordered run items, tool calls and results, raw model responses, final structured output, and usage. API keys, raw base64 images, encrypted reasoning, and hidden reasoning content are excluded.

The UI reports cumulative frames processed, items identified, searches performed, and underlying model calls. See [FEATURES.md](./FEATURES.md) for live-feed tracking, natural-language filters, eBay integration, and batch processing.

## Cloudflare Workers deploy

Docker self-hosting uses local D1/R2 bindings in `wrangler.jsonc` and does not need Cloudflare routes.

To deploy to Cloudflare Workers instead:

1. Create a D1 database and R2 bucket in your Cloudflare account.
2. Update `database_id`, bucket names, and add a `routes` entry for your custom domain in `wrangler.jsonc`.
3. Apply remote migrations: `npm run db:migrate:remote`
4. Set secrets: `wrangler secret put OPENAI_API_KEY`
5. Deploy: `npm run deploy`
