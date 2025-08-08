# Mi-Todo (Tracker de Vida) — Demo Scaffold

Este repo contiene un scaffold que extiende el proyecto inicial de tracker financiero hacia **Mi‑Todo**, un tracker de vida con módulos: finanzas, comidas, entrenamientos, hábitos y metas.

## Qué hay implementado (Fase 1)
- UI mobile-first con Tailwind (componentes añadidos).
- Vista unificada `MiTodoView` y FAB para añadir elementos rápido.
- Módulos: `meals`, `workouts`, `habits`, `goals` con forms y listas (funcionamiento local/mock state).
- `OfflineBanner`, `SyncStatus` y `BottomNav`.
- Scaffold para Supabase client (`src/lib/supabaseClient.ts`) y React Query (`src/lib/reactQuery.ts`).
- PWA plugin añadido en `vite.config.ts` (config básica).

## Correr localmente (vista previa)
1. Instala dependencias:
   ```bash
   npm install
   ```
2. Inicia el servidor de desarrollo:
   ```bash
   npm run dev
   ```
3. Abre `http://localhost:5173` (o la URL que dev muestre).

## Conectar Supabase (opcional)
Agrega las variables en `.env`:
```
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
```

## Deploy rápido en Vercel
1. Conecta este repo a Vercel (o crea un nuevo proyecto).  
2. Usa `npm run build` como build command y la carpeta `dist` como output.  
3. Agrega variables de entorno en Vercel para Supabase.

## Notas
- Este scaffold usa state local para la mayoría de los módulos; la integración completa con Supabase/Stripe se hará en siguientes iteraciones.
- Las imágenes PWA en `public/` son placeholders; reemplázalas con assets reales para publicar.