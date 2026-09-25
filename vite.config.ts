import { cloudflare } from "@cloudflare/vite-plugin";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";

const defaultAllowedHosts = [
  "ysg.christianboyle.com",
  "local.wesbos.com",
  "desktop-ngpp4sj.tail79512.ts.net",
  ".tail79512.ts.net",
];

const extraAllowedHosts =
  process.env.VITE_ALLOWED_HOSTS?.split(",")
    .map((host) => host.trim())
    .filter(Boolean) ?? [];

export default defineConfig({
  server: {
    host: true,
    port: 5174,
    strictPort: true,
    // Funnel can't relay Vite's HMR WebSocket; a broken socket reloads Safari on mobile.
    hmr: false,
    allowedHosts: [...new Set([...defaultAllowedHosts, ...extraAllowedHosts])],
  },
  plugins: [
    react(),
    cloudflare(),
    VitePWA({
      devOptions: { enabled: false },
      registerType: "autoUpdate",
      manifest: {
        name: "Yard Sale Gold",
        short_name: "Gold",
        description: "Spot valuable finds with GPT-5.6 Luna.",
        theme_color: "#11110f",
        background_color: "#f4f0e6",
        display: "standalone",
        start_url: "/scan",
        icons: [
          { src: "/icon.svg", sizes: "any", type: "image/svg+xml", purpose: "any maskable" },
        ],
      },
      workbox: {
        navigateFallback: "/index.html",
        navigateFallbackDenylist: [/^\/api\//],
        globPatterns: ["**/*.{js,css,html,svg,woff2}"],
      },
    }),
  ],
});
