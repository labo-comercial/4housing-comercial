-- ============================================================================
-- Cotizaciones: columnas "Proyecto" (texto libre) y "Fecha de envío"
-- ============================================================================
-- Correr en el SQL Editor del proyecto Supabase (wcpkpwxhqdcdljfwzcmy).
-- Aditivo e idempotente. Después se deploya el index.html que las usa.
--   · proyecto     : referencia libre del proyecto (la escribe el comercial).
--   · fecha_envio  : se setea sola cuando la cotización pasa a "Cotizado-Enviado".
-- ============================================================================
alter table public.cotizaciones
  add column if not exists proyecto    text,
  add column if not exists fecha_envio timestamptz;
