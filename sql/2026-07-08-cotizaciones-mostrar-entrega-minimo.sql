-- Migración: puntos 04 (Plazo de entrega) y 05 (Plazo mínimo de alquiler)
-- opcionales en la plantilla de cotización.
--
-- Ejecutar MANUALMENTE en el SQL Editor de Supabase, ANTES de desplegar el
-- index.html actualizado (index.html ya espera mostrar_entrega/mostrar_minimo
-- con estas columnas presentes en la tabla).

alter table public.cotizaciones
  add column if not exists mostrar_entrega boolean not null default true,
  add column if not exists mostrar_minimo  boolean not null default true;
