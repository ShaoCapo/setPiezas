USE Practica2;

-- borra filas
/*
DELETE FROM contiene;
DELETE FROM color;
DELETE FROM pieza;
DELETE FROM categoria;
DELETE FROM `set`;
DELETE FROM tematica;*/

-- borra filas y tabla

DROP TABLE IF EXISTS contiene;
DROP TABLE IF EXISTS color;
DROP TABLE IF EXISTS pieza;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS `set`;
DROP TABLE IF EXISTS tematica;
DROP TABLE IF EXISTS bajas;

-- borra filas y tablas, y las vuelve a crear
/*
TRUNCATE TABLE contiene;
TRUNCATE TABLE color;
TRUNCATE TABLE pieza;
TRUNCATE TABLE categoria;
TRUNCATE TABLE `set`;
TRUNCATE TABLE tematica;*/


CREATE TABLE categoria
	(ID					INTEGER			NOT NULL,
	 NOMBRE				VARCHAR(50) 	NOT NULL,
	 PRIMARY KEY (ID));


CREATE TABLE color
	(ID					INTEGER			NOT NULL,
	 NOMBRE 			VARCHAR(25)		NOT NULL,
	 RGB				VARCHAR(6), -- UNIQUE
	 ES_TRANSPARENTE	VARCHAR(1)
						CHECK (ES_TRANSPARENTE IN ( 'f', 't' )),
	 PRIMARY KEY (ID));

CREATE TABLE pieza
	(NUM_PIEZA			INTEGER			NOT NULL,
	 NOMBRE				VARCHAR(150),
	 CATEGORIA			INTEGER,
	 PRIMARY KEY (NUM_PIEZA),
     FOREIGN KEY (CATEGORIA)
		REFERENCES categoria (ID));
        
 
CREATE TABLE tematica
	(ID					INTEGER			NOT NULL,
	 NOMBRE				VARCHAR(25),
	 PRIMARY KEY (ID));
 

CREATE TABLE `set`
	(NUM_SET			INTEGER 		NOT NULL,
	 NOMBRE				VARCHAR(65),
	 AÑO				CHAR(4),
	 TEMATICA			INTEGER,
	 PRIMARY KEY (NUM_SET),
     FOREIGN KEY (TEMATICA)
		REFERENCES tematica (ID));
        

CREATE TABLE contiene
	(NUM_PIEZA			INTEGER			NOT NULL,
	 NUM_SET			INTEGER			NOT NULL,
	 COLOR				INTEGER			NOT NULL,
	 CANTIDAD			INTEGER			NOT NULL,
	 PRIMARY KEY (NUM_PIEZA, NUM_SET, COLOR),
     FOREIGN KEY (NUM_PIEZA)
		REFERENCES pieza (NUM_PIEZA), 
	 FOREIGN KEY (NUM_SET)
		REFERENCES `set` (NUM_SET),
	 FOREIGN KEY (COLOR)
		REFERENCES color (ID));