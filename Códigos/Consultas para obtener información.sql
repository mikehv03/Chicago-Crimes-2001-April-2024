--1. CONTAR LOS CRÍMENES QUE HAN SUCEDIDO POR AÑO
SELECT  EXTRACT(YEAR FROM date) AS anio, COUNT(*) AS numero_crimenes
FROM crimes
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY anio;

--2. VIOLENCIA DOMÉSTICA EN CHICAGO
SELECT EXTRACT(YEAR FROM date) as anio, COUNT(*) as frec
FROM crimes
WHERE domestic IS TRUE
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY anio DESC;

--3. OBTENER LOS CÓDIGOS IUCR MÁS UTILIZADOS EN LA BASE DE DATOS
WITH CTE_iucr_numero_crimenes AS(
    SELECT iucr_codes_id AS IUCR, COUNT(*) AS numero_crimenes
    FROM crimes
    GROUP BY iucr_codes_id
    ORDER BY numero_crimenes DESC
    LIMIT 5
)

SELECT CTE_iucr_numero_crimenes.IUCR, primary_type_iucr.description AS primary_description, secondary_description, numero_crimenes, iucr_codes.active
FROM CTE_iucr_numero_crimenes
INNER JOIN iucr_codes ON CTE_iucr_numero_crimenes.IUCR = iucr_codes.iucr
INNER JOIN primary_type_iucr ON primary_type_iucr.id = iucr_codes.primary_type_iucr_id
ORDER BY numero_crimenes DESC;

--4. OBTENER LOS CÓDIGOS FBI MÁS UTILIZADOS EN LA BASE DE DATOS
SELECT fbi_code, description, COUNT(*) AS numero_delitos
FROM crimes
INNER JOIN fbi_code ON fbi_code.fbi_code = fbi_code_id
GROUP BY fbi_code.fbi_code, fbi_code.description
ORDER BY numero_delitos DESC
LIMIT 5;

--5. LOCALIZACIONES DONDE OCURRIERON MÁS DELITOS
SELECT location.id, location.description, COUNT(*) AS numero_crimenes
FROM location
INNER JOIN crimes ON location.id = crimes.location_id
GROUP BY location.id, location.description
ORDER BY numero_crimenes DESC
LIMIT 10;

--6. PORCENTAJE DE PERSONAS ARRESTADAS.
WITH CTE_crimenes_con_arresto AS (
    SELECT COUNT(*) AS tot_crimines_con_arresto
    FROM crimes
    WHERE arrest IS TRUE
),

CTE_crimenes_totales AS(
    SELECT COUNT(*) AS tot_crimenes
    FROM crimes
)

SELECT (CAST(tot_crimines_con_arresto AS DECIMAL) / tot_crimenes) * 100 AS porcentaje
FROM CTE_crimenes_con_arresto, CTE_crimenes_totales;

--7. OBTENER LOS DISTRITOS POLICIACOS DONDE MÁS CRÍMENES HAN SUCEDIDO
SELECT police_district, COUNT(*) AS numero_delitos
FROM crimes
GROUP BY police_district
ORDER BY numero_delitos DESC
LIMIT 5;

--OBTENER LOS DISTRITOS POLICIACOS DONDE MENOS CRÍMENES HAN SUCEDIDO
SELECT police_district, COUNT(*) AS numero_delitos
FROM crimes
GROUP BY police_district
ORDER BY numero_delitos
LIMIT 5;

--OBTENER LAS COMMUNITY_AREAS DONDE MÁS CRÍMENES HAN SUCEDIDO
SELECT community_area, COUNT(*) AS numero_delitos
FROM crimes
GROUP BY community_area
ORDER BY numero_delitos DESC
LIMIT 5;

--OBTENER LAS COMMUNITY_AREAS DONDE MENOS CRÍMENES HAN SUCEDIDO
SELECT community_area, COUNT(*) AS numero_delitos
FROM crimes
GROUP BY community_area
ORDER BY numero_delitos
LIMIT 5;

--FUNCIONES VENTANA
--1. OBTENER EL NÚMERO DE FBI MÁS UTILIZADO POR AÑO
WITH CTE_fbicode_anio AS (
    SELECT EXTRACT(YEAR FROM date) AS anio, fbi_code_id, COUNT(*) AS numero_crimenes
    FROM crimes
    GROUP BY EXTRACT(YEAR FROM date), fbi_code_id
),

CTE_anio_max_fbi AS(
    SELECT anio, fbi_code_id, numero_crimenes,
       MAX(numero_crimenes) OVER w AS max
    FROM CTE_fbicode_anio
    WINDOW w AS(
        PARTITION BY anio
       )
)

SELECT anio, fbi_code_id, fbi_code.description, numero_crimenes
FROM CTE_anio_max_fbi
INNER JOIN fbi_code ON fbi_code.fbi_code = CTE_anio_max_fbi.fbi_code_id
WHERE numero_crimenes = max;

--2. OBTENER EL DISTRICT ÁREA QUE MÁS CRÍMENES TUVO POR AÑO
WITH CTE_anio_police_district AS(
    SELECT EXTRACT(YEAR FROM date) AS anio, police_district, COUNT(*) AS numero_crimenes
    FROM crimes
    GROUP BY EXTRACT(YEAR FROM date), police_district
),

CTE_mas_crimenes_anio_police_district AS(
    SELECT anio, police_district, numero_crimenes, MAX(numero_crimenes) OVER w AS max_numero_crimenes
    FROM CTE_anio_police_district
    WINDOW w AS (
    PARTITION BY anio
        )
)

SELECT anio, police_district, numero_crimenes
FROM CTE_mas_crimenes_anio_police_district
WHERE numero_crimenes = max_numero_crimenes;

