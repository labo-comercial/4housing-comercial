-- ============================================================================
-- Cotizaciones: guardar el link de la carpeta de SharePoint del proyecto
-- ============================================================================
-- Correr en el SQL Editor de wcpkpwxhqdcdljfwzcmy. Aditivo. Después deploy HTML.
alter table public.cotizaciones
  add column if not exists sharepoint_url text;
