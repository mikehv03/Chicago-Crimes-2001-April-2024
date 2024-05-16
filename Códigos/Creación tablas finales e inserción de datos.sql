--Creación e inserción datos en locación
DROP TABLE IF EXISTS public.location;
CREATE TABLE public.location(
    id BIGSERIAL PRIMARY KEY,
    description text
);

INSERT INTO public.location(description)
SELECT DISTINCT location_description
FROM raw.crimes;

--Creación primary_type_iucr
DROP TABLE IF EXISTS public.primary_type_iucr;
CREATE TABLE public.primary_type_iucr(
    id BIGSERIAL PRIMARY KEY,
    description text NOT NULL
);

INSERT INTO public.primary_type_iucr(description)
SELECT DISTINCT primary_description
FROM raw.iucr;

--Creación de los codes
DROP TABLE IF EXISTS public.iucr_codes;
CREATE TABLE public.iucr_codes(
    iucr VARCHAR(4) PRIMARY KEY,
    primary_type_iucr_id BIGINT REFERENCES primary_type_iucr(id) NOT NULL,
    secondary_description text NOT NULL,
    active boolean NOT NULL
);

INSERT INTO public.iucr_codes(iucr, primary_type_iucr_id, secondary_description, active)
SELECT iucr, primary_type_iucr.id, secondary_description, active
FROM raw.iucr
INNER JOIN public.primary_type_iucr on iucr.primary_description = primary_type_iucr.description;

SELECT *
FROM raw.crimes;

--Creación de los fbi_codes
DROP TABLE IF EXISTS public.fbi_code;
CREATE TABLE public.fbi_code(
    fbi_code VARCHAR(3) PRIMARY KEY,
    description TEXT NOT NULL
);

INSERT INTO public.fbi_code(fbi_code, description)
VALUES
    ('01A', 'HOMICIDE'),
    ('01B', 'NON-PREMEDITATED HOMICIDE'),
    ('02', 'CRIMINAL SEXUAL ASSAULT'),
    ('03', 'ROBBERY'),
    ('04A', 'MOTOR VEHICLE THEFT'),
    ('04B', 'MOTOR VEHICLE THEFT (WITHOUT THE USE OF FORCE)'),
    ('05', 'LARCENY'),
    ('06', 'BURGLARY'),
    ('07', 'ARSON'),
    ('08A', 'AGGRAVATED ASSAULT'),
    ('08B', 'SIMPLE ASSAULT'),
    ('09', 'NARCOTICS VIOLATION'),
    ('10', 'FIREARM VIOLATION'),
    ('11', 'CRIMINAL DAMAGE TO PROPERTY'),
    ('12', 'PUBLIC ORDER VIOLATION'),
    ('13', 'NON-CRIMINAL SEXUAL OFFENSES'),
    ('14', 'AGGRAVATED SEXUAL OFFENSES'),
    ('15', 'AGGRAVATED BATTERY'),
    ('16', 'PROSTITUTION'),
    ('17', 'GAMBLING'),
    ('18', 'LIQUOR LAW VIOLATION'),
    ('19', 'DOMESTIC DISPUTES'),
    ('20', 'WEAPONS VIOLATION'),
    ('21', 'OFFENSES AGAINST CHILDREN'),
    ('22', 'FINANCIAL CRIMES'),
    ('23', 'OTHER PROPERTY CRIMES'),
    ('24', 'CRIMES AGAINST SOCIETY'),
    ('25', 'CIVIL RIGHTS VIOLATIONS'),
    ('26', 'OTHER UNCLASSIFIED CRIMES'),
    ('27', 'SEX OFFENSES (EXCEPT FORCIBLE RAPE AND PROSTITUTION)');


--CREACIÓN DE TABLA DE BLOCK E INSERCIÓN DE DATOS
DROP TABLE IF EXISTS public.block CASCADE;
CREATE TABLE  public.block(
    id BIGSERIAL PRIMARY KEY,
    description TEXT NOT NULL
);

INSERT INTO public.block(description)
SELECT DISTINCT block
FROM raw.crimes;

--CREACIÓN DE LA TABLA CRIMES
DROP TABLE IF EXISTS public.crimes;
CREATE TABLE public.crimes(
    case_number VARCHAR(15) PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    block_id BIGINT REFERENCES block(id) NOT NULL,
    iucr_codes_id VARCHAR(4) REFERENCES iucr_codes(iucr) NOT NULL,
    fbi_code_id VARCHAR(3) REFERENCES fbi_code(fbi_code) NOT NULL,
    location_id BIGINT REFERENCES location(id) NOT NULL,
    arrest BOOLEAN NOT NULL,
    domestic BOOLEAN NOT NULL,
    police_district BIGINT NOT NULL,
    ward BIGINT NOT NULL,
    community_area BIGINT NOT NULL,
    x_coordinate BIGINT,
    y_coordinate BIGINT,
    updated_on TIMESTAMP NOT NULL
);

INSERT INTO public.crimes(case_number, date, block_id, iucr_codes_id, fbi_code_id, location_id, arrest, domestic, police_district, ward, community_area, x_coordinate, y_coordinate, updated_on)
SELECT case_number, date, block.id, iucr_codes.iucr, fbi_code.fbi_code, location.id, arrest, domestic, district, ward, community_area, x_coordinate, y_coordinate, updated_on
FROM raw.crimes
INNER JOIN iucr_codes ON raw.crimes.iucr = iucr_codes.iucr
INNER JOIN fbi_code ON raw.crimes.fbi_code = fbi_code.fbi_code
INNER JOIN location ON raw.crimes.location_description = location.description
INNER JOIN block ON raw.crimes.block = block.description;


