-- Complemento a 2026-07-10-prospeccion-mineria-petroleo-energia.sql
--
-- Carga las empresas que figuran en la hoja "Proyectos Mineros y Petroleros"
-- de la matriz y que NO estaban ya cubiertas por las hojas "Empresas
-- Operadoras" / "Constructoras EPC" (esas 36 ya se cargaron en la migración
-- anterior). Son 21 empresas — varias son JVs/socios de un mismo proyecto,
-- agrupadas en un solo registro cuando la propia matriz ya las presentaba
-- así (ej. "Kopano Cobre S.A. / Mogotes Metals").
--
-- Los datos de contacto de esta tanda se consiguieron por investigación web
-- (búsquedas + intentos de acceso directo a los sitios oficiales, varios
-- bloqueados por política de red del entorno) — no estaban en la matriz
-- original. Donde la fuente marcó una inconsistencia o dato dudoso
-- (teléfono con formato distinto entre fuentes, dominio de mail
-- inconsistente, etc.) se dejó la advertencia explícita en "notas" en vez de
-- asumir cuál versión es la correcta. Recomendamos que el equipo comercial
-- confirme estos datos (llamando o vía el formulario web) antes de escribirle
-- en frío a un contacto de esta tanda específicamente.
--
-- Ejecutar MANUALMENTE en el SQL Editor de Supabase. Mismo criterio de
-- seguridad que la migración anterior: solo INSERT, con guarda WHERE NOT
-- EXISTS por nombre de empresa (y por empresa+nombre+apellido para
-- contactos) — segura de re-ejecutar y no toca ni duplica nada de lo que ya
-- esté cargado en Prospección.

-- 1) Empresas adicionales (solo en la hoja de Proyectos, no en Operadoras/EPC)
with nuevas_empresas(nombre, sector, linkedin, pais, notas) as (
  values
  ('AbraSilver Resource Corp', 'Minería', 'https://ca.linkedin.com/company/abrasilver-resource-corp', 'Argentina', $$Opera Proyecto Diablillos (oro/plata), Salta. Oficina central: 220 Bay St, Suite 550, Toronto, ON M5J 2W4, Canadá. Tel +1 416-306-8334. Email info@abrasilver.com. Presidente y CEO: John Miniotis. Sin oficina propia en Argentina confirmada. Web: https://www.abrasilver.com/ | Fuente: investigación web jul-2026 (snippets de búsqueda, sin lectura directa del sitio por bloqueo de red del entorno).$$),
  ('Lake Resources NL', 'Minería', 'https://au.linkedin.com/company/lake-resources', 'Argentina', $$Opera proyecto de litio Kachi, Catamarca. Oficina: Level 5, 126 Phillip Street, Sydney NSW 2000, Australia. Tel +61 2 9299 9690. Email de contacto no confirmado (aparece enmascarado en resultados de búsqueda). Sin oficina propia en Argentina. Web: https://lakeresources.com.au/ | Fuente: investigación web jul-2026.$$),
  ('Galan Lithium Ltd', 'Minería', 'https://www.linkedin.com/company/galan-lithium-ltd', 'Argentina', $$Opera proyecto de litio Hombre Muerto Oeste, Catamarca. Oficina central: Level 1, 50 Kings Park Road, West Perth WA 6005, Australia. Tel +61 (08) 9214 2150. Email admin@galanlithium.com.au. Oficina en Argentina: Levels 2-3, San Martín 692, San Fernando del Valle de Catamarca. Representación legal en CABA (Saravia Frías Abogados): Arroyo 894 1° Piso, C1007AAB, tel +54 11 4328-4121. Web: https://galanlithium.com.au/ | Fuente: investigación web jul-2026, incluye oficina Argentina confirmada.$$),
  ('Aldebaran Resources Inc', 'Minería', 'https://ca.linkedin.com/company/aldebaran-resources', 'Argentina', $$Opera proyecto de cobre Altar, San Juan. Oficina central: 200 Burrard Street, Suite 1570, Vancouver, BC V6C 3L6, Canadá. Tel +1 604 685-6800. Email info@aldebaranresources.com. Oficina en Argentina (Aldebaran Argentina SA): Lateral Este Av. Circunvalación 198 sur, 5411 Santa Lucía, San Juan. Tel +54-264-4254793. Web: https://aldebaranresources.com/ | Fuente: investigación web jul-2026, incluye oficina y teléfono en San Juan.$$),
  ('Minas Argentinas S.A.', 'Minería', 'https://www.linkedin.com/company/minas-argentinas-s-a', 'Argentina', $$Opera proyecto de oro Gualcamayo (Carbonatos Profundos), San Juan. Dirección societaria: Gral. José María Paz (Oeste) 558, San Juan J5402AJL (CUIT 30-67726246-6). Sin email/teléfono comercial directo confirmado — canal recomendado: formulario web en minasargentinas.com/contacto. Web: https://minasargentinas.com/ | Fuente: investigación web jul-2026.$$),
  ('BHP (Vicuña Corp - Josemaría / Filo del Sol, JV con Lundin Mining)', 'Minería', 'https://ar.linkedin.com/company/vicunaarg', 'Argentina', $$JV entre BHP y Lundin Mining, San Juan (Distrito Vicuña). Oficina de Vicuña Argentina S.A.: Ruta Nacional 40 Km 3480, Parque Tecno Industrial Albardón, Depto. Albardón, San Juan CP5419. Tel +54 9 2646 61-8892. Email comunicaciones@vicuna.com (no confirmado contra sitio oficial). BHP contacto corporativo global: online@bhp.com. Lundin Mining corporativo: info@lundinmining.com, +1 416 342 5560. Sin contacto argentino directo de BHP confirmado. Web: https://vicuna.com/ | Fuente: investigación web jul-2026.$$),
  ('Pampa Exploraciones S.A. (subsidiaria de NGEx Minerals, Grupo Lundin)', 'Minería', 'https://ca.linkedin.com/company/ngex-minerals-ltd', 'Argentina', $$Opera Proyecto Lunahuasi, San Juan (Distrito Vicuña). Matriz NGEx Minerals (Vancouver): info@ngexminerals.com, tel +1 604 689 7842. Interlocutores conocidos en prensa sin contacto directo confirmado: Martín Rode (Presidente/Gerente General Sudamérica), Iván Chávez (gerente de operaciones Lunahuasi), Alfredo Vitaller (director de Asuntos Corporativos). Sin canal propio de la subsidiaria argentina encontrado. Web: https://ngexminerals.com/ | Fuente: investigación web jul-2026.$$),
  ('Integra Capital / Compañía Minera Aguilar SJ', 'Minería', 'https://www.linkedin.com/company/integra-capital-sa', 'Argentina', $$Opera Proyectos Iglesia y Calingasta, San Juan. Oficina holding: Av. Maipú 1252, CABA CP1006COM. Contacto: integracapital.com/contact/. ADVERTENCIA: NO usar mtinant@aguilar-arzinc.com / 54-11-3754-4100 — ese contacto corresponde a Compañía Minera Aguilar S.A. (mina de zinc en Jujuy, entidad distinta), no a la unidad de exploración de cobre en San Juan. Web: https://integracapital.com/ | Fuente: investigación web jul-2026.$$),
  ('Kopano Cobre S.A. / Mogotes Metals', 'Minería', 'https://www.linkedin.com/company/mogotes-metals/', 'Argentina', $$Opera Proyecto Filo Sur (cobre/oro), San Juan. Email info@mogotesmetals.com. Oficina Toronto: 401/217 Queen St W, Toronto ON M5V 0R2, Canadá. Sin contacto propio de Kopano Cobre S.A. en Argentina encontrado. Web: https://www.mogotesmetals.com/ | Fuente: investigación web jul-2026.$$),
  ('Argentina Metals Corp / Mirasol Resources', 'Minería', 'https://www.linkedin.com/company/argentina-metals-corp', 'Argentina', $$Distrito Minero Malargüe Occidental (cobre, 14 proyectos de exploración), Mendoza. Subsidiaria argentina: Mises Metals S.A.S. (constituida dic-2025, Mendoza), sin contacto propio hallado. Mirasol Resources (socio): contact@mirasolresources.com, tel +1 604 602-9989, oficina Suite 1150-355 Burrard St, Vancouver BC V6C 2G8; VP Investor Relations: Troy Shultz (sin email directo). Webs: https://argentinametals.com/ , https://mirasolresources.com/ | Fuente: investigación web jul-2026.$$),
  ('Ganfeng Lithium', 'Minería', 'https://ar.linkedin.com/company/ganfenglithium', 'Argentina', $$Opera proyecto de litio Mariana, Salta; también socia (con Lithium Americas Corp y JEMSE) del proyecto Cauchari-Olaroz en Jujuy (operado localmente por Minera Exar, ya cargada como empresa aparte). Subsidiaria: Ganfeng Litio Argentina S.A. (CUIT 30716420600), oficina Dean Funes 531 PB, Salta 4400. Sección Proveedores en sitio LATAM sin datos de contacto directo confirmados. Webs: https://www.ganfenglithium.com/index_en.html , https://ganfenglithium-latam.com/ | Fuente: investigación web jul-2026.$$),
  ('First Quantum Minerals', 'Minería', 'https://ca.linkedin.com/company/firstquantumminerals', 'Argentina', $$Opera proyecto de cobre Taca Taca, Salta. Investor Relations (sede Canadá): Bonita To, Director IR, tel (416) 361-6400 / gratuito 1 (888) 688-6577, email info@fqml.com. Subsidiaria local para Taca Taca: Corriente Argentina S.A. (LinkedIn: ar.linkedin.com/company/corriente-argentina-s-a-), representante legal en Salta: Dr. Diego Reston (sin contacto directo hallado). Web: https://www.first-quantum.com/ | Fuente: investigación web jul-2026.$$),
  ('Lithium Argentina AG', 'Minería', 'https://www.linkedin.com/company/lithium-argentina', 'Argentina', $$Opera proyectos Pastos Grandes / Pozuelos, Salta/Jujuy. Entidad escindida de Lithium Americas Corp en 2023, enfocada en los activos argentinos. Oficina Buenos Aires: Carlos Pellegrini 719, 6to piso, CABA 1009. Tel +54 11 5263 0616. Email general info@lithium-argentina.com. Web: https://www.lithium-argentina.com/ | Fuente: investigación web jul-2026, oficina física en Buenos Aires confirmada.$$),
  ('Lithium Americas Corp', 'Minería', 'https://ca.linkedin.com/company/lithiumamericas', 'Argentina', $$Socia (con Ganfeng y JEMSE) del proyecto Cauchari-Olaroz, Jujuy — pero tras el spin-off de oct-2023 esta entidad quedó enfocada en Thacker Pass (Nevada, EEUU); los activos argentinos pasaron a Lithium Argentina AG (empresa distinta, ya cargada aparte). Sin oficina en Argentina encontrada. Oficina Vancouver: email info@lithiumamericas.com, tel 778-656-5820. Se mantiene este registro solo a modo de referencia — para prospección usar Lithium Argentina AG o Minera Exar. Web: https://www.lithiumamericas.com/ | Fuente: investigación web jul-2026.$$),
  ('Argosy Minerals Ltd', 'Minería', 'https://www.linkedin.com/company/argosy-minerals', 'Argentina', $$Socia de Puna Mining S.A. en el proyecto Salar del Rincón, Salta (Puna Mining ya cargada como empresa aparte, con contactos propios). Oficina: Level 2, 22 Mount Street, Perth WA 6000, Australia. Teléfono con discrepancia entre fuentes (+61 8 6188 8181 o +61 8 6555 2950) — confirmar cuál está vigente antes de usar. Sin email directo encontrado. Web: https://www.argosyminerals.com.au/ | Fuente: investigación web jul-2026.$$),
  ('TotalEnergies Argentina', 'Oil & Gas', 'https://ar.linkedin.com/company/totalenergies', 'Argentina', $$Opera en Vaca Muerta (junto a YPF, PAE, Tecpetrol, Vista Energy), Neuquén. Oficina Neuquén: San Martín 4346, Tel (299) 449-2242 / (11) 4346-6400. Email comercial reportado con dominio inconsistente entre fuentes (comercial@totalenergies.com.ar / comercial@totalenergies.com) — confirmar antes de usar. Página de contacto: https://totalenergies.com.ar/es/contactanos | Fuente: investigación web jul-2026.$$),
  ('Golar LNG', 'Energía', null, 'Argentina', $$Socia minoritaria (10%, consorcio Southern Energy junto con PAE, Pampa Energía, YPF y Harbour Energy) del Proyecto GNL, Río Negro/Neuquén. Sin oficina ni contacto propio en Argentina — para prospección conviene abordar vía PAE o el consorcio Southern Energy directamente. Contacto corporativo global: Golar Management Limited, 70 Victoria Street, Londres, +44 20 7063 7900, email golarlng@golar.com. Web: https://www.golarlng.com | Fuente: investigación web jul-2026.$$),
  ('TGS (Transportadora de Gas del Sur)', 'Energía', 'https://ar.linkedin.com/company/tgs_2', 'Argentina', $$Opera Proyecto NGLs (Planta Loma La Lata y Bahía Blanca), Neuquén. Sede CABA: Don Bosco 3672, 6º piso, C1206ABF, Tel (011) 4865-9050/60/70. Planta Cerri (Bahía Blanca): Av. Gral. Daniel Cerri 701. Portal de proveedores propio, sin email/teléfono directo de compras hallado. Página contacto: https://www.tgs.com.ar/en/contact/ | Fuente: investigación web jul-2026.$$),
  ('Pampa Energía', 'Energía', 'https://www.linkedin.com/company/pampa-energia', 'Argentina', $$Opera proyecto petrolero Rincón de Aranda, Neuquén (distinta de su subsidiaria constructora Sacde, ya cargada aparte). Sede CABA: Maipú 1, C1084ABA, Tel +54 11 4344-6000. Oficina Neuquén: J.J. Lastra 6000, Tel (299) 449-1300 / 449-1339. Portal de proveedores con alta: https://pampa.com/proveedores/postulacion-nuevo-proveedor-de-pampa/ — asistencia a proveedores: email callcap@pampa.com, tel 0800-888-9999 opción 1 (L-V 10-13h). Web: https://pampa.com | Fuente: investigación web jul-2026 — canal de proveedores concreto y accionable.$$),
  ('Hochschild Mining', 'Minería', null, 'Argentina', $$Opera minas de oro/plata San José y Don Nicolás (vía Minera Santa Cruz S.A., JV 51% Hochschild / 49% McEwen Mining), Santa Cruz. Oficina administrativa Buenos Aires (Minera Santa Cruz S.A.): Av. Santa Fe 2755, piso 9, C1425BGC, CABA. Tel +54 11 4132-7900 (formato reportado con leve inconsistencia entre fuentes, confirmar). Contacto corporativo global (Londres): info@hocplc.com, +44 203 709 3260. Página contactos: https://www.hochschildmining.com/es/contactos/ | Fuente: investigación web jul-2026.$$),
  ('AngloGold Ashanti (Cerro Vanguardia)', 'Minería', 'https://ar.linkedin.com/company/cerro-vanguardia', 'Argentina', $$Opera mina de oro/plata Cerro Vanguardia, Santa Cruz. Dirección: Av. San Martín 1032 PB, Puerto San Julián, Santa Cruz. Fax +54 2962 496261. Portal de proveedores (formulario, sin email directo): https://cerrovanguardia.com.ar/proveedores/ — contacto general: https://cerrovanguardia.com.ar/contacto/ — portal de carreras: https://careers.anglogoldashanti.com/go/Argentina-(es_ES)/9005001/ | Fuente: investigación web jul-2026.$$)
)
insert into public.empresas_prospecto (nombre, sector, linkedin, pais, notas)
select ne.nombre, ne.sector, ne.linkedin, ne.pais, ne.notas
from nuevas_empresas ne
where not exists (
  select 1 from public.empresas_prospecto e
  where lower(trim(e.nombre)) = lower(trim(ne.nombre))
);

-- 2) Contactos con nombre real y dato personal confiable (email/tel propio),
--    vinculados por nombre de empresa
with nuevos_contactos(empresa_nombre, nombre, apellido, cargo, email, telefono, notas) as (
  values
  ('Galan Lithium Ltd', 'Katherine', 'Garvey', 'Company Secretary', 'kgarvey@galanlithium.com.au', null, null),
  ('Aldebaran Resources Inc', 'Ben', 'Cherrington', 'Investor Relations', 'ben.cherrington@aldebaranresources.com', null, null),
  ('Aldebaran Resources Inc', 'Laura', 'Brangwin', 'Investor Relations', 'laura.brangwin@aldebaranresources.com', null, null),
  ('Kopano Cobre S.A. / Mogotes Metals', 'Allen', 'Sabet', 'CEO', 'allen@mogotesmetals.com', '(647) 846-3313', null),
  ('Argentina Metals Corp / Mirasol Resources', 'Raymond D.', 'Harari', 'CEO (Argentina Metals Corp)', 'harari@argentinametals.com', null, 'Teléfono reportado con prefijo +507 (Panamá), atípico — confirmar antes de usar, no cargado por esa razón.'),
  ('Lithium Argentina AG', 'Kelly', 'O''Brien', 'Investor Relations', 'Kelly.obrien@lithium-argentina.com', null, null)
)
insert into public.prospectos (empresa_id, nombre, apellido, cargo, email, telefono, estado, notas)
select e.id, nc.nombre, nc.apellido, nc.cargo, nc.email, nc.telefono, 'sin_contactar', nc.notas
from nuevos_contactos nc
join public.empresas_prospecto e on lower(trim(e.nombre)) = lower(trim(nc.empresa_nombre))
where not exists (
  select 1 from public.prospectos p
  where p.empresa_id = e.id
    and lower(trim(coalesce(p.nombre,''))) = lower(trim(coalesce(nc.nombre,'')))
    and lower(trim(coalesce(p.apellido,''))) = lower(trim(coalesce(nc.apellido,'')))
);
