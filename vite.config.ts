import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), VitePWA({ manifest: { name: 'Mi‑Todo', short_name: 'MiTodo', start_url: '/', display: 'standalone', background_color: '#ffffff', theme_color: '#6366f1', icons: [{src: '/pwa-192.png', sizes: '192x192', type: 'image/png'},{src:'/pwa-512.png', sizes:'512x512', type:'image/png'}] } })],
{
  plugins: [react()],
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
});
