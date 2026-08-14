-- 2026-08-14-diagnostico-fechas.sql
-- Diagnóstico (SOLO LECTURA) para saber si hay fechas guardadas en formato no-ISO
-- (ej. "18 de agosto de 2026" o "18/08/2026") en cotizaciones y oportunidades.
--
-- Correr en el SQL Editor de Supabase y pasarme el resultado. Con eso escribo el
-- UPDATE exacto para normalizarlas a ISO (YYYY-MM-DD). NO modifica nada.

-- 1) Tipo de dato de las columnas de fecha (date vs text).
--    Si son 'date', ya están normalizadas y no hay nada que migrar.
select table_name, column_name, data_type
from information_schema.columns
where (table_name = 'cotizaciones'  and column_name in ('fecha_iso','fecha_envio'))
   or (table_name = 'oportunidades' and column_name = 'fecha_limite')
order by table_name, column_name;

-- 2) Cotizaciones cuya fecha_iso NO empieza con YYYY-MM-DD (texto raro).
select id, ref, fecha_iso
from public.cotizaciones
where fecha_iso is not null
  and fecha_iso::text !~ '^\d{4}-\d{2}-\d{2}'
order by ref;

-- 3) Oportunidades cuya fecha_limite NO empieza con YYYY-MM-DD.
select id, ref, fecha_limite
from public.oportunidades
where fecha_limite is not null
  and fecha_limite::text !~ '^\d{4}-\d{2}-\d{2}'
order by ref;
