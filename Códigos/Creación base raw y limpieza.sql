--CREATING RAW SCHEMA
DROP SCHEMA IF EXISTS raw CASCADE;
CREATE SCHEMA IF NOT EXISTS raw;

--CREATING TABLE FROM RAW DATA
DROP TABLE IF EXISTS raw.crimes;
CREATE TABLE raw.crimes(
    id bigint,
    case_number text,
    date text,
    block text,
    iucr text,
    primary_type text,
    description text,
    location_description text,
    arrest boolean,
    domestic boolean,
    beat bigint,
    district bigint,
    ward bigint,
    community_area bigint,
    fbi_code text,
    x_coordinate bigint,
    y_coordinate bigint,
    year bigint,
    updated_on text,
    latitude double precision,
    longitude double precision,
    location text
);

--Poner los datos
\copy raw.crimes(id, case_number, date, block, iucr, primary_type, description, location_description, arrest, domestic, beat, district, ward, community_area, fbi_code, x_coordinate, y_coordinate, year, updated_on, latitude, longitude, location) FROM 'path_to_downloaded_csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');

--Limpieza de datos, primero la location_description
UPDATE raw.crimes
SET  location_description =
    CASE
        WHEN location_description ILIKE '%PARKING LOT%' THEN 'PARKING LOT'
        WHEN (location_description ILIKE '%SIDEWALK%' OR location_description ILIKE '%ALLEY%')  THEN 'STREET'
        WHEN location_description IS NULL THEN 'OTHER'
        WHEN location_description ILIKE '%DEPARTMENT STORE%' THEN 'STORE'
        WHEN location_description ILIKE '%TAXI CAB%' THEN 'TAXI'
        WHEN location_description ILIKE '%SCHOOL%' THEN 'SCHOOL'
        WHEN location_description ILIKE '%RESIDENCE%' THEN 'RESIDENCE'
        WHEN location_description ILIKE '%RETIREMENT HOME%' THEN 'RETIREMENT HOME'
        WHEN location_description ILIKE '%FOOD STORE%' THEN 'FOOD STORE'
        WHEN location_description ILIKE '%FACTORY%' THEN 'FACTORY'
        WHEN location_description ILIKE '%GOVERNMENT BUILDING%' THEN 'GOVERNMENT BUILDING'
        WHEN location_description ILIKE '%HOSPITAL%' THEN 'HOSPITAL'
        WHEN location_description ILIKE '%PARK%' THEN 'PARK'
        WHEN location_description ILIKE '%GARAGE%' THEN 'GARAGE'
        WHEN location_description ILIKE '%BAR%' THEN 'BAR'
        WHEN location_description ILIKE '%PLACE OF WORSHIP%' THEN 'PLACE OF WORSHIP'
        WHEN location_description ILIKE '%RETAIL STORE%' THEN 'RETAIL STORE'
        WHEN location_description ILIKE '%RESIDENTIAL%' THEN 'RESIDENCE'
        WHEN location_description ILIKE '%BUSINESS OFFICE%' THEN 'BUSINESS OFFICE'
        WHEN location_description ILIKE '%AUTO%' THEN 'AUTO'
        WHEN location_description ILIKE '%BOAT%' THEN 'BOAT'
        WHEN location_description ILIKE '%CHA%' THEN 'CHICAGO HOUSING AUTHORITY'
        WHEN Location_description ILIKE '%CHURCH%' THEN 'CHURCH'
        WHEN location_description ILIKE '%AIRPORT%' THEN 'AIRPORT'
        WHEN location_description ILIKE '%CLEANERS%' THEN 'CLEANING STORE'
        WHEN location_description ILIKE '%UNIVERSITY%' THEN 'UNIVERSITY'
        WHEN location_description ILIKE '%CTA%' THEN 'CHICAGO TRANSIT AUTHORITY'
        WHEN location_description ILIKE '%GAS STATION%' THEN 'GAS STATION'
        WHEN location_description ILIKE '%HIGHWAY%' THEN 'HIGHWAY'
        WHEN location_description ILIKE '%HOTEL%' THEN 'HOTEL'
        WHEN location_description ILIKE '%JAIL%' THEN 'JAIL'
        WHEN location_description ILIKE '%JUNK YARD%' THEN 'JUNK YARD'
        WHEN location_description ILIKE '%LAKE%' THEN 'LAKE'
        WHEN location_description ILIKE '%MEDICAL%' THEN 'MEDICAL'
        WHEN location_description ILIKE '%MOVIE HOUSE%' THEN 'MOVIE HOUSE'
        WHEN location_description ILIKE '%NURSING%' THEN 'NURSING HOME'
        WHEN location_description ILIKE '%COMMERCIAL TRANSPORTATION%' THEN 'COMMERCIAL TRANSPORTATION'
        WHEN location_description ILIKE '%RAILROAD%' THEN 'RAILROAD PROPERTY'
        WHEN location_description ILIKE '%POOL ROOM%' THEN 'POOLROOM'
        WHEN location_description ILIKE '%RIVER%' THEN 'RIVER'
        WHEN location_description ILIKE '%SPORTS ARENA%' THEN 'SPORTS ARENA'
        WHEN location_description ILIKE '%TAVERN%' THEN 'TAVERN'
        WHEN location_description ILIKE '%VACANT LOT%' THEN 'VACANT LOT'
        WHEN location_description ILIKE '%CEMETARY%' THEN 'CEMETERY'
        WHEN location_description ILIKE '%CEMETERY%' THEN 'CEMETERY'
        WHEN location_description ILIKE '%OTHER%' THEN 'OTHER'
        WHEN location_description ILIKE '%VEHICLE%' THEN 'VEHICLE'
    ELSE
        location_description
END;

--CONVERT DATE TO TIMESTAMP
ALTER TABLE raw.crimes
ALTER COLUMN date TYPE timestamp without time zone
USING TO_TIMESTAMP(date, 'MM/DD/YYYY HH:MI:SS AM');

--CONVERT UPDATE_ON TO TIMESTAMP
ALTER TABLE raw.crimes
ALTER COLUMN updated_on TYPE timestamp without time zone
USING TO_TIMESTAMP(updated_on, 'MM/DD/YYYY HH:MI:SS AM');

--ELIMINAR TODOS LOS LUGARES QUE NO TENGAN COMMUNITY AREA O NO TENGAN WARD
DELETE FROM raw.crimes
WHERE id IN (SELECT id
            FROM raw.crimes
            WHERE community_area IS NULL);

DELETE FROM raw.crimes
WHERE id IN (SELECT id
            FROM raw.crimes
            WHERE ward IS NULL);

DELETE FROM raw.crimes
WHERE id IN (SELECT id
            FROM raw.crimes
            WHERE district IS NULL);
/* SE ENCONTRÓ QUE ALGUNOS CÓDIGOS DE IUCR NO ESTABAN EN LA TABLA ESPECIAL PARA CHICAGO, POR LO QUE CAMBIAMOS SU IUCR A UNOS SIMILARES
QUE SÍ ESTABAN */
UPDATE raw.crimes
SET iucr =
    CASE
        WHEN iucr ILIKE '0585' THEN '0580'
        WHEN iucr ILIKE '1581' THEN '1563'
        WHEN iucr ILIKE '2896' THEN '2890'
        WHEN iucr ILIKE '3961' THEN '3960'
    ELSE
        iucr
END;

--ELIMINAR DATOS DE LOS DELITOS DE TIPO: NO CRIMINALES
DELETE FROM raw.crimes
WHERE id IN (SELECT id
            FROM raw.crimes
            WHERE iucr = '5073');

DELETE FROM raw.crimes
WHERE id IN (SELECT id
            FROM raw.crimes
            WHERE iucr = '5093');

DELETE FROM raw.crimes
WHERE id IN (SELECT id
            FROM raw.crimes
            WHERE iucr = '5094');

DELETE FROM raw.crimes
WHERE id IN (SELECT id
            FROM raw.crimes
            WHERE iucr = '5113');

DELETE FROM raw.crimes
WHERE id IN (SELECT id
            FROM raw.crimes
            WHERE iucr = '5114');

--PONER TODOS LOS BLOCK EN MAYÚSCULA
UPDATE raw.crimes
SET block = UPPER(block);

--ENCONTRAMOS CIERTOS CASE_ID REPETIDOS POR LO QUE LA LIMPIAMOS
DELETE FROM raw.crimes
WHERE id IN (WITH CTE_nombres_casos_repetidos AS (
                SELECT id, case_number, ROW_NUMBER() OVER (PARTITION BY case_number ORDER BY id) as numero_fila
                FROM raw.crimes
                WHERE case_number IN (
                    SELECT case_number
                    FROM raw.crimes
                    GROUP BY case_number
                    HAVING COUNT(*) > 1
                )
                ORDER BY case_number, numero_fila
            )

            SELECT id
            FROM CTE_nombres_casos_repetidos
            WHERE numero_fila != 1);

--AGREGAR TABLA DE IUCR
DROP TABLE IF EXISTS raw.iucr;
CREATE TABLE raw.iucr(
    iucr VARCHAR(4) PRIMARY KEY, --Se observó que los códigos tienen máximo 4 caracteres
    primary_description TEXT NOT NULL,
    secondary_description TEXT NOT NULL,
    index_code TEXT NOT NULL,
    active BOOLEAN NOT NULL
);

\copy raw.iucr(iucr, primary_description, secondary_description, index_code, active) FROM 'path_to_downloaded_csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');

--Habían ciertos datos que no tenían 0s al principio, y en la tabla de crímenes todos tenían. Por ende con esto se normalizo
UPDATE raw.iucr
SET iucr = LPAD(CAST(iucr AS TEXT), 4, '0')
WHERE LENGTH(CAST(iucr AS TEXT)) < 4;



