-- Carga de base de prospección: Minería, Petróleo y Energía (Federal)
-- Fuente: Matriz_Maestra_Federal_Mineria_Petroleo_Energia_4_HOUSING.xlsx (aportada por el usuario)
--
-- Ejecutar MANUALMENTE en el SQL Editor de Supabase.
--
-- Alcance: se cargan las 36 empresas de las hojas "Empresas Operadoras" (22) y
-- "Constructoras EPC" (14) de la matriz, que son las hojas con empresas y
-- canales de contacto concretos. La hoja "Proyectos Mineros y Petroleros" (42
-- proyectos) NO se carga como registros separados: es información de contexto
-- de mercado (qué proyecto/provincia/RIGI corresponde a cada operadora), en su
-- mayoría de las mismas empresas ya cubiertas en "Empresas Operadoras", y sin
-- estructura de empresa/contacto propia. Si además querés esas ~15 empresas
-- que aparecen solo en esa hoja (varias todavía "a confirmar" o sin ningún
-- canal de contacto), lo cargamos aparte.
--
-- Contactos con nombre y apellido reales (11 personas, extraídas de las
-- celdas de texto libre de la matriz) se cargan en prospectos, vinculados a
-- su empresa. El resto de las empresas queda sin contacto individual
-- (RRHH/Compras/Relaciones Institucionales son portales o casillas
-- genéricas, no una persona) — quedan en la ficha de la empresa (notas) para
-- que el equipo comercial defina a quién escribirle.
--
-- Seguro para re-ejecutar y seguro si alguna de estas empresas ya estaba
-- cargada de antes: solo hace INSERT (nunca UPDATE ni DELETE), y cada INSERT
-- valida por nombre (o por nombre+contacto) que el registro no exista ya, así
-- que no duplica nada ni toca el historial de gestiones/estado de los
-- prospectos que ya fueron contactados.

-- 1) Empresas (Empresas Operadoras + Constructoras EPC)
with nuevas_empresas(nombre, sector, linkedin, pais, notas) as (
  values
  ('YPF S.A.', 'Oil & Gas', 'https://ar.linkedin.com/company/ypf-s-a-', 'Argentina', $$Oil & Gas / Energía - Vaca Muerta, GNL, VMOS | RRHH: Portal de Empleos oficial de YPF | Compras/Proveedores: Sitio de Proveedores (plataforma SAP Ariba) - alta obligatoria para cotizar | Relaciones institucionales: ypf@ypf.com | Web: https://www.ypf.com/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Pan American Energy (PAE)', 'Oil & Gas', 'https://ar.linkedin.com/company/pan-american-energy', 'Argentina', $$Oil & Gas / Energías Renovables - Cerro Dragón, Vaca Muerta, GNL | RRHH: Portal de Carreras PAE | Compras/Proveedores: presentaciondeproveedores@pan-energy.com | Relaciones institucionales: Formulario de contacto oficial del sitio | Web: https://www.pan-american-energy.com/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Tecpetrol (Grupo Techint)', 'Oil & Gas', 'https://www.linkedin.com/company/tecpetrol', 'Argentina', $$Oil & Gas - Fortín de Piedra, Los Toldos | RRHH: Techint Careers (portal de empleos del grupo) | Compras/Proveedores: Sección 'Gestión de Proveedores' en su sitio | Relaciones institucionales: Formulario en página de contacto | Web: https://www.tecpetrol.com/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Vista Energy', 'Oil & Gas', null, 'Argentina', $$Oil & Gas - Vaca Muerta | RRHH: Sección 'Carreras' en su web y LinkedIn | Compras/Proveedores: Portal de abastecimiento en la web corporativa | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Aconcagua Energía', 'Energía', null, 'Argentina', $$Oil & Gas / Generación de energía - Mendoza, Neuquén, Río Negro | Compras/Proveedores: contacto@aconcaguaenergia.com.ar | Relaciones institucionales: (+54 11) 5235-9800 | Web: https://www.aconcaguaenergia.com.ar/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Clear Petroleum', 'Oil & Gas', null, 'Argentina', $$Oil & Gas / Servicios especializados - Cuenca Neuquina y Golfo San Jorge | Compras/Proveedores: info@clear.com.ar | Web: https://www.clearpetroleum.com.ar/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Central Puerto S.A.', 'Energía', null, 'Argentina', $$Energía / Minería - Proyecto Diablillos | Compras/Proveedores: compras@centralpuerto.com | Relaciones institucionales: Av. Thomas Edison 2701, CABA | Web: https://www.centralpuerto.com/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Lundin Mining Argentina (Vicuña Corp - Josemaría / Filo del Sol)', 'Minería', 'https://ar.linkedin.com/company/vicunaarg', 'Argentina', $$Minería metalífera (Cobre/Oro) - San Juan | RRHH: empleo@josemaria.com.ar | Compras/Proveedores: Portal de Proveedores Local (empresas de San Juan y nacionales) | Relaciones institucionales: compras_sanjuan@lundinmining.com | Web: https://lundinmining.com/ | LinkedIn opera como Vicuña Corp | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('McEwen Copper (Los Azules)', 'Minería', 'https://ar.linkedin.com/company/mcewencopper', 'Argentina', $$Minería metalífera (Cobre) - San Juan | Compras/Proveedores: info_argentina@mcewenmining.com | Relaciones institucionales: San Juan Capital (oficina central) | Web: https://www.mcewencopper.com/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Rio Tinto (Rincón / Fénix / Sal de Vida - ex Arcadium)', 'Minería', null, 'Argentina', $$Litio - Salta, Catamarca, Jujuy | RRHH: Portal de empleos global y local | Compras/Proveedores: Sitio web, sección 'Suppliers' (registro global de proveedores) | Web: https://www.riotinto.com/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Eramine Sudamérica (Centenario-Ratones)', 'Minería', null, 'Argentina', $$Litio - Salta | RRHH: Formulario de contacto general (deriva a RRHH) | Compras/Proveedores: Formulario de contacto general (deriva a compras) | Relaciones institucionales: Formulario de contacto general | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Minera Exar (Cauchari-Olaroz)', 'Minería', 'https://ar.linkedin.com/company/exarlitio', 'Argentina', $$Litio - Jujuy | RRHH: curriculum@mineraexar.com.ar | Compras/Proveedores: proveedores@mineraexar.com.ar | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('POSCO Argentina (Sal de Oro)', 'Minería', 'https://ar.linkedin.com/company/posco-argentina', 'Argentina', $$Litio - Salta / Catamarca | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Glencore (El Pachón / MARA)', 'Minería', null, 'Argentina', $$Cobre / Oro / Molibdeno - San Juan / Catamarca | Web: https://www.glencore.com/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Barrick Gold / Shandong Gold (Veladero)', 'Minería', null, 'Argentina', $$Oro / Plata - San Juan | Web: https://www.barrick.com/ | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Newmont Corporation (Cerro Negro)', 'Minería', 'https://ar.linkedin.com/company/newmont-argentina', 'Argentina', $$Oro / Plata - Santa Cruz | RRHH: No hay altas directas por RRHH para site; búsquedas centralizadas en jobs.newmont.com | Compras/Proveedores: Registro POR INVITACIÓN vía SAP Ariba (no hay alta espontánea). Procurement Corporativo (Colorado, EEUU): +1 303-863-7414. Compromiso de 'Local Procurement' declarado en su web. || CONTACTOS DIRECTOS DE COMPRAS/SUPPLY CHAIN (aportados por el usuario, verificados en LinkedIn jul-2026): Emiliano Cebrero, Superintendente de Supply Chain (San Juan) - Emiliano.cebrero@newmont.com | Verónica Cajelli, Purchasing Officer/Área Compras Minera - veronica.cajelli@newmont.com | Cel: +54 9 11 2646-0709 | Relaciones institucionales: Oficina Buenos Aires: Av. Leandro N. Alem 855, Piso 27, CABA | Oficina Santa Cruz (Perito Moreno): Av. San Martín 1207, Tel +54-297-4872901 (el +54 2963 432464 publicado antes por Newmont ya no está en servicio, corregido con fuente CAMICRUZ) || CONTACTO DIRECTO: María Eugenia Sampalione, Gerente de Relaciones Externas / Directora Ejecutiva Argentina, Cel. +54 911 5419-8435, maria.sampalione@newmont.com || Mercedes Garbi, Relaciones Externas, Cel. +54 911 3685-6231, mercedes.garbi@newmont.com | Web: https://www.newmont.com/ | Operación: https://operations.newmont.com/latac/cerro-negro-argentina | Estado de verificación (matriz jul-2026): 🟩 Verificado (jul-2026) - fuente: camicruz.com.ar (Cámara Minera de Santa Cruz). Teléfono de planta anterior no funcionaba (confirmado por el usuario).$$),
  ('Minera Santa Rita S.R.L. (MSR)', 'Minería', 'https://ar.linkedin.com/company/minera-santa-rita-srl', 'Argentina', $$Boratos (en producción) y Litio en desarrollo - Salta (Campo Quijano) | Compras/Proveedores: ventas@santaritasrl.com / comercial@santaritasrl.com (Gerente de Ventas: Ariel Albornoz) | Relaciones institucionales: Ruta Provincial 36 Km2, Campo Quijano, Salta (CP 4407) | Web: https://santaritasrl.com/ | Estado de verificación (matriz jul-2026): 🟩 Verificado (jul-2026) - fuente: santaritasrl.com, ExportArgentina.org.ar$$),
  ('Borax Argentina S.A.', 'Minería', 'https://www.linkedin.com/company/borax-argentina-s-a-', 'Argentina', $$Boratos (ácido bórico, bórax) - Salta (Campo Quijano, Tincalayu, Sijes) | RRHH: Ver contacto de logística abajo | Compras/Proveedores: consultas@boraxargentina.com / Tel (54 387) 426-8000 | Relaciones institucionales: Presidente (2021, verificar vigencia): Fernando Cornejo Torino. Gerente General (fuente Mining Press, sin fecha): Iván Gómez. Huaytiquina 227, Campo Quijano, Salta 4407 | Web: https://boraxargentina.com/ | Estado de verificación (matriz jul-2026): 🟩 Verificado (jul-2026), presidencia de 2021 a confirmar$$),
  ('Puna Mining S.A.', 'Minería', 'https://ar.linkedin.com/company/puna-mining-s-a', 'Argentina', $$Litio (carbonato grado batería) - Salar del Rincón, Salta | Compras/Proveedores: comercio_exterior@punamining.com.ar (canal de comercio exterior/exportaciones) | Relaciones institucionales: Presidente/fundador: Pablo Alurralde. CEO: Francisco Alurralde. Director Operativo: Luis Sansot. Representante Legal: Francisco Durand Casali. Campo Quijano, Salta 4407 | Web: https://punamining.com.ar/ | Estado de verificación (matriz jul-2026): 🟩 Verificado (jul-2026)$$),
  ('Mansfield Minera SA (Proyecto Lindero)', 'Minería', null, 'Argentina', $$Oro - Salta (subsidiaria 100% de Fortuna Silver Mines Inc., Canadá) | Relaciones institucionales: Av. Reyes Católicos 1224, Piso 2, Salta A4408KRN. No se encontró con certeza el nombre del actual Country Manager/Gerente General en Argentina (fuentes de pago dan nombres de baja confiabilidad, no se incluyen) | Web: argentinamining.com/es/mansfield | Estado de verificación (matriz jul-2026): 🟨 Empresa verificada; directivo local sin confirmar$$),
  ('Bureau Veritas Argentina S.A.', 'Industria', null, 'Argentina', $$Servicios de inspección, certificación y ensayos técnicos (incl. minería) - sede CABA | Relaciones institucionales: Ing. Enrique Butty 240, Piso 4, Torre Laminar, CABA C1001AFB. Tel +54 11 4000 8000. CEO global (Francia, no Argentina): Hinda Gharbi | Web: https://www.bureauveritas.com.ar/ | Estado de verificación (matriz jul-2026): 🟩 Verificado (jul-2026) - sede argentina confirmada$$),
  ('SSR Mining Inc. (Puna Operations - Pirquitas/Chinchillas)', 'Minería', 'https://ar.linkedin.com/company/ssr-mining-inc', 'Argentina', $$Plata/Plomo/Zinc - Jujuy | Relaciones institucionales: Gerente General SSR Mining Puna: Francisco Saravia Toledo (actualizado, may-2026; antes ejercía Cristian Ramos hasta 2022-2023). Directora Corporativa de Sostenibilidad (Canadá, no Argentina): Bernarda Elizalde | Web: https://www.ssrmining.com/projects/pirquitas/ | Estado de verificación (matriz jul-2026): 🟩 Verificado (jul-2026)$$),
  ('Techint Ingeniería y Construcción', 'Construcción', null, 'Argentina', $$Constructora principal / infraestructura pesada | Proyectos: Oleoducto Vaca Muerta Oil Sur (VMOS), Josemaría, plantas de litio en Salta | Oficina Argentina: Torre Bouchard, Plaza Bouchard 557, Piso 16, C1106ABG CABA. Tel +54 9 11 4018 4100 / 2456 8240 / 4413 8467. info@techint.com | Contacto directo por cargo: Operations Sr. Director Región Sur (Argentina y Uruguay) - acalcagno@techint.com | Estado de verificación (matriz jul-2026): 🟩 Verificado (jul-2026) - fuente: IPLOCA member directory + techint.com$$),
  ('Sacde (Pampa Energía)', 'Construcción', null, 'Argentina', $$Ductos y energía | Proyectos: Gasoductos y oleoductos en la Patagonia junto a Techint | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Milicic', 'Construcción', 'https://www.linkedin.com/company/milicic-sa', 'Argentina', $$Movimiento de suelos y caminos | Proyectos: Josemaría, Veladero, Centenario-Ratones (Eramine) | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('AESA (constructora propia de YPF)', 'Construcción', null, 'Argentina', $$Montaje de plantas de tratamiento de gas y petróleo | Proyectos: Vaca Muerta, montaje planta Cauchari-Olaroz | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Contreras Hermanos', 'Construcción', null, 'Argentina', $$Tendido de ductos y obras civiles | Proyectos: NOA y Cuenca Neuquina | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Víctor Contreras', 'Construcción', null, 'Argentina', $$Obras de infraestructura gasífera y petrolera | Proyectos: Cuenca Neuquina | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Fluor', 'Construcción', null, 'Argentina', $$Ingeniería y gestión de construcción (EPCM) | Proyectos: Proyecto Josemaría (San Juan) | Oficina Argentina (Fluor Daniel Argentina Inc., sucursal): San Martín 323, CABA (CUIT 30-66345583-0). No se encontró mail/tel público ni nombre de director local confiable. | Estado de verificación (matriz jul-2026): 🟨 Empresa y sede verificadas; directivo local sin confirmar$$),
  ('Bechtel', 'Construcción', null, 'Argentina', $$Ingeniería y gestión de proyecto | Proyectos: Proyecto Los Azules (San Juan) | NOVEDAD (18-may-2026): Bechtel anunció que abrirá oficina en Argentina (aún sin dirección/tel local publicado) tras reunión de su Chairman & CEO Brendan Bechtel con el canciller Pablo Quirno, impulsado por proyectos RIGI (Los Azules, El Pachón, MARA, Josemaría/Filo del Sol). | Estado de verificación (matriz jul-2026): 🟩 Verificado (jul-2026) - fuente: Shale24, cancillería (X/Twitter oficial)$$),
  ('Jacobs', 'Construcción', null, 'Argentina', $$Ingeniería de detalle | Proyectos: Litio en Salta (Rincón / Rio Tinto) | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Sullair Argentina', 'Construcción', null, 'Argentina', $$Montaje de plantas de energía y generación modular | Proyectos: Litio en Salta | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Sintec', 'Construcción', null, 'Argentina', $$Montaje industrial y eléctrico | Proyectos: Litio en Jujuy (Minera Exar) | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Esuco', 'Construcción', null, 'Argentina', $$Obras civiles y plantas de bombeo | Proyectos: Oleoducto Vaca Muerta Oil Sur | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Kellogg Brown & Root (KBR)', 'Construcción', null, 'Argentina', $$Ingeniería global | Proyectos: Proyecto GNL (YPF/PAE) | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$),
  ('Cartellone', 'Construcción', null, 'Argentina', $$Movimiento de tierras y acceso cordillerano | Proyectos: Proyecto Josemaría (junto a Milicic) | Estado de verificación (matriz jul-2026): 🟨 Sin verificar - confirmar$$)
)
insert into public.empresas_prospecto (nombre, sector, linkedin, pais, notas)
select ne.nombre, ne.sector, ne.linkedin, ne.pais, ne.notas
from nuevas_empresas ne
where not exists (
  select 1 from public.empresas_prospecto e
  where lower(trim(e.nombre)) = lower(trim(ne.nombre))
);

-- 2) Contactos con nombre real, vinculados por nombre de empresa
with nuevos_contactos(empresa_nombre, nombre, apellido, cargo, email, telefono) as (
  values
  ('Newmont Corporation (Cerro Negro)', 'Emiliano', 'Cebrero', 'Superintendente de Supply Chain (San Juan)', 'Emiliano.cebrero@newmont.com', null),
  ('Newmont Corporation (Cerro Negro)', 'Verónica', 'Cajelli', 'Purchasing Officer / Área Compras Minera', 'veronica.cajelli@newmont.com', '+54 9 11 2646-0709'),
  ('Newmont Corporation (Cerro Negro)', 'María Eugenia', 'Sampalione', 'Gerente de Relaciones Externas / Directora Ejecutiva Argentina', 'maria.sampalione@newmont.com', '+54 911 5419-8435'),
  ('Newmont Corporation (Cerro Negro)', 'Mercedes', 'Garbi', 'Relaciones Externas', 'mercedes.garbi@newmont.com', '+54 911 3685-6231'),
  ('Borax Argentina S.A.', 'Fernando', 'Cornejo Torino', 'Presidente (2021, a confirmar vigencia)', null, null),
  ('Borax Argentina S.A.', 'Iván', 'Gómez', 'Gerente General', null, null),
  ('Puna Mining S.A.', 'Pablo', 'Alurralde', 'Presidente / Fundador', null, null),
  ('Puna Mining S.A.', 'Francisco', 'Alurralde', 'CEO', null, null),
  ('Puna Mining S.A.', 'Luis', 'Sansot', 'Director Operativo', null, null),
  ('Puna Mining S.A.', 'Francisco', 'Durand Casali', 'Representante Legal', null, null),
  ('SSR Mining Inc. (Puna Operations - Pirquitas/Chinchillas)', 'Francisco', 'Saravia Toledo', 'Gerente General SSR Mining Puna', null, null)
)
insert into public.prospectos (empresa_id, nombre, apellido, cargo, email, telefono, estado)
select e.id, nc.nombre, nc.apellido, nc.cargo, nc.email, nc.telefono, 'sin_contactar'
from nuevos_contactos nc
join public.empresas_prospecto e on lower(trim(e.nombre)) = lower(trim(nc.empresa_nombre))
where not exists (
  select 1 from public.prospectos p
  where p.empresa_id = e.id
    and lower(trim(coalesce(p.nombre,''))) = lower(trim(coalesce(nc.nombre,'')))
    and lower(trim(coalesce(p.apellido,''))) = lower(trim(coalesce(nc.apellido,'')))
);
