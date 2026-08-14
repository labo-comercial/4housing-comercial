-- 2026-08-02-cierres-mensuales.sql
-- Cierre mensual de indicadores comerciales + registro histórico.
--
-- Dos piezas:
--   1) cotizaciones.fecha_estado  → cuándo pasó a ganada/perdida (para contar
--      "ganadas/perdidas del mes" por fecha real, no por fecha de creación).
--   2) cierres_mensuales           → foto congelada de los indicadores por mes y
--      unidad. Inmutable (la app solo inserta meses que faltan; recalcular es
--      una acción explícita).
--
-- Correr en el SQL Editor de Supabase (proyecto wcpkpwxhqdcdljfwzcmy).
-- Es idempotente: se puede correr más de una vez sin romper nada.

-- ===========================================================================
-- 1 · fecha_estado en cotizaciones
-- ===========================================================================
alter table public.cotizaciones
  add column if not exists fecha_estado timestamptz;

comment on column public.cotizaciones.fecha_estado is
  'Momento en que la cotización pasó a ganada/perdida. Se usa para los cierres '
  'mensuales por fecha real. NULL en las cerradas antes de esta feature → la app '
  'cae a created_at como aproximación.';

-- Backfill aproximado para las que YA están ganadas/perdidas (histórico):
-- se usa updated_at (última modificación ≈ cierre del trato) o, si no hay,
-- created_at. Este UPDATE no cambia "estado", así que no dispara el trigger.
update public.cotizaciones
   set fecha_estado = coalesce(updated_at, created_at)
 where estado in ('ganada','perdida')
   and fecha_estado is null;

-- Trigger: al pasar a ganada/perdida (y solo entonces), sella la fecha.
create or replace function public.cotizacion_sella_fecha_estado()
returns trigger
language plpgsql
as $$
begin
  if (new.estado is distinct from old.estado) and new.estado in ('ganada','perdida') then
    new.fecha_estado := now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_cotizacion_fecha_estado on public.cotizaciones;
create trigger trg_cotizacion_fecha_estado
  before update on public.cotizaciones
  for each row execute function public.cotizacion_sella_fecha_estado();

-- ===========================================================================
-- 2 · cierres_mensuales
-- ===========================================================================
create table if not exists public.cierres_mensuales (
  periodo     text        not null,                      -- 'YYYY-MM'
  unidad      text        not null,                      -- 'rental' | 'ventas'
  indicadores jsonb       not null default '{}'::jsonb,  -- todos los KPIs congelados
  tipo        text        not null default 'auto',       -- 'auto' | 'manual'
  cerrado_por text,                                       -- email de quien lo cerró/recalculó
  cerrado_en  timestamptz not null default now(),
  primary key (periodo, unidad)
);

comment on table public.cierres_mensuales is
  'Foto congelada de los indicadores comerciales por mes y unidad. Los de FLUJO '
  '(del mes) son exactos; los de STOCK (a fin de mes) son la foto al momento de '
  'cerrar (cerrado_en dice cuándo se tomó).';

alter table public.cierres_mensuales enable row level security;

-- Mismo criterio que el CRM endurecido: solo el sector fhcomercial.
drop policy if exists cierres_mensuales_fhcomercial on public.cierres_mensuales;
create policy cierres_mensuales_fhcomercial on public.cierres_mensuales
  for all to authenticated
  using (public.tiene_sector('fhcomercial'))
  with check (public.tiene_sector('fhcomercial'));
