import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';
// import devtools from 'solid-devtools/vite';

export default defineConfig({
  publicDir: "/assets/",
  plugins: [solidPlugin()],
  server: { port: 3000 },
  build: { target: 'esnext' },
});
