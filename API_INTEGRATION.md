# API & Integrations — Mi-Todo

Este documento describe las API que necesitarás e instrucciones paso a paso para conectar Supabase, Stripe (pagos), integraciones de salud (Google Fit / Apple Health) y notificaciones push.

## 1) Supabase (recomendado)
### ¿Qué ofrece?
- Autenticación (email / magic link)
- Postgres con Row Level Security (RLS)
- Storage (fotos)
- Edge Functions (opcional)

### Tablas importantes (ya incluidas en `db/001_init.sql`)
- tenants, users, transactions, meals, workouts, habits, goals

### Pasos para conectar Supabase al frontend
1. Crea un proyecto en https://app.supabase.com
2. En `Project Settings -> API` copia `anon public` key y `supabase URL`.
3. En tu app, crea un archivo `.env` con:
   ```env
   VITE_SUPABASE_URL=https://xyz.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJ...
   ```
4. Reinicia el dev server. La app detectará `isSupabaseEnabled` y usará Supabase para leer/escribir datos.
5. Crea las tablas ejecutando `db/001_init.sql` en el SQL editor de Supabase. Ejecuta `db/001_seed.sql` para datos demo.

### RLS & Security
- Implementa políticas RLS por `user_id` y `tenant_id`. En el SQL hay un ejemplo usando `auth.uid()`.
- Para tareas administrativas (seed/migrations) usa la `service_role` key desde supabase (NO expongas esta key en el frontend).

### Endpoints/Funciones que usaremos en el frontend
- `supabase.auth.signInWithOtp({ email })` — magic link sign-in.
- `supabase.from('transactions').select('*')` — leer datos.
- `supabase.from('transactions').insert([payload])` — crear registros.

## 2) Sincronización offline (qué se implementó)
- Usamos `localforage` para almacenar datos locales y una cola de mutaciones en la clave `mi_todo_queue`.
- Al montar la app y al volver online (`window.online`), la app ejecuta `api.processQueue()` que intenta enviar las mutaciones pendientes a Supabase.
- Las mutaciones se encolan con `{ op, entity, payload }` y si Supabase no está disponible se quedan en la cola.

## 3) Export / Import
- CSV: usamos `papaparse` para generar CSV desde arrays de objetos.
- JSON: exportación simple con `JSON.stringify`.
- PDF: usamos `html2canvas` + `jspdf` para exportar una captura de la pantalla como PDF (puedes crear reportes más sofisticados en el servidor).

## 4) Pagos (Stripe) — Preparación para SaaS
- Recomendado flujo:
  - Backend (serverless) con endpoints que creen `checkout.sessions` con la secret key de Stripe.
  - Webhook endpoint para escuchar `checkout.session.completed` y actualizar `users`/`tenants` con plan/role.
- En frontend: usar `stripe-js` para redirigir al checkout.
- Nota: **No incluyo keys de Stripe en el repo**. Añadir un microservicio o Edge Function para manejar pagos es lo recomendado.

## 5) Integraciones de Salud (Google Fit / Apple Health)
- Google Fit: requiere OAuth2 y uso de Google APIs para leer datos (pasos, calorías). Debes crear proyecto en Google Cloud Console, configurar OAuth consent, y un backend que maneje tokens para cada usuario.
- Apple Health: la integración se realiza mayormente a través de la app iOS (HealthKit) y requiere un bridge nativo o usar HealthKit -> servidor sync (más complejo).

## 6) Notificaciones Push
- Web Push: usar `service worker` + `Push API`. Necesitas VAPID keys y un servicio para enviar notificaciones (p. ej. web-push npm package).
- Push móvil: usar Firebase Cloud Messaging (FCM) o servicios como OneSignal.

## 7) Panel Admin & Roles
- Añade `role` o `is_admin` en la tabla `users` o administra roles por `tenant`.
- Panel admin puede listar usuarios, ver métricas y administrar planes (Stripe).

## 8) Resumen rápido de endpoints/client usage (frontend)
- `api.getTransactions()` — obtiene transacciones (supabase or localforage)
- `api.addTransaction(t)` — añade transacción y encola si offline
- `api.getEntity('meals')` / `api.addEntity('meals', payload)` — CRUD genérico para módulos
- `api.processQueue()` — fuerza el envío de la cola al backend

---
Si quieres, puedo also generar un pequeño `edge function` o serverless example para manejar Stripe checkout y un ejemplo de integración Google OAuth para Google Fit (sin keys, solo el boilerplate).

---

## Snippets de código (frontend) — dónde y cómo añadir user_id / tenant_id
A continuación ejemplos concretos que puedes copiar en tu frontend cuando prepares el payload antes de insertar en Supabase.

```ts
// Obtener la sesión y user_id (Supabase v2)
const session = await supabase.auth.getSession();
const user = session.data.session?.user; // user.id es el uuid
const userId = user?.id; // ejemplo: '123e4567-e89b-12d3-a456-426614174000'
// Si guardaste tenant_id en user_metadata al crear el usuario:
const tenantId = (user as any)?.user_metadata?.tenant_id;

// Ejemplo al crear una transacción
const tx = {
  id: 'tx_' + Math.random().toString(36).slice(2,9),
  user_id: userId,
  tenant_id: tenantId,
  name: 'Café',
  amount: 3.5,
  type: 'expense',
  category: 'Alimentos',
  date: new Date().toISOString(),
  currency: 'USD'
};

await supabase.from('transactions').insert([tx]);
```

## Políticas RLS recomendadas (ejemplo rápido)
En Supabase SQL editor, después de crear las tablas, activa RLS y añade políticas como:

```sql
-- Para que sólo el usuario propietario vea/edite sus filas
create policy "users_own_rows" on transactions for all using (auth.uid() = user_id::text);
```

Ajusta las políticas para `tenant_id` si manejas multi-tenant: por ejemplo permitir acceso a filas donde tenant_id = current_setting('request.jwt.claims.tenant_id')::uuid (si configuras claims de JWT).
