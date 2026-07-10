-- ============================================================
-- RENTAL DASHBOARD - Schema Supabase
-- Ejecutar en: Supabase > SQL Editor > New query
-- ============================================================

-- 1. TABLA PRINCIPAL DE DATOS RENTAL
create table if not exists public.rental_data (
  id bigint generated always as identity primary key,
  serie text,
  cliente text,
  tipologia text,
  modelo_negocio text,
  anio integer,
  mes text,
  mes_anio text,
  moneda text,
  importe_mensual numeric,
  estado_serie text,
  tipo_cambio numeric,
  importe_pesos numeric,
  created_at timestamptz default now()
);

-- 2. TABLA DE CHAT INTERNO
create table if not exists public.chat_messages (
  id bigint generated always as identity primary key,
  user_email text not null,
  user_name text,
  message text not null,
  created_at timestamptz default now()
);

-- 3. TABLA DE NOTIFICACIONES
create table if not exists public.notifications (
  id bigint generated always as identity primary key,
  title text not null,
  body text not null,
  created_at timestamptz default now()
);

-- 4. HABILITAR REALTIME en chat y notificaciones
alter publication supabase_realtime add table public.chat_messages;
alter publication supabase_realtime add table public.notifications;

-- 5. ROW LEVEL SECURITY - permitir lectura/escritura a usuarios autenticados
alter table public.rental_data enable row level security;
alter table public.chat_messages enable row level security;
alter table public.notifications enable row level security;

create policy "Autenticados pueden leer rental_data"
  on public.rental_data for select
  to authenticated using (true);

create policy "Autenticados pueden leer mensajes"
  on public.chat_messages for select
  to authenticated using (true);

create policy "Autenticados pueden escribir mensajes"
  on public.chat_messages for insert
  to authenticated with check (true);

create policy "Autenticados pueden leer notificaciones"
  on public.notifications for select
  to authenticated using (true);

-- 6. INDICES para mejorar performance de filtros
create index if not exists idx_rental_modelo on public.rental_data(modelo_negocio);
create index if not exists idx_rental_mes on public.rental_data(mes_anio);
create index if not exists idx_rental_estado on public.rental_data(estado_serie);
