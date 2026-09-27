/*
================================================================================
PROYECTO: Sistema de Base de Datos de Formula 1 (PostgreSQL & PL/pgSQL)
ASIGNATURA: Bases de Datos | Grado en Ingenieria en Sistemas de Informacion (GISI - UAH)
AUTORES: Ivan Collado y David Martinez

NOTA SOBRE ORGANIZACION Y REFACTORIZACION PARA GITHUB:
El presente script corresponde fielmente a la solucion desarrollada y evaluada
en el laboratorio de la universidad (Practica PECL2).
Con el fin de estructurar este repositorio para su publicacion en GitHub siguiendo
las mejores practicas de la industria, los datasets CSV se han reubicado en la
carpeta 'data/'. Por ello, las sentencias \COPY del Bloque 1 se han actualizado
para leer desde 'data/<archivo>.csv' (asumiendo ejecucion desde la raiz del modulo
01-bases-de-datos). Toda la logica relacional, normalizacion, vistas, triggers y
control de acceso RBAC permanece 100% fiel e inalterada respecto a la entrega academica.
================================================================================
*/

\pset pager off
SET client_encoding TO 'UTF8';

BEGIN;
\echo '=================================================================='
\echo '<< CREACION DE LA BASE DE DATOS "FORMULAONE" >>'
\echo 'BLOQUE 1: CREACION DE ESQUEMAS, TABLAS Y CARGA DE DATOS (PL1)'
\echo '=================================================================='

\echo ''
\echo 'Limpiando esquemas existentes (si los hubiese)...'

-- Eliminamos el esquema y tablas si existen
DROP SCHEMA IF EXISTS ddbb CASCADE;

-- Eliminamos el esquema temporal y tablas si existen
DROP SCHEMA IF EXISTS temp CASCADE;

\echo ''
\echo 'Esquemas existentes eliminados correctamente.'

\echo '========================================================='
\echo '<< INICIANDO LA CREACION DE LA BASE DE DATOS "FORMULAONE" >>'
\echo '========================================================='
\echo ''

/* 
/// ESQUEMA TEMPORAL ///
Se crean las tablas temporales con todos los campos como TEXT y 
sin restricciones para facilitar la carga de datos desde CSV.
*/
\echo '========================================================='
\echo 'Creando esquema temporal y tablas...'
\echo '========================================================='
\echo ''
\echo 'Creando esquema temporal...'
CREATE SCHEMA IF NOT EXISTS temp;

-- TABLA TEMPORAL CIRCUITOS
\echo '' 
\echo 'Creando tabla temporal "circuitos_temp"...'
CREATE TABLE IF NOT EXISTS temp.circuitos_temp (
    circuito_id TEXT,
    circuito_ref TEXT,
    nombre TEXT,
    localizacion TEXT,
    ciudad TEXT,
    latitud TEXT,
    longitud TEXT,
    altura TEXT,
    url TEXT
);

-- TABLA TEMPORAL ESCUDERiAS
\echo ''
\echo 'Creando tabla temporal "escuderias_temp"...'
CREATE TABLE IF NOT EXISTS temp.escuderias_temp (
    escuderia_id TEXT,
    escuderia_ref TEXT,
    nombre TEXT,
    nacionalidad TEXT,
    url TEXT
);

-- TABLA TEMPORAL PILOTOS
\echo ''
\echo 'Creando tabla temporal "pilotos_temp"...'
CREATE TABLE IF NOT EXISTS temp.pilotos_temp (
    piloto_id TEXT,
    piloto_ref TEXT,
    numero TEXT,
    codigo TEXT,
    nombre TEXT,
    apellido TEXT,
    fecha_nacimiento TEXT,
    nacionalidad TEXT,
    url TEXT
);

-- TABLA TEMPORAL TIEMPO VUELTAS
\echo ''
\echo 'Creando tabla temporal "tiempo_vueltas_temp"...'
CREATE TABLE IF NOT EXISTS temp.tiempo_vueltas_temp (
    carrera_id TEXT,
    piloto_id TEXT,
    vuelta TEXT,
    posicion TEXT,
    tiempo TEXT,
    milisegundos TEXT
);

-- TABLA TEMPORAL PARADAS EN BOXES
\echo ''
\echo 'Creando tabla temporal "paradas_boxes_temp"...'
CREATE TABLE IF NOT EXISTS temp.paradas_boxes_temp (
    carrera_id TEXT,
    piloto_id TEXT,
    parada TEXT,
    vuelta TEXT,
    tiempo TEXT,
    duracion TEXT,
    milisegundos TEXT
);

-- TABLA TEMPORAL CLASIFICACIONES
\echo ''
\echo 'Creando tabla temporal "clasificaciones_temp"...'
CREATE TABLE IF NOT EXISTS temp.clasificaciones_temp (
    clasificaciones_id TEXT,
    carrera_id TEXT,
    piloto_id TEXT,
    escuderia_id TEXT,
    numero TEXT,
    posicion TEXT,
    q1 TEXT,
    q2 TEXT,
    q3 TEXT
);

-- TABLA TEMPORAL CARRERAS
\echo ''
\echo 'Creando tabla temporal "carreras_temp"...'
CREATE TABLE IF NOT EXISTS temp.carreras_temp (
    carrera_id TEXT,
    anio TEXT,
    ronda TEXT,
    circuito_id TEXT,
    nombre TEXT,
    fecha TEXT,
    tiempo TEXT,
    url TEXT,
    fp1_date TEXT,
    fp1_time TEXT,
    fp2_date TEXT,
    fp2_time TEXT,
    fp3_date TEXT,
    fp3_time TEXT,
    quali_date TEXT,
    quali_time TEXT,
    sprint_date TEXT,
    sprint_time TEXT
);

-- TABLA TEMPORAL RESULTADOS
\echo ''
\echo 'Creando tabla temporal "resultados_temp"...'
CREATE TABLE IF NOT EXISTS temp.resultados_temp (
    resultado_id TEXT,
    carrera_id TEXT,
    piloto_id TEXT,
    escuderia_id TEXT,
    numero TEXT,
    posicion_parrilla TEXT,
    posicion_final TEXT,
    posicion_texto TEXT,
    posicicion_orden TEXT,
    puntos TEXT,
    vueltas TEXT,
    tiempo TEXT,
    milisegundos TEXT,
    vuelta_rapida TEXT,
    rank TEXT,
    vuelta_rapida_tiempo TEXT,
    vuelta_rapida_velocidad TEXT,
    status_id TEXT
);

-- TABLA TEMPORAL TEMPORADAS
\echo ''
\echo 'Creando tabla temporal "temporadas_temp"...'
CREATE TABLE IF NOT EXISTS temp.temporadas_temp (
    anio TEXT,
    url TEXT
);

-- TABLA TEMPORAL ESTADO
\echo ''
\echo 'Creando tabla temporal "estado_temp"...'
CREATE TABLE IF NOT EXISTS temp.estado_temp (
    estado_id TEXT,
    estado TEXT
);

\echo ''
\echo 'Esquema y tablas creadas correctamente.'
\echo ''

\echo '========================================================='
\echo 'Creando esquema principal y tablas...'
\echo '========================================================='
\echo ''
\echo 'Creando esquema principal...'
CREATE SCHEMA IF NOT EXISTS ddbb;

-- ======================= ENTIDADES FUERTES (Y STATUS) =======================
-- TABLA PILOTOS
\echo ''
\echo 'Creando tabla "pilotos"...'
CREATE TABLE IF NOT EXISTS ddbb.pilotos (
    piloto_ref VARCHAR NOT NULL,
    numero INT,
    codigo VARCHAR(3), -- Codigos siempre de 3 letras
    nombre VARCHAR NOT NULL,
    apellido VARCHAR NOT NULL,
    fecha_nacimiento DATE,
    nacionalidad VARCHAR,
    url TEXT,

    PRIMARY KEY (piloto_ref)
);

-- TABLA ESCUDERiAS
\echo ''
\echo 'Creando tabla "escuderias"...'
CREATE TABLE IF NOT EXISTS ddbb.escuderias (
    escuderia_ref VARCHAR NOT NULL,
    nombre VARCHAR NOT NULL,
    nacionalidad VARCHAR,
    url TEXT,

    PRIMARY KEY (escuderia_ref)
);

-- TABLA CIRCUITOS
\echo ''
\echo 'Creando tabla "circuitos"...'
CREATE TABLE IF NOT EXISTS ddbb.circuitos (
    circuito_ref VARCHAR NOT NULL,
    nombre VARCHAR NOT NULL,
    localizacion VARCHAR,
    ciudad VARCHAR,
    latitud FLOAT,
    longitud FLOAT,
    altura FLOAT,
    url TEXT,

    PRIMARY KEY (circuito_ref)
);

-- TABLA TEMPORADAS
\echo ''
\echo 'Creando tabla "temporadas"...'
CREATE TABLE IF NOT EXISTS ddbb.temporadas (
    anio INT NOT NULL,
    url TEXT,

    PRIMARY KEY (anio)
);

-- TABLA STATUS
\echo ''
\echo 'Creando tabla "status"...'
CREATE TABLE IF NOT EXISTS ddbb.status (
    estado_id INT NOT NULL,
    estado VARCHAR,

    PRIMARY KEY (estado_id)
);

-- ======================= ENTIDADES DeBILES Y RELACIONES =======================
-- TABLA CARRERAS
\echo ''
\echo 'Creando tabla "carreras"...'
CREATE TABLE IF NOT EXISTS ddbb.carreras (
    anio INT NOT NULL,
    circuito_ref VARCHAR NOT NULL,
    nombre VARCHAR NOT NULL,
    ronda INT,
    fecha_hora TIMESTAMP,
    url TEXT,

    -- PK compuesta formada por la PK de temporada, la PK de circuito (sus entidades fuertes) 
    -- y el nombre de la carrera (atributo identificador de la entidad debil).
    PRIMARY KEY (anio, circuito_ref, nombre),

    -- FK hacia temporada y circuito
    FOREIGN KEY (anio) 
        REFERENCES ddbb.temporadas(anio),

    FOREIGN KEY (circuito_ref) 
        REFERENCES ddbb.circuitos(circuito_ref)
);

-- TABLA VUELTAS
\echo ''
\echo 'Creando tabla "vueltas"...'
CREATE TABLE IF NOT EXISTS ddbb.vueltas (
    piloto_ref VARCHAR NOT NULL,
    nombre_carrera VARCHAR NOT NULL,
    anio_carrera INT NOT NULL,
    circuito_ref_carrera VARCHAR NOT NULL,
    n_vuelta INT NOT NULL,
    posicion INT,
    tiempo TIME,

    -- PK compuesta formada por la PK de piloto y la PK de carrera (sus entidades fuertes) y 
    --  el numero de vuelta (atributo identificador de la entidad debil).
    -- (Para saber la vuelta de un piloto en una carrera concreta necesitamos saber que piloto 
    --  y en que carrera hizo la vuelta).
    PRIMARY KEY (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, n_vuelta),

    -- FK hacia piloto y carrera
    FOREIGN KEY (piloto_ref) 
        REFERENCES ddbb.pilotos(piloto_ref),

    FOREIGN KEY (nombre_carrera, anio_carrera, circuito_ref_carrera) 
        REFERENCES ddbb.carreras(nombre, anio, circuito_ref)
);

-- TABLA PARADAS EN BOXES
\echo ''
\echo 'Creando tabla "boxes"...'
CREATE TABLE IF NOT EXISTS ddbb.boxes (
    -- Esta es la PK/FK compuesta que referencia a la tabla "vueltas"
    piloto_ref VARCHAR NOT NULL,
    nombre_carrera VARCHAR NOT NULL,
    anio_carrera INT NOT NULL,
    circuito_ref_carrera VARCHAR NOT NULL,
    n_vuelta INT NOT NULL, -- Debe ser NOT NULL para que funcione la FK

    -- Atributos especificos de "paradas en boxes"
    -- parada INT, -- Atributo de la relacion "Realiza Pit Stop" entre "Vueltas" y "Boxes"
    tiempo TIME,
    hora TIME,

    -- PK compuesta (misma que la de "vueltas").
    PRIMARY KEY (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, n_vuelta),

    -- FK (relacion 1:1).
    -- Cada fila de "boxes" DEBE corresponder a una fila existente en "vueltas".
    FOREIGN KEY (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, n_vuelta) 
        REFERENCES ddbb.vueltas(piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, n_vuelta)

    -- ¿Por que no movemos los atributos de "paradas en boxes" a la tabla "vueltas" directamente?
    -- Si un piloto no para en una vuelta, esas tres columnas son NULL. Si para, se rellenan. 
    -- Es mas simple y rapido de consultar.
);

-- TABLA RELACION "CALIFICA" PILOTO-CARRERAS
\echo ''
\echo 'Creando tabla "califica"...'
CREATE TABLE IF NOT EXISTS ddbb.califica (
    piloto_ref VARCHAR NOT NULL,
    nombre_carrera VARCHAR NOT NULL,
    anio_carrera INT NOT NULL,
    circuito_ref_carrera VARCHAR NOT NULL,
    posicion INT,
    q1 TIME,
    q2 TIME,
    q3 TIME,

    -- PK compuesta formada por la PK de piloto y la PK de carrera (sus entidades fuertes).
    PRIMARY KEY (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera),

    -- FK hacia piloto y carrera
    FOREIGN KEY (piloto_ref) 
        REFERENCES ddbb.pilotos(piloto_ref),

    FOREIGN KEY (nombre_carrera, anio_carrera, circuito_ref_carrera) 
        REFERENCES ddbb.carreras(nombre, anio, circuito_ref)
);

-- TABLA RELACION "CORRE" PILOTO-ESCUDERIA-CARRERA
\echo ''
\echo 'Creando tabla "corre"...'
CREATE TABLE IF NOT EXISTS ddbb.corre (
    piloto_ref VARCHAR NOT NULL,
    nombre_carrera VARCHAR NOT NULL,
    anio_carrera INT NOT NULL,
    circuito_ref_carrera VARCHAR NOT NULL,
    escuderia_ref VARCHAR NOT NULL,

    posicion INT,
    puntos FLOAT,
    estado VARCHAR,

    -- PK compuesta formada por la PK de piloto, la PK de carrera y la PK de escuderia 
    -- (sus entidades fuertes).
    PRIMARY KEY (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, escuderia_ref),

    -- FK hacia piloto, escuderia y carrera
    FOREIGN KEY (piloto_ref) 
        REFERENCES ddbb.pilotos(piloto_ref),

    FOREIGN KEY (escuderia_ref) 
        REFERENCES ddbb.escuderias(escuderia_ref),

    FOREIGN KEY (nombre_carrera, anio_carrera, circuito_ref_carrera) 
        REFERENCES ddbb.carreras(nombre, anio, circuito_ref)
);

\echo ''
\echo 'Esquema y tablas creadas correctamente.'
\echo ''

\echo '========================================================='
\echo 'Cargando datos en las tablas temporales...'
\echo '========================================================='

-- NOTA: Rutas actualizadas a 'data/*.csv' para ejecucion desde la raiz del modulo '01-bases-de-datos'
-- (En la entrega original se ejecutaba con los CSV en el mismo directorio).

-- TABLA TEMPORAL CIRCUITOS
\echo ''
\echo 'Cargando datos en la tabla temporal "circuitos_temp"...'
\COPY temp.circuitos_temp FROM data/circuits.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL ESCUDERiAS
\echo ''
\echo 'Cargando datos en la tabla temporal "escuderias_temp"...'
\COPY temp.escuderias_temp FROM data/constructors.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL PILOTOS
\echo ''
\echo 'Cargando datos en la tabla temporal "pilotos_temp"...'
\COPY temp.pilotos_temp FROM data/drivers.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL TIEMPO VUELTAS
\echo ''
\echo 'Cargando datos en la tabla temporal "tiempo_vueltas_temp"...'
\COPY temp.tiempo_vueltas_temp FROM data/lap_times.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL PARADAS EN BOXES
\echo ''
\echo 'Cargando datos en la tabla temporal "paradas_boxes_temp"...'
\COPY temp.paradas_boxes_temp FROM data/pit_stops.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL CLASIFICACIONES
\echo ''
\echo 'Cargando datos en la tabla temporal "clasificaciones_temp"...'
\COPY temp.clasificaciones_temp FROM data/qualifying.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL CARRERAS
\echo ''
\echo 'Cargando datos en la tabla temporal "carreras_temp"...'
\COPY temp.carreras_temp FROM data/races.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL RESULTADOS
\echo ''
\echo 'Cargando datos en la tabla temporal "resultados_temp"...'
\COPY temp.resultados_temp FROM data/results.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL TEMPORADAS
\echo ''
\echo 'Cargando datos en la tabla temporal "temporadas_temp"...'
\COPY temp.temporadas_temp FROM data/seasons.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

-- TABLA TEMPORAL ESTADO
\echo ''
\echo 'Cargando datos en la tabla temporal "estado_temp"...'
\COPY temp.estado_temp FROM data/status.csv WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', NULL 'NULL', ENCODING 'UTF8');

\echo ''
\echo 'Datos cargados correctamente en las tablas temporales.'
\echo ''

\echo '========================================================='
\echo 'Moviendo datos del esquema temporal al esquema principal...'
\echo '========================================================='

-- 1. Migramos tablas independientes (sin FKs)
-- Inserta TEMPORADAS
\echo ''
\echo 'Insertando datos en la tabla "temporadas"...'
INSERT INTO ddbb.temporadas (anio, url)
SELECT DISTINCT
    anio::INT AS anio, -- NOT NULL
    url::TEXT AS url
FROM temp.temporadas_temp;

\echo ''
\echo 'Mostrando 10 filas de la tabla "temporadas":'
SELECT * FROM ddbb.temporadas ORDER BY RANDOM() LIMIT 10;

-- Inserta CIRCUITOS
\echo ''
\echo 'Insertando datos en la tabla "circuitos"...'
INSERT INTO ddbb.circuitos (circuito_ref, nombre, localizacion, ciudad, latitud, longitud, altura, url)
SELECT DISTINCT
    circuito_ref::VARCHAR AS circuito_ref, -- NOT NULL
    nombre::VARCHAR AS nombre,
    localizacion::VARCHAR AS localizacion,
    ciudad::VARCHAR AS ciudad,
    latitud::FLOAT AS latitud,
    longitud::FLOAT AS longitud,
    altura::FLOAT AS altura,
    url::TEXT AS url
FROM temp.circuitos_temp;

\echo ''
\echo 'Mostrando 10 filas de la tabla "circuitos":'
SELECT * FROM ddbb.circuitos ORDER BY RANDOM() LIMIT 10;

-- Inserta PILOTOS
\echo ''
\echo 'Insertando datos en la tabla "pilotos"...'
INSERT INTO ddbb.pilotos (piloto_ref, numero, codigo, nombre, apellido, fecha_nacimiento, nacionalidad, url)
SELECT DISTINCT
    piloto_ref::VARCHAR AS piloto_ref, -- NOT NULL

    CASE -- Manejamos valores nulos en 'numero'
        WHEN numero IS NULL OR numero = '\N' THEN NULL 
        ELSE numero::INT 
    END AS numero,
    
    CASE -- Manejamos valores nulos en 'codigo'
        WHEN codigo IS NULL OR codigo = '\N' THEN NULL 
        ELSE codigo::VARCHAR 
    END AS codigo,

    nombre::VARCHAR AS nombre,
    apellido::VARCHAR AS apellido,

    -- Manejamos el formato de las fechas para convertir de YYYY--MM-DD a DD-MM-YYYY
    CASE 
        -- Para formato YYYY-MM-DD (revisamos el 5º caracter)
        WHEN SUBSTRING(fecha_nacimiento, 5, 1) = '-'
            THEN TO_DATE(fecha_nacimiento, 'YYYY-MM-DD')

        -- Para formato DD-MM-YYYY (revisamos el 3º caracter)
        WHEN SUBSTRING(fecha_nacimiento, 3, 1) = '/'
            THEN TO_DATE(fecha_nacimiento, 'DD/MM/YYYY')
    END AS fecha_nacimiento,

    nacionalidad::VARCHAR AS nacionalidad,
    url::TEXT AS url

FROM temp.pilotos_temp;

\echo ''
\echo 'Mostrando 10 filas de la tabla "pilotos":'
SELECT * FROM ddbb.pilotos ORDER BY RANDOM() LIMIT 10;

-- Inserta ESCUDERiAS
\echo ''
\echo 'Insertando datos en la tabla "escuderias"...'
INSERT INTO ddbb.escuderias (escuderia_ref, nombre, nacionalidad, url)
SELECT DISTINCT
    escuderia_ref::VARCHAR AS escuderia_ref, -- NOT NULL
    nombre::VARCHAR AS nombre,
    nacionalidad::VARCHAR AS nacionalidad,
    url::TEXT AS url
FROM temp.escuderias_temp;

\echo 'Mostrando 10 filas de la tabla "escuderias":'
SELECT * FROM ddbb.escuderias ORDER BY RANDOM() LIMIT 10;

-- Inserta STATUS
\echo ''
\echo 'Insertando datos en la tabla "status"...'
INSERT INTO ddbb.status (estado_id, estado)
SELECT DISTINCT
    estado_id::INT AS estado_id, -- NOT NULL
    estado::VARCHAR AS estado
FROM temp.estado_temp;

\echo ''
\echo 'Mostrando 10 filas de la tabla "status":'
SELECT * FROM ddbb.status ORDER BY RANDOM() LIMIT 10;

-- 2. Migramos tablas dependientes (requieren JOINS)
-- Inserta CARRERAS
\echo ''
\echo 'Insertando datos en la tabla "carreras"...'
INSERT INTO ddbb.carreras (anio, circuito_ref, nombre, ronda, fecha_hora, url)
SELECT DISTINCT
    -- Obtenemos el año de la temporada directamente de la tabla temporal de carreras en vez de la de temporadas
    -- Asi, evitamos hacer un JOIN innecesario
    gp.anio::INT AS anio, 
    c.circuito_ref::VARCHAR AS circuito_ref, -- JOIN con circuitos_temp
    gp.nombre::VARCHAR AS nombre,
    gp.ronda::INT AS ronda,
    
    -- Combinamos las columnas de fecha y hora en un solo TIMESTAMP
    CASE
        -- Manejamos los nulos
        WHEN fecha IS NULL OR fecha = '\N' OR tiempo IS NULL OR tiempo = '\N'
            THEN NULL

        -- Formato DD/MM/YYYY
        WHEN SUBSTRING(fecha, 3, 1) = '/'
            THEN TO_TIMESTAMP(fecha || ' ' || tiempo, 'DD/MM/YYYY HH24:MI:SS')

        -- Formato YYYY-MM-DD
        WHEN SUBSTRING(fecha, 5, 1) = '-'
            THEN TO_TIMESTAMP(fecha || ' ' || tiempo, 'YYYY-MM-DD HH24:MI:SS')

        ELSE NULL
    END AS fecha_hora,

    gp.url::TEXT AS url

FROM temp.carreras_temp gp
JOIN temp.circuitos_temp c ON gp.circuito_id = c.circuito_id;

\echo ''
\echo 'Mostrando 10 filas de la tabla "carreras":'
SELECT * FROM ddbb.carreras ORDER BY RANDOM() LIMIT 10;

-- Inserta VUELTAS
\echo ''
\echo 'Insertando datos en la tabla "vueltas"...'
INSERT INTO ddbb.vueltas (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, n_vuelta, posicion, tiempo)
SELECT DISTINCT
    p.piloto_ref::VARCHAR AS piloto_ref, -- NOT NULL
    gp.nombre::VARCHAR AS nombre_carrera, -- NOT NULL
    gp.anio::INT AS anio_carrera, -- NOT NULL
    c.circuito_ref::VARCHAR AS circuito_ref_carrera, -- NOT NULL
    lt.vuelta::INT AS n_vuelta,
    lt.posicion::INT AS posicion,

    -- Convertimos el tiempo de formato TEXT a TIME
    CASE 
        WHEN lt.tiempo IS NULL OR lt.tiempo = '\N' 
            THEN NULL
        ELSE TO_TIMESTAMP(lt.tiempo, 'MI:SS.MS')::TIME
    END AS tiempo

FROM temp.tiempo_vueltas_temp lt
JOIN temp.pilotos_temp p ON lt.piloto_id = p.piloto_id
JOIN temp.carreras_temp gp ON lt.carrera_id = gp.carrera_id
-- JOIN con circuitos_temp para obtener el circuito_ref
JOIN temp.circuitos_temp c ON gp.circuito_id = c.circuito_id;

\echo ''
\echo 'Mostrando 10 filas de la tabla "vueltas":'
SELECT * FROM ddbb.vueltas ORDER BY RANDOM() LIMIT 10;

-- Inserta PARADAS EN BOXES
\echo ''
\echo 'Insertando datos en la tabla "boxes"...'
INSERT INTO ddbb.boxes (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, n_vuelta, tiempo, hora)
SELECT DISTINCT
    p.piloto_ref::VARCHAR AS piloto_ref,
    gp.nombre::VARCHAR AS nombre_carrera,
    gp.anio::INT AS anio_carrera, 
    c.circuito_ref::VARCHAR AS circuito_ref_carrera,
    b.vuelta::INT AS n_vuelta,

    -- Convertimos el tiempo de formato TEXT a TIME:
    -- 1. Convertimos b.duracion (ej: '22.640') a un intervalo de segundos
    -- 2. Luego lo pasamos a un tipo TIME
    CASE
        WHEN b.duracion IS NULL OR b.duracion = '\N' 
            THEN NULL
        ELSE (b.duracion || ' seconds')::INTERVAL::TIME
    END AS tiempo,

    CASE -- Convertimos la hora de formato TEXT a TIMESTAMP
        WHEN b.tiempo IS NULL OR b.tiempo = '\N' 
            THEN NULL
        ELSE TO_TIMESTAMP(b.tiempo, 'HH24:MI:SS')
    END AS hora

FROM temp.paradas_boxes_temp b
JOIN temp.pilotos_temp p ON b.piloto_id = p.piloto_id
JOIN temp.carreras_temp gp ON b.carrera_id = gp.carrera_id
JOIN temp.circuitos_temp c ON gp.circuito_id = c.circuito_id;

\echo ''
\echo 'Mostrando 10 filas de la tabla "boxes":'
SELECT * FROM ddbb.boxes ORDER BY RANDOM() LIMIT 10;

-- Inserta CALIFICACIONES
\echo ''
\echo 'Insertando datos en la tabla "califica"...'
INSERT INTO ddbb.califica (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, posicion, q1, q2, q3)
SELECT DISTINCT
    p.piloto_ref::VARCHAR AS piloto_ref, 
    gp.nombre::VARCHAR AS nombre_carrera,
    gp.anio::INT AS anio_carrera, 
    c.circuito_ref::VARCHAR AS circuito_ref_carrera,
    cl.posicion::INT AS posicion,

    -- Convertimos las columnas de tiempo de formato TEXT a TIME
    CASE 
        WHEN cl.q1 IS NULL OR cl.q1 = '\N' 
            THEN NULL
        ELSE TO_TIMESTAMP(cl.q1, 'MI:SS.MS')::TIME
    END AS q1,

    CASE 
        WHEN cl.q2 IS NULL OR cl.q2 = '\N' 
            THEN NULL
        ELSE TO_TIMESTAMP(cl.q2, 'MI:SS.MS')::TIME
    END AS q2,

    CASE 
        WHEN cl.q3 IS NULL OR cl.q3 = '\N' 
            THEN NULL
        ELSE TO_TIMESTAMP(cl.q3, 'MI:SS.MS')::TIME
    END AS q3

FROM temp.clasificaciones_temp cl
JOIN temp.pilotos_temp p ON cl.piloto_id = p.piloto_id
JOIN temp.carreras_temp gp ON cl.carrera_id = gp.carrera_id
JOIN temp.circuitos_temp c ON gp.circuito_id = c.circuito_id;

\echo ''
\echo 'Mostrando 10 filas de la tabla "califica":'
SELECT * FROM ddbb.califica ORDER BY RANDOM() LIMIT 10;

-- Inserta CORRE
\echo ''
\echo 'Insertando datos en la tabla "corre"...'
INSERT INTO ddbb.corre (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, escuderia_ref, posicion, puntos, estado)
SELECT DISTINCT ON ( -- Para evitar duplicados en la PK compuesta
    p.piloto_ref,
    gp.nombre,
    gp.anio,
    c.circuito_ref,
    e.escuderia_ref
)
    p.piloto_ref::VARCHAR AS piloto_ref, 
    gp.nombre::VARCHAR AS nombre_carrera,
    gp.anio::INT AS anio_carrera, 
    c.circuito_ref::VARCHAR AS circuito_ref_carrera,
    e.escuderia_ref::VARCHAR AS escuderia_ref,

    CASE -- Manejamos nulos en posicion_final
        WHEN r.posicion_final IS NULL OR r.posicion_final = '\N'
            THEN NULL
        ELSE r.posicion_final::INT
    END AS posicion,
    
    r.puntos::FLOAT AS puntos,
    s.estado::VARCHAR AS estado

FROM temp.resultados_temp r
JOIN temp.pilotos_temp p ON r.piloto_id = p.piloto_id
JOIN temp.carreras_temp gp ON r.carrera_id = gp.carrera_id
JOIN temp.circuitos_temp c ON gp.circuito_id = c.circuito_id
JOIN temp.escuderias_temp e ON r.escuderia_id = e.escuderia_id
JOIN temp.estado_temp s ON r.status_id = s.estado_id

-- Ordenamos para que DISTINCT ON funcione correctamente
ORDER BY
    p.piloto_ref,
    gp.nombre,
    gp.anio,
    c.circuito_ref,
    e.escuderia_ref,
    
    -- Ordenamos por posicion_final ascendente, tratando los nulos como el valor mas alto (99)
    CASE
        WHEN r.posicion_final IS NULL OR r.posicion_final = '\N'
            THEN 99
        ELSE r.posicion_final::INT
    END ASC; -- Prioriza las filas con menor posicion_final

\echo ''
\echo 'Mostrando 10 filas de la tabla "corre":'
SELECT * FROM ddbb.corre ORDER BY RANDOM() LIMIT 10;

\echo ''
\echo 'Datos insertados correctamente en el esquema principal.'
\echo ''

-- Eliminamos el esquema temporal y todas sus tablas
\echo '========================================================='
\echo 'Limpiando esquema temporal...'
\echo '========================================================='
\echo ''

DROP SCHEMA IF EXISTS temp CASCADE;

\echo ''
\echo 'Esquema temporal eliminado correctamente.'
\echo ''
\echo ' // FINALIZADA LA CREACION DE LA BASE DE DATOS "FORMULAONE" // '
\echo ''
COMMIT;
-- Punto de control tras la creacion de la base de datos
-- Los datos ya estan guardados permanentemente
-- Si el script falla mas adelante, la base de datos seguira existiendo

-- Para las consultas no es necesario hacer un BEGIN/COMMIT
\echo '=================================================================='
\echo '<< INICIANDO LAS CONSULTAS A LA BASE DE DATOS "FORMULAONE" >>'
\echo 'BLOQUE 2: CONSULTAS A LA BASE DE DATOS'
\echo '=================================================================='

-- CONSULTA 1: Haga un listado de todos los circuitos, asi como el numero de grandes premios que ha 
-- albergado cada uno. El listado estara ordenado del circuito que haya acogido mas carreras al que menos
\echo ''
\echo 'Consulta 1: Listado de circuitos y numero de grandes premios alojados'
\echo '-------------------------------------------------------------------------'

SELECT
    c.nombre AS circuito,
    COUNT(*) AS numero_grandes_premios
FROM 
    ddbb.circuitos c
JOIN
    -- Unimos con la tabla de carreras para contar los "Grandes Premios" que hay por circuito
    ddbb.carreras gp ON c.circuito_ref = gp.circuito_ref
GROUP BY
    -- Agrupamos por circuito (referencia y nombre)
    c.circuito_ref, c.nombre
ORDER BY
    -- Ordenamos de mayor a menor numero de grandes premios
    numero_grandes_premios DESC;

-- CONSULTA 2: Muestre el numero de grandes premios que ha corrido Ayrton Senna asi como el total 
--  de puntos conseguidos en las mismas.
\echo ''
\echo 'Consulta 2: Grandes Premios corridos y puntos totales de Ayrton Senna'
\echo '-------------------------------------------------------------------------'

SELECT 
    -- Contamos el numero de GPs que ha corrido Ayrton Senna
    COUNT (co.piloto_ref) AS numero_grandes_premios,
    -- Sumamos los puntos conseguidos en esos GPs
    SUM (co.puntos) AS puntos_totales
FROM 
    ddbb.corre co
JOIN
    -- Unimos con pilotos para filtrar por nombre
    ddbb.pilotos p ON co.piloto_ref = p.piloto_ref
WHERE 
    p.nombre = 'Ayrton' AND p.apellido = 'Senna';

-- CONSULTA 3: Haga un listado con el nombre y apellidos de todos los pilotos nacidos despues del 31 de diciembre de 1999, 
-- junto con el numero de carreras en las que haya participado cada uno de ellos.
\echo ''
\echo 'Consulta 3: Pilotos nacidos despues del 31/12/1999 y sus carreras'
\echo '-------------------------------------------------------------------------'

SELECT 
    p.nombre,
    p.apellido,
    -- Contamos las filas en la tabla "corre" para saber en cuantas carreras ha participado cada piloto
    COUNT (*) AS numero_carreras
FROM 
    ddbb.pilotos p
JOIN
    -- Unimos con la tabla "corre" para contar las carreras
    ddbb.corre co ON p.piloto_ref = co.piloto_ref
WHERE
    -- Filtramos por fecha de nacimiento
    p.fecha_nacimiento > '1999-12-31'
GROUP BY
    -- Agrupamos por piloto (referencia, nombre y apellido)
    p.piloto_ref, p.nombre, p.apellido
ORDER BY
    -- Ordenamos para ver primero los pilotos con mas carreras
    numero_carreras DESC;

-- CONSULTA 4: Muestre el nombre de todas las escuderias españolas o italianas junto con el numero de grandes premios corridos.
\echo ''
\echo 'Consulta 4: Escuderias espaniolas o italianas y sus grandes premios corridos'
\echo '-------------------------------------------------------------------------'

SELECT
    e.nombre,
    e.nacionalidad,
    -- Contamos el numero de grandes premios corridos por cada escuderia
    COUNT (*) AS numero_participaciones
FROM
    ddbb.escuderias e
JOIN
    -- Unimos con la tabla "corre" para contar las participaciones
    ddbb.corre co ON e.escuderia_ref = co.escuderia_ref
WHERE
    -- Filtramos por nacionalidad española o italiana
    e.nacionalidad = 'Spanish' OR e.nacionalidad = 'Italian'
GROUP BY
    -- Agrupamos por escuderia (referencia, nombre y nacionalidad)
    e.escuderia_ref, e.nombre, e.nacionalidad
ORDER BY
    -- Ordenamos para ver primero las escuderias con mas participaciones
    numero_participaciones DESC;


-- CONSULTA 5: Crea una vista donde para cada temporada se muestren los pilotos que han corrido en la misma, 
-- asi como los puntos totales que han obtenido cada uno en esa temporada.
\echo ''
\echo 'Consulta 5: Vista de pilotos y puntos totales por temporada'
\echo '-------------------------------------------------------------------------'
CREATE OR REPLACE VIEW ddbb.vista_puntos_por_temporada AS
SELECT
    co.anio_carrera AS temporada,
    p.nombre,
    p.apellido,
    -- Sumamos los puntos obtenidos por cada piloto en la temporada
    SUM (co.puntos) AS puntos_totales_temporada
FROM
    ddbb.corre co
JOIN
    -- Unimos con la tabla pilotos para obtener nombre y apellido
    ddbb.pilotos p ON co.piloto_ref = p.piloto_ref
GROUP BY
    -- Agrupamos por año (temporada) y piloto (referencia, nombre y apellido)
    co.anio_carrera, 
    p.piloto_ref, p.nombre, p.apellido
ORDER BY
    -- Ordenamos para ver primero los resultados mas recientes
    temporada DESC,
    puntos_totales_temporada DESC;

\echo ''
\echo 'Vista "vista_puntos_por_temporada" creada correctamente.'

-- CONSULTA 6: Utilizando dicha vista obtén el nombre de los pilotos ganadores en las temporadas
-- del 2010 al 2015 inclusive
\echo ''
\echo 'Consulta 6: Pilotos ganadores de las temporadas 2010-2015'
\echo '-------------------------------------------------------------------------'
SELECT DISTINCT ON (vp.temporada)
    vp.temporada,
    vp.nombre,
    vp.apellido,
    vp.puntos_totales_temporada
FROM
    -- Consultamos directamente la vista creada en la consulta anterior
    ddbb.vista_puntos_por_temporada vp
WHERE
    vp.temporada BETWEEN 2010 AND 2015
ORDER BY
    -- Ordenamos por temporada para que DISTINCT ON funcione correctamente
    -- Y seleccionamos el piloto con mas puntos en cada temporada
    vp.temporada DESC, 
    vp.puntos_totales_temporada DESC;

-- CONSULTA 7: Obtener el nombre de los pilotos que han ganado al menos un GP (posición = 1)
\echo ''
\echo 'Consulta 7: Pilotos que han ganado al menos un Gran Premio'
\echo '-------------------------------------------------------------------------'
SELECT DISTINCT
    p.nombre,
    p.apellido
FROM
    ddbb.pilotos p
JOIN
    ddbb.corre co ON p.piloto_ref = co.piloto_ref
WHERE
    -- Filtramos por posicion 1 (ganadores)
    co.posicion = 1
ORDER BY
    p.apellido, 
    p.nombre;

-- CONSULTA 8: Mostrar el número de Grandes Premios por país
\echo ''
\echo 'Consulta 8: Numero de Grandes Premios por pais'
\echo '-------------------------------------------------------------------------'
SELECT
    c.ciudad AS pais,
    COUNT (*) AS numero_grandes_premios
FROM
    ddbb.circuitos c
JOIN
    -- Unimos con la tabla de carreras para contar los "Grandes Premios" por pais
    ddbb.carreras gp ON c.circuito_ref = gp.circuito_ref
GROUP BY
    -- Agrupamos por ciudad
    c.ciudad
ORDER BY
    numero_grandes_premios DESC;

-- CONSULTA 9: Mostrar el piloto con la vuelta más rápida en toda la historia 
-- (Se prohíbe el uso de la sentencia LIMIT)
\echo ''
\echo 'Consulta 9: Piloto con la vuelta mas rapida en la historia'
\echo '-------------------------------------------------------------------------'
-- La columna "tiempo" en la tabla "vueltas" es de tipo TIME, por lo que podemos usar MIN directamente
SELECT
    p.nombre,
    p.apellido,
    v.tiempo AS vuelta_mas_rapida
FROM
    ddbb.vueltas v
JOIN
    -- Unimos con la tabla pilotos para obtener nombre y apellido
    ddbb.pilotos p ON v.piloto_ref = p.piloto_ref
WHERE
    -- La vuelta mas rapida sera aquella cuyo tiempo sea igual al minimo tiempo registrado
    v.tiempo = (
        SELECT MIN (tiempo) 
        FROM ddbb.vueltas
        WHERE tiempo > '00:00:00' -- Excluimos tiempos nulos o invalidos
    );

-- CONSULTA 10: Mostrar el número de paradas en boxes por piloto en el gran premio de Monaco de 2023
\echo ''
\echo 'Consulta 10: Numero de paradas en boxes por piloto en el GP de Monaco 2023'
\echo '-------------------------------------------------------------------------'
SELECT
    p.nombre,
    p.apellido,
    COUNT(*) AS numero_paradas
FROM
    ddbb.boxes b

-- Hacemos varios JOINs para filtrar por el gran premio de Monaco de 2023
-- Se hacen varios JOINs porque la tabla "boxes" solo tiene referencia a piloto y carrera
-- Necesitamos llegar a la tabla "carreras" para filtrar por el gran premio concreto
JOIN
    -- Unimos con la tabla "corre" para filtrar por carrera concreta
    ddbb.corre co ON 
        -- Relacionamos los siguientes campos para identificar la carrera
        -- Es necesario relacionar todos estos campos ya que la PK de "corre" es compuesta
        -- Relacionamos por piloto
        b.piloto_ref = co.piloto_ref AND
        -- Relacionamos por carrera
        b.nombre_carrera = co.nombre_carrera AND
        -- Relacionamos por año y circuito
        b.anio_carrera = co.anio_carrera AND
        -- Relacionamos por circuito
        b.circuito_ref_carrera = co.circuito_ref_carrera
JOIN
    -- Unimos con la tabla "carreras" para filtrar por el gran premio de Monaco de 2023
    ddbb.carreras ca ON 
        -- Relacionamos por carrera
        co.nombre_carrera = ca.nombre AND
        -- Relacionamos por año y circuito
        co.anio_carrera = ca.anio AND
        -- Relacionamos por circuito
        co.circuito_ref_carrera = ca.circuito_ref
JOIN
    -- Por ultimo, unimos con la tabla pilotos para obtener nombre y apellido
    ddbb.pilotos p ON co.piloto_ref = p.piloto_ref
WHERE
    -- Filtramos por el gran premio de Monaco de 2023
    ca.nombre = 'Monaco Grand Prix'
    AND ca.anio = 2023
GROUP BY
    -- Agrupamos por piloto (referencia, nombre y apellido)
    p.nombre, 
    p.apellido
ORDER BY
    numero_paradas DESC;

-- CONSULTA 11: Mostrar el nombre de los pilotos que hayan participado en más de 100 premios
-- ordenados por aquellos que hayan participado en más grandes premios
\echo ''
\echo 'Consulta 11: Pilotos con mas de 100 grandes premios'
\echo '-------------------------------------------------------------------------'
SELECT
    p.nombre,
    p.apellido,
    COUNT(*) AS numero_grandes_premios
FROM
    ddbb.corre co
JOIN
    -- Unimos con la tabla pilotos para obtener nombre y apellido
    ddbb.pilotos p ON co.piloto_ref = p.piloto_ref
GROUP BY
    p.piloto_ref, 
    p.nombre, 
    p.apellido
HAVING
    -- Filtramos por pilotos con mas de 100 grandes premios
    COUNT(*) > 100
ORDER BY
    numero_grandes_premios DESC;

-- FIN DE LAS CONSULTAS
\echo ''
\echo '// Finalizadas las consultas a la base de datos "FORMULAONE" //'
\echo ''

-- Para las creaciones de triggers es necesario hacer un BEGIN/COMMIT
BEGIN;
\echo '==========================================================================='
\echo '<< INICIANDO LA CREACION DE TRIGGERS EN LA BASE DE DATOS "FORMULAONE" >>'
\echo 'BLOQUE 3: CREACION DE TRIGGERS'
\echo '==========================================================================='

-- Trigger de auditoria para eventos de insercion, modificacion y borrado
-- Registrado: tabla de bbdd, tipo de evento, usuario y fecha y hora
\echo ''
\echo '// Comenzando la creacion del trigger de auditoria //'
\echo ''
\echo 'Creando tabla Auditoria...'
CREATE TABLE IF NOT EXISTS ddbb.auditoria (
    id_aud SERIAL PRIMARY KEY,
    nombre_tabla VARCHAR NOT NULL,
    tipo_evento VARCHAR NOT NULL, -- INSERT, UPDATE, DELETE
    usuario VARCHAR NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

\echo ''
\echo 'Tabla Auditoria creada correctamente.'
\echo ''
\echo 'Creando funcion para el trigger de auditoria...'
CREATE OR REPLACE FUNCTION ddbb.auditoria()
RETURNS TRIGGER AS $$
BEGIN
    -- TG_OP es el tipo de operacion que disparo el trigger (INSERT, UPDATE, DELETE)
    -- TG_TABLE_NAME es el nombre de la tabla que disparo el trigger
    -- CURRENT_USER es el usuario que realizo la operacion

    -- Insertamos un registro en la tabla de auditoria segun el tipo de operacion
    INSERT INTO ddbb.auditoria(nombre_tabla, tipo_evento, usuario, fecha_hora)
    VALUES (
        TG_TABLE_NAME,      -- Nombre de la tabla afectada
        TG_OP,              -- Tipo de evento
        CURRENT_USER,       -- Usuario que realiza la operacion
        CURRENT_TIMESTAMP   -- Fecha y hora actual
    );
    IF (TG_OP = 'DELETE') THEN
        RETURN OLD; -- Para DELETE, retornamos la fila antigua
    ELSE
        RETURN NEW; -- Para INSERT y UPDATE, retornamos la nueva fila
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo ''
\echo 'Funcion para el trigger de auditoria creada correctamente.'
\echo ''

\echo 'Creando trigger de auditoria para todas las tablas del esquema ddbb...'
-- Creamos un trigger para cada tabla del esquema ddbb
\echo ''
\echo 'Creando trigger para la tabla "pilotos"...'
CREATE TRIGGER auditoria_pilotos
AFTER INSERT OR UPDATE OR DELETE ON ddbb.pilotos
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo 'Creando trigger para la tabla "escuderias"...'
CREATE TRIGGER auditoria_escuderias
AFTER INSERT OR UPDATE OR DELETE ON ddbb.escuderias
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo 'Creando trigger para la tabla "circuitos"...'
CREATE TRIGGER auditoria_circuitos
AFTER INSERT OR UPDATE OR DELETE ON ddbb.circuitos
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo 'Creando trigger para la tabla "temporadas"...'
CREATE TRIGGER auditoria_temporadas
AFTER INSERT OR UPDATE OR DELETE ON ddbb.temporadas
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo 'Creando trigger para la tabla "carreras"...'
CREATE TRIGGER auditoria_carreras
AFTER INSERT OR UPDATE OR DELETE ON ddbb.carreras
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo 'Creando trigger para la tabla "vueltas"...'
CREATE TRIGGER auditoria_vueltas
AFTER INSERT OR UPDATE OR DELETE ON ddbb.vueltas
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo 'Creando trigger para la tabla "boxes"...'
CREATE TRIGGER auditoria_boxes
AFTER INSERT OR UPDATE OR DELETE ON ddbb.boxes
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo 'Creando trigger para la tabla "califica"...'
CREATE TRIGGER auditoria_califica
AFTER INSERT OR UPDATE OR DELETE ON ddbb.califica
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo 'Creando trigger para la tabla "corre"...'
CREATE TRIGGER auditoria_corre
AFTER INSERT OR UPDATE OR DELETE ON ddbb.corre
FOR EACH ROW EXECUTE FUNCTION ddbb.auditoria();

\echo ''
\echo '// Triggers de auditoria creados correctamente //'
\echo ''

\echo '// Comenzando la creacion del trigger de control de puntos //'
\echo ''
\echo 'Creando tabla de resumen de puntos...'
CREATE TABLE IF NOT EXISTS ddbb.puntos_pilotos (
    piloto_ref VARCHAR PRIMARY KEY,
    total_puntos FLOAT DEFAULT 0, -- Configuramos valor por defecto 0

    FOREIGN KEY (piloto_ref) 
        REFERENCES ddbb.pilotos(piloto_ref)
);

\echo ''
\echo 'Tabla de resumen de puntos creada correctamente.'
\echo ''

\echo 'Inicializando tabla de resumen de puntos...'
-- Insertamos todos los pilotos con 0 puntos inicialmente
INSERT INTO ddbb.puntos_pilotos (piloto_ref, total_puntos)
SELECT
    piloto_ref,
    -- Convertimos valores NULL a 0 en caso de que no tenga puntos
    SUM(COALESCE(puntos, 0)) AS total_puntos
FROM
    ddbb.corre
GROUP BY
    piloto_ref
-- En caso de que el piloto ya exista, actualizamos sus puntos
ON CONFLICT (piloto_ref) DO UPDATE
-- Actualizamos puntos en caso de conflicto
SET total_puntos = EXCLUDED.total_puntos; 


\echo ''
\echo 'Tabla de resumen de puntos inicializada correctamente.'

\echo ''
\echo 'Creando funcion para el trigger de control de puntos...'
CREATE OR REPLACE FUNCTION ddbb.actualizar_puntos()
RETURNS TRIGGER AS $$
BEGIN
    -- Caso 1: INSERT (nuevo resultado: sumamos puntos)
    IF (TG_OP = 'INSERT') THEN
        -- Intentamos insertar el piloto en la tabla resumen de puntos con sus nuevos puntos
        INSERT INTO ddbb.puntos_pilotos (piloto_ref, total_puntos)
        VALUES (NEW.piloto_ref, COALESCE(NEW.puntos, 0))
        -- Si el piloto ya existe, actualizamos sus puntos
        ON CONFLICT (piloto_ref) DO UPDATE
        SET total_puntos = puntos_pilotos.total_puntos + COALESCE(NEW.puntos, 0);

        RETURN NEW;

    -- Caso 2: UPDATE (modificacion de resultado)
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Buscamos al piloto y actualizamos sus puntos
        -- Total = Actual - Viejos (incorrectos) + Nuevos (correctos)
        UPDATE ddbb.puntos_pilotos
        SET total_puntos = total_puntos - COALESCE(OLD.puntos, 0) + COALESCE(NEW.puntos, 0)
        WHERE piloto_ref = NEW.piloto_ref;

        RETURN NEW;

    -- Caso 3: DELETE (borrado de resultado)
    ELSIF (TG_OP = 'DELETE') THEN
        -- Buscamos al piloto y restamos sus puntos que se van a eliminar
        UPDATE ddbb.puntos_pilotos
        SET total_puntos = total_puntos - COALESCE(OLD.puntos, 0)
        WHERE piloto_ref = OLD.piloto_ref;

        RETURN OLD;
    END IF;
    RETURN NULL; -- No deberia llegar aqui
END;
$$ LANGUAGE plpgsql;

\echo ''
\echo 'Funcion para el trigger de control de puntos creada correctamente.'

\echo ''
\echo 'Creando trigger de control de puntos para la tabla "corre"...'
DROP TRIGGER IF EXISTS control_puntos_corre ON ddbb.corre;
CREATE TRIGGER control_puntos_corre
AFTER INSERT OR UPDATE OR DELETE ON ddbb.corre
FOR EACH ROW EXECUTE FUNCTION ddbb.actualizar_puntos();

\echo ''
\echo '// Trigger de control de puntos creado correctamente //'
\echo ''
\echo '// Finalizada la creacion de triggers en la base de datos "FORMULAONE" //'
\echo ''
COMMIT;
-- Punto de control tras la creacion de los triggers
-- Los triggers ya estan activos permanentemente
-- Si el script falla mas adelante, los triggers seguira existiendo

BEGIN;
-- Para las pruebas de los triggers es necesario hacer un BEGIN/ROLLBACK
-- Asi, podemos deshacer los cambios realizados durante las pruebas
-- para no alterar los datos reales de la base de datos 
\echo '==========================================================================='
\echo '<< INICIANDO PRUEBAS DE LOS TRIGGERS EN LA BASE DE DATOS "FORMULAONE" >>'
\echo 'BLOQUE 4: PRUEBAS DE TRIGGERS'
\echo '==========================================================================='

\echo ''
\echo '// Preparando el entorno de pruebas //'

-- Insertamos una temporada de prueba
\echo ''
\echo 'Insertando temporada de prueba...'
INSERT INTO ddbb.temporadas (anio, url)
VALUES (2099, 'http://test.temporada.2099');
SELECT * FROM ddbb.temporadas WHERE anio = 2099;
\echo ''
\echo 'Temporada de prueba insertada correctamente.'

-- Insertamos un circuito de prueba
\echo ''
\echo 'Insertando circuito de prueba...'
INSERT INTO ddbb.circuitos (circuito_ref, nombre, localizacion, ciudad, latitud, longitud, altura, url)
VALUES ('test_circuito_2099', 'Test Circuito 2099', 'Test Localizacion', 'Test Ciudad', 0.0, 0.0, 0.0, 'http://test.circuito.2099');
SELECT * FROM ddbb.circuitos WHERE circuito_ref = 'test_circuito_2099';
\echo ''
\echo 'Circuito de prueba insertado correctamente.'

-- Insertamos un carrera de prueba
\echo ''
\echo 'Insertando carrera de prueba...'
INSERT INTO ddbb.carreras (anio, circuito_ref, nombre, ronda, fecha_hora, url)
VALUES (2099, 'test_circuito_2099', 'Test Grand Prix 2099', 1, '2099-01-01 12:00:00', 'http://test.gp.2099');
SELECT * FROM ddbb.carreras WHERE anio = 2099 AND nombre = 'Test Grand Prix 2099';
\echo ''
\echo 'Carrera de prueba insertada correctamente.'

-- Insertamos una escuderia de prueba
\echo ''
\echo 'Insertando escuderia de prueba...'
INSERT INTO ddbb.escuderias (escuderia_ref, nombre, nacionalidad, url)
VALUES ('test_escuderia_2099', 'Test Escuderia 2099', 'Test Nacionalidad', 'http://test.escuderia.2099');
SELECT * FROM ddbb.escuderias WHERE escuderia_ref = 'test_escuderia_2099';
\echo ''
\echo 'Escuderia de prueba insertada correctamente.'

-- Insertamos un piloto de prueba
\echo ''
\echo 'Insertando piloto de prueba...'
INSERT INTO ddbb.pilotos (piloto_ref, numero, codigo, nombre, apellido, fecha_nacimiento, nacionalidad, url)
VALUES ('test_piloto_2099', 99, 'TST', 'Test', 'Piloto2099', '2090-01-01', 'Test Nacionalidad', 'http://test.piloto.2099');
SELECT * FROM ddbb.pilotos WHERE piloto_ref = 'test_piloto_2099';
\echo ''
\echo 'Piloto de prueba insertado correctamente.'

\echo ''
\echo '// Entorno de pruebas preparado correctamente //'

\echo ''
\echo '// Iniciando pruebas del trigger de auditoria //'

\echo ''
\echo '--- PRUEBA 1: INSERT (Nuevo resultado) ---'
INSERT INTO ddbb.corre (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, escuderia_ref, posicion, puntos, estado)
VALUES ('test_piloto_2099', 'Test Grand Prix 2099', 2099, 'test_circuito_2099', 'test_escuderia_2099', 1, 25.0, 'Finished');
\echo 'Registro insertado en la tabla "corre".'

\echo ''
\echo '>> Verificando tabla de PUNTOS (Esperado: 25.0 puntos) <<'
SELECT * FROM ddbb.puntos_pilotos 
WHERE piloto_ref = 'test_piloto_2099';

\echo ''
\echo '>> Verificando tabla de AUDITORIA (Esperado: INSERT en tabla "corre") <<'
SELECT * FROM ddbb.auditoria 
WHERE 
    nombre_tabla = 'corre' 
ORDER BY id_aud DESC;

\echo ''
\echo '--- PRUEBA 2: UPDATE (Modificacion de resultado) ---'

-- Modificamos el resultado del piloto de prueba de 25.0 a 18.0 puntos
UPDATE ddbb.corre
SET puntos = 18.0
WHERE piloto_ref = 'test_piloto_2099' AND nombre_carrera = 'Test Grand Prix 2099';
\echo 'Registro actualizado en la tabla "corre".'

\echo '>> Verificando tabla de PUNTOS (Esperado: 18.0 puntos) <<'
SELECT * FROM ddbb.puntos_pilotos 
WHERE piloto_ref = 'test_piloto_2099';

\echo ''
\echo '>> Verificando tabla de AUDITORIA (Esperado: UPDATE en tabla "corre") <<'
SELECT * FROM ddbb.auditoria 
WHERE 
    nombre_tabla = 'corre'
ORDER BY id_aud DESC;

\echo ''
\echo '--- PRUEBA 3: DELETE (Borrado de resultado) ---'
DELETE FROM ddbb.corre
WHERE piloto_ref = 'test_piloto_2099' AND nombre_carrera = 'Test Grand Prix 2099';
\echo 'Registro borrado de la tabla "corre".'

\echo ''
\echo '>> Verificando tabla de PUNTOS (Esperado: 0.0 puntos) <<'
SELECT * FROM ddbb.puntos_pilotos
WHERE piloto_ref = 'test_piloto_2099';

\echo ''
\echo '>> Verificando tabla de AUDITORIA (Esperado: DELETE en tabla "corre") <<'
SELECT * FROM ddbb.auditoria
WHERE 
    nombre_tabla = 'corre'
ORDER BY id_aud DESC;

\echo ''
\echo '// Pruebas del trigger de auditoria finalizadas correctamente //'
\echo ''
\echo '// Deshaciendo los cambios realizados durante las pruebas //'
ROLLBACK;
-- Deshacemos los cambios realizados durante las pruebas haciendo un ROLLBACK
-- Asi, no alteramos los datos reales de la base de datos

\echo ''
\echo '// Cambios deshechos correctamente //'
\echo ''

\echo '==========================================================================='
\echo '<< INICIANDO CREACION DE USUARIOS EN LA BASE DE DATOS "FORMULAONE" >>'
\echo 'BLOQUE 5: CREACION DE USUARIOS'
\echo '==========================================================================='
\echo ''
BEGIN;
\echo '--- Limpiado usuarios anteriores (si los hubiera)... ---'

-- Borramos usuarios si ya existen
DROP USER IF EXISTS administrador;
DROP USER IF EXISTS gestor;
DROP USER IF EXISTS analista;
DROP USER IF EXISTS invitado;

\echo ''
\echo '// Usuarios anteriores eliminados correctamente //'
\echo ''
\echo '--- CREACION DE USUARIOS ---'
\echo ''
\echo 'Creando usuario: administrador...'
CREATE USER administrador WITH PASSWORD 'admin123';

\echo ''
\echo 'Creando usuario: gestor...'
CREATE USER gestor WITH PASSWORD 'gestor123';

\echo ''
\echo 'Creando usuario: analista...'
CREATE USER analista WITH PASSWORD 'analista123';

\echo ''
\echo 'Creando usuario: invitado...'
CREATE USER invitado WITH PASSWORD 'invitado123';

\echo ''
\echo '// Usuarios creados correctamente //'
\echo ''
\echo '--- ASIGNACION DE PERMISOS A USUARIOS ---'

-- Todos los usuarios pueden "usar" el esquema ddbb
GRANT USAGE ON SCHEMA ddbb TO administrador, gestor, analista, invitado;

\echo ''
\echo 'Asignando permisos al usuario: administrador...'
GRANT ALL PRIVILEGES ON SCHEMA ddbb TO administrador;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ddbb TO administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ddbb TO administrador;

\echo ''
\echo 'Asignando permisos al usuario: gestor...'
-- El Gestor puede hacer SELECT, INSERT, UPDADTE y DELETE
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ddbb TO gestor;
-- Ademas necesita permisos sobre las secuencias para los INSERTs
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA ddbb TO gestor;
-- No le damos permisos de CREATE TABLE para que no pueda crear nuevas tablas

\echo ''
\echo 'Asignando permisos al usuario: analista...'
-- El Analista solo puede hacer SELECT
GRANT SELECT ON ALL TABLES IN SCHEMA ddbb TO analista;
-- No necesita permisos sobre las secuencias ya que no hace INSERTs

\echo ''
\echo 'Asignando permisos al usuario: invitado...'
-- El Invitado solo puede hacer SELECT sobre algunas tablas
-- Puede ver resultados (corre), pilotos, carreras, escuderias, circuitos, temporadas, estado y califica
GRANT SELECT ON 
    ddbb.pilotos,
    ddbb.escuderias,
    ddbb.circuitos,
    ddbb.temporadas,
    ddbb.carreras,
    ddbb.corre,
    ddbb.status,
    ddbb.califica
TO invitado;
-- No necesita permisos sobre las secuencias ya que no hace INSERTs
-- No puede ver vueltas, boxes, auditoria ni puntos_pilotos
-- No le damos permiso asi que por defecto no tiene acceso a esas tablas

\echo ''
\echo '// Permisos asignados correctamente //'
COMMIT;
-- Punto de control tras la creacion de los usuarios
-- Los usuarios ya estan creados permanentemente
-- Si el script falla mas adelante, los usuarios seguirane existiendo

\echo ''
\echo '// Finalizada la creacion de usuarios en la base de datos "FORMULAONE" //'
\echo ''
\echo '=================================================================='
\echo '<< INICIANDO PRUEBAS DE PERMISOS EN LA BASE DE DATOS "FORMULAONE" >>'
\echo 'BLOQUE 6: PRUEBAS DE PERMISOS'
\echo '=================================================================='
\echo ''
-- No hacemos un BEGIN aqui porque cada bloque de pruebas individualmente hace su propio BEGIN/ROLLBACK

\echo '--- INICIANDO PRUEBAS DE PERMISOS ---'
\echo ''
\echo '// Prueba de permisos para el usuario: administrador //'
\echo '[TEST ADMINISTRADOR]'
\echo 'Conectando como usuario: administrador...'
-- BEGIN para el bloque de pruebas del administrador
BEGIN; 
SET ROLE administrador;

\echo ''
\echo 'Probando SELECT en la tabla "pilotos"...'
SELECT * FROM ddbb.pilotos LIMIT 1;

\echo ''
\echo 'Probando INSERT en la tabla "pilotos"...'
INSERT INTO ddbb.pilotos (piloto_ref, numero, codigo, nombre, apellido, fecha_nacimiento, nacionalidad, url)
VALUES ('test_admin_001', 1, 'TST', 'Test', 'Admin001', '1990-01-01', 'Test Nacionalidad', 'http://test.admin.001');

\echo ''
\echo 'Probando UPDATE en la tabla "pilotos"...'
UPDATE ddbb.pilotos
SET nombre = 'TestUpdated'
WHERE piloto_ref = 'test_admin_001';

\echo ''
\echo 'Probando DELETE en la tabla "pilotos"...'
DELETE FROM ddbb.pilotos
WHERE piloto_ref = 'test_admin_001';

\echo ''
\echo 'Pruebas de administrador finalizadas correctamente.'
\echo ''
ROLLBACK;
-- Deshacemos los cambios realizados durante las pruebas del administrador

\echo '// Prueba de permisos para el usuario: gestor //'
\echo '[TEST GESTOR]'
\echo 'Conectando como usuario: gestor...'
-- BEGIN para el bloque de pruebas del gestor
BEGIN;
SET ROLE gestor;

\echo ''
\echo 'Probando SELECT en la tabla "escuderias"...'
SELECT * FROM ddbb.escuderias LIMIT 1;

\echo ''
\echo 'Probando INSERT en la tabla "escuderias"...'
INSERT INTO ddbb.escuderias (escuderia_ref, nombre, nacionalidad, url)
VALUES ('test_gestor_001', 'Test Gestor 001', 'Test Nacionalidad', 'http://test.gestor.001');

\echo ''
\echo 'Probando UPDATE en la tabla "escuderias"...'
UPDATE ddbb.escuderias 
SET nombre = 'TestGestorUpdated'
WHERE escuderia_ref = 'test_gestor_001';

\echo ''
\echo 'Probando DELETE en la tabla "escuderias"...'
DELETE FROM ddbb.escuderias
WHERE escuderia_ref = 'test_gestor_001';

\echo ''
\echo 'Pruebas de gestor finalizadas correctamente.'
\echo ''
ROLLBACK;
-- Deshacemos los cambios realizados durante las pruebas del gestor

-- A continuación se ejecutan pruebas donde se esperan errores de permisos intencionadamente
-- Para asegurar que el script siga funcionando, estos errores se ejecutan dentro de sus propias transacciones
\echo '// Prueba de permisos para el usuario: analista //'
\echo '[TEST ANALISTA]'
\echo 'Conectando como usuario: analista...'
SET ROLE analista;

\echo ''
\echo 'Probando SELECT en la tabla "circuitos"...'
-- El SELECT no deberia fallar, asi que lo hacemos dentro de un BEGIN/ROLLBACK para mantener la estructura
BEGIN;
SELECT * FROM ddbb.circuitos LIMIT 1;
ROLLBACK;
-- Fin del bloque de SELECT

\echo ''
\echo 'Probando INSERT en la tabla "circuitos"...'
-- El INSERT deberia fallar por falta de permisos
BEGIN;
INSERT INTO ddbb.circuitos (circuito_ref, nombre, localizacion, ciudad, latitud, longitud, altura, url)
VALUES ('test_analista_001', 'Test Analista 001', 'Test Localizacion', 'Test Ciudad', 0.0, 0.0, 0.0, 'http://test.analista.001');
\echo '>> ERROR ESPERADO: Permiso denegado para INSERT <<'
ROLLBACK;
-- Fin del bloque de INSERT

\echo ''
\echo 'Probando UPDATE en la tabla "circuitos"...'
-- El UPDATE deberia fallar por falta de permisos
BEGIN;
UPDATE ddbb.circuitos
SET nombre = 'TestAnalistaUpdated'
WHERE circuito_ref = 'test_analista_001';
\echo '>> ERROR ESPERADO: Permiso denegado para UPDATE <<'
ROLLBACK;
-- Fin del bloque de UPDATE

\echo ''
\echo 'Probando DELETE en la tabla "circuitos"...'
-- El DELETE deberia fallar por falta de permisos
BEGIN;
DELETE FROM ddbb.circuitos
WHERE circuito_ref = 'test_analista_001';
\echo '>> ERROR ESPERADO: Permiso denegado para DELETE <<'
ROLLBACK;
-- Fin del bloque de DELETE

-- Finalizamos las pruebas del analista RESETEANDO el ROLE para regresar al usuario original
RESET ROLE;

\echo ''
\echo 'Pruebas de analista finalizadas correctamente.'
\echo ''

\echo '// Prueba de permisos para el usuario: invitado //'
\echo '[TEST INVITADO]'
\echo 'Conectando como usuario: invitado...'
SET ROLE invitado;

\echo ''
\echo 'Probando SELECT en la tabla "pilotos"...'
BEGIN;
SELECT * FROM ddbb.pilotos LIMIT 1;
ROLLBACK;

\echo ''
\echo 'Probando INSERT en la tabla "pilotos"...'
BEGIN;
INSERT INTO ddbb.pilotos (piloto_ref, numero, codigo, nombre, apellido, fecha_nacimiento, nacionalidad, url)
VALUES ('test_invitado_001', 1, 'TST', 'Test', 'Invitado001', '1990-01-01', 'Test Nacionalidad', 'http://test.invitado.001');
\echo '>> ERROR ESPERADO: Permiso denegado para INSERT <<'
ROLLBACK;

\echo ''
\echo 'Probando UPDATE en la tabla "pilotos"...'
BEGIN;
UPDATE ddbb.pilotos
SET nombre = 'TestInvitadoUpdated'
WHERE piloto_ref = 'test_invitado_001';
\echo '>> ERROR ESPERADO: Permiso denegado para UPDATE <<'
ROLLBACK;

\echo ''
\echo 'Probando DELETE en la tabla "pilotos"...'
BEGIN;
DELETE FROM ddbb.pilotos
WHERE piloto_ref = 'test_invitado_001';
\echo '>> ERROR ESPERADO: Permiso denegado para DELETE <<'
ROLLBACK;

-- Finalizamos las pruebas del invitado RESETEANDO el ROLE para regresar al usuario original
RESET ROLE;

\echo ''
\echo 'Pruebas de invitado finalizadas correctamente.'
\echo ''
\echo '// Pruebas de permisos finalizadas correctamente //'
\echo ''
\echo '============================================================================'
\echo 'FIN DEL SCRIPT DE CONFIGURACION DE LA BASE DE DATOS "FORMULAONE"'
\echo '============================================================================'
\echo ';)'