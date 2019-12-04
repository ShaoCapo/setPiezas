USE Practica2;

DROP PROCEDURE IF EXISTS SetsPorTematicaAnio;
DROP PROCEDURE IF EXISTS NumPiezasEnSet;
DROP FUNCTION IF EXISTS transformarT_F;
DROP TRIGGER IF EXISTS hayMasDe4;
DROP TRIGGER IF EXISTS piezaHistoria;

-- PROCEDIMIENTOS
-- 1. Procedimiento almacenado de nombre SetsPorTematicaAnio, que obtenga como salida los nombres de los set existentes
--    y el número total de piezas que contienen, para una temática y año concretos que se pasarán como parámetros de entrada.
--    En el procedimiento no se definirán parámetros de salida.
DELIMITER $$
CREATE PROCEDURE SetsPorTematicaAnio (IN tematica VARCHAR(15), año INTEGER)
BEGIN
	SELECT s.NOMBRE, COUNT(cn.NUM_PIEZA) AS 'Número total de piezas'
    FROM contiene cn INNER JOIN `set` s ON cn.NUM_SET = s.NUM_SET
					 INNER JOIN tematica t ON t.ID = s.TEMATICA
    WHERE t.NOMBRE = tematica AND s.AÑO = año
    GROUP BY s.NOMBRE;
END$$
DELIMITER ;

CALL SetsPorTematicaAnio ('Jurassic World', 2003);

-- 2. Procedimiento almacenado de nombre NumPiezasEnSet, que devuelva el número total de piezas que contiene un set concreto
--    y el número de colores diferentes de éstas. El procedimiento tendrá como parámetro de entrada el nombre de un set concreto.
DELIMITER $$
CREATE PROCEDURE NumPiezasEnSet (IN Nombre_set VARCHAR(100))
BEGIN
  SELECT COUNT(cn.NUM_PIEZA) AS 'Número de piezas total', COUNT(DISTINCT cn.COLOR) AS 'Número de colores diferentes'
  FROM contiene cn INNER JOIN `set` s 	ON s.NUM_SET = cn.NUM_SET
				   INNER JOIN color cl	ON cl.ID = cn.COLOR
  WHERE s.NOMBRE = Nombre_set 
  GROUP BY s.NOMBRE;
END$$
DELIMITER ;

CALL NumPiezasEnSet ('Darth Maul');

-- 3. Definir una función que convierta un valor 't' o 'f' pasado como argumento y devuelva el valor booleano correspondiente
DELIMITER $$
CREATE FUNCTION transformarT_F_BOOLEAN (ES_TRANSPARENTE VARCHAR(5))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
	DECLARE tF BOOLEAN;
    CASE ES_TRANSPARENTE
		WHEN 't' THEN SET tF = TRUE;
        WHEN 'f' THEN SET tF = FALSE;
        ELSE SET tF = NULL;
	END CASE;
    RETURN(tF);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION transformarT_F_VARCHAR (ES_TRANSPARENTE VARCHAR(5))
RETURNS VARCHAR(15)
DETERMINISTIC
BEGIN
	DECLARE tF VARCHAR(15);
    CASE ES_TRANSPARENTE
		WHEN 't' THEN SET tF = 'TRUE';
        WHEN 'f' THEN SET tF = 'FALSE';
        ELSE SET tF = 'Valor erróneo';    
	END CASE;
    RETURN(tF);
END$$
DELIMITER ;

-- BOOLEAN
SELECT TRANSFORMART_F_BOOLEAN ('t'); -- 1
SELECT transformarT_F_BOOLEAN ('f'); -- 3
SELECT transformarT_F_BOOLEAN ('1'); -- 2
SELECT transformarT_F_BOOLEAN (NULL); -- 4
-- VARCHAR
SELECT transformarT_F_VARCHAR ('t');
SELECT transformarT_F_VARCHAR ('f');
SELECT transformarT_F_VARCHAR ('1');
SELECT transformarT_F_VARCHAR (NULL);

-- TRIGGERS
-- 1. A partir de este momento la empresa no va a permitir que haya set con más de 4 piezas, se debe desarrollar un trigger
--    que impida que éstos se puedan incorporar a la base de datos. Para ello, se debe impedir la operación de alta de
--    pertenencia de una pieza a un set cuando, en el caso de insertar una en la base de datos, se detecte que en el set ya hay cuatro piezas.
DELIMITER $$
CREATE TRIGGER hayMasDe4 
	BEFORE INSERT ON contiene
FOR EACH ROW
BEGIN
	DECLARE masDe4 INTEGER;
	SELECT COUNT(DISTINCT NUM_PIEZA) INTO masDe4
    FROM contiene
    WHERE NUM_SET = new.`num_set`;
    
    IF (masDe4 > 4) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El set ya tiene más de 4 piezas';
	END IF;
END$$
DELIMITER ;

-- NO PERMITIDO
SET AUTOCOMMIT = 0;
BEGIN WORK;
	INSERT INTO pieza (`num_pieza`,`nombre`,`categoria`) VALUES (191,'Anatian',16);
	INSERT INTO contiene (`num_pieza`,`num_set`,`color`,`cantidad`) VALUES (191,65,13,65);
SELECT *
FROM contiene;
	ROLLBACK;

-- PERMITIDO
SET AUTOCOMMIT = 0;
BEGIN WORK;
	INSERT INTO pieza (`num_pieza`,`nombre`,`categoria`) VALUES (191,'Anatian',16);
	INSERT INTO contiene (`num_pieza`,`num_set`,`color`,`cantidad`) VALUES (191,1,13,65);
SELECT *
FROM contiene;
	ROLLBACK;

-- 2. Con la base de datos ya en marcha, la empresa ha decidido que necesita un cambio en el diseño y solicita que se cree una
--    tabla nueva ya que pide que, si se da una pieza de baja se almacene de manera histórica la siguiente información:
--    código de pieza, número de colores diferentes de los que dispone y número de sets en los que participa. Se solicita:
	-- a. Crear una tabla que se denomine “bajas” cuya estructura permita almacenar el número de pieza, el número de colores
    --    disponibles y el número de sets en los que participa una pieza. En esta tabla solamente estarán aquellas piezas que
    --    se den de baja en la base de datos.
    
    CREATE TABLE bajas
	(NUM_PIEZA		INTEGER NOT NULL,
	NUM_SET			INTEGER NOT NULL,
	NUM_COLORES		INTEGER,
	PRIMARY KEY (NUM_PIEZA, NUM_SET));
    
	-- b. Crear un trigger que, al intentar eliminar una pieza de la tabla: a) almacene la información de la pieza que se quiere
    --    almacenar en la tabla “bajas” b) si la opción de restricción de integridad referencial respecto de la tabla “contiene”
    --    es “NO ACTION”, elimine todas las tuplas de la tabla “contiene” correspondientes a la pieza que se quiere eliminar
	--    (básicamente, que implemente la opción “DELETE CASCADE”, y c) permita la eliminación de la pieza en la tabla piezas.
DROP TRIGGER IF EXISTS piezaHistoria;

	DELIMITER $$
	CREATE TRIGGER piezaHistoria
		AFTER DELETE ON contiene
	FOR EACH ROW
	BEGIN
		DECLARE num_color INTEGER;
		SELECT COUNT(DISTINCT color) INTO num_color
        FROM contiene
        WHERE NUM_PIEZA = old.`num_pieza` AND
			  NUM_SET = old.`num_set`
        GROUP BY NUM_PIEZA;
        
		INSERT INTO bajas (`num_pieza`, `num_set`, `num_colores`)
			VALUES (old.`num_pieza`, old.`num_set`, num_color);
	END$$
	DELIMITER ;
    
    SET AUTOCOMMIT = 0;
	BEGIN WORK;
        DELETE FROM contiene 
		   WHERE NUM_PIEZA = 188;
		DELETE FROM pieza 
		   WHERE NUM_PIEZA = 188;
	SELECT *
    FROM bajas;
    SELECT *
    FROM pieza;
	ROLLBACK;
