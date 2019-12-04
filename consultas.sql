-- 1. Obtener el número de piezas total para cada categoría.
SELECT COUNT(num_pieza) AS 'Número Piezas Total', CATEGORIA
FROM pieza
GROUP BY CATEGORIA;

-- 2. Obtener todos los set posteriores al año 2000 que no pertenezcan a ninguna temática.
SELECT NOMBRE
FROM `set`
WHERE AÑO > 2000 AND TEMATICA IS NULL;

-- 3. Obtener para cada set, su nombre y la cantidad total de piezas de las que dispone, ordenadas en función del número total de piezas.
SELECT s.NOMBRE, COUNT(cn.NUM_PIEZA) AS 'Número de piezas'
FROM `set` s INNER JOIN contiene cn ON cn.NUM_SET = s.NUM_SET
WHERE EXISTS (SELECT COUNT(NUM_PIEZA)
					FROM contiene
                    GROUP BY NUM_SET)
GROUP BY cn.NUM_SET
ORDER BY COUNT(cn.NUM_PIEZA);

-- 4. Obtener el nombre de los colores que no disponen de piezas contenidas en ningún set.
SELECT cl.NOMBRE
FROM color cl
WHERE ID NOT IN(SELECT COLOR
				FROM contiene);

-- 5. Obtener el nombre de los colores que no figuran en ninguna pieza contenidas en los set del año 2017, pero sí figuran en algún set del año 2016.
SELECT cl.NOMBRE
FROM color cl INNER JOIN contiene cn 	ON cl.ID = cn.COLOR
			  INNER JOIN pieza p 		ON cn.NUM_PIEZA = p.NUM_PIEZA
WHERE cn.NUM_SET NOT IN (SELECT NUM_SET
						 FROM `set`
                         WHERE AÑO = 2017)
	AND cn.NUM_SET IN (SELECT NUM_SET
					   FROM `set`
                       WHERE AÑO = 2016);

-- 6. Obtener el nombre y el año de los sets cuya temática empiece por la letra ‘r’ ordenados alfabéticamente.
SELECT s.NOMBRE, s.AÑO
FROM `set`s INNER JOIN tematica t ON t.ID = s.TEMATICA
WHERE t.NOMBRE LIKE 'R%'
ORDER BY s.NOMBRE;

-- 7. Obtener todas las categorías de las piezas que tengan algún set que esté comprendido entre los años 2001 y 2003 y que además no tenga ninguna pieza roja.
SELECT DISTINCT c.*
FROM categoria c INNER JOIN pieza p 	ON p.CATEGORIA = c.ID 
				 INNER JOIN contiene cn ON cn.NUM_PIEZA = p.NUM_PIEZA
                 INNER JOIN `set` s 	ON s.NUM_SET = cn.NUM_SET
                 INNER JOIN color cl 	ON cl.ID = cn.COLOR
WHERE s.AÑO BETWEEN 2001 AND 2003
	AND cl.ID <> 'Rojo';

-- 8. Listar los colores de los sets que tengan más de 4 piezas cuya temática sea The hobbit o Jurassic World.
SELECT DISTINCT cl.NOMBRE
FROM `set` s INNER JOIN tematica t 	ON t.ID = s.TEMATICA
			 INNER JOIN contiene cn	ON cn.NUM_SET = s.NUM_SET
             INNER JOIN color cl 	ON cl.ID = cn.COLOR
WHERE cn.NUM_SET IN (SELECT NUM_SET
					 FROM contiene
                     WHERE t.NOMBRE = 'Jurassic World' 
						OR t.NOMBRE = 'The Hobbit'
                     GROUP BY NUM_SET
                     HAVING COUNT(NUM_PIEZA) > 4);

-- 9. Obtener todas las temáticas de los sets que contengan todas las piezas transparentes.
SELECT s.TEMATICA
FROM `set` s 	INNER JOIN contiene cn	ON s.NUM_SET = cn.NUM_SET
                INNER JOIN color cl 	ON cn.COLOR = cl.ID
WHERE cl.ES_TRANSPARENTE = 't'
GROUP BY s.TEMATICA
HAVING COUNT(DISTINCT cn.NUM_PIEZA) = (SELECT COUNT(*)
									   FROM color
									   WHERE ES_TRANSPARENTE = 't');

-- 10. Obtener el nombre del set que contiene un mayor número de piezas diferentes y el número total de dichas piezas.
SELECT s.NOMBRE, COUNT(DISTINCT cn.NUM_PIEZA) AS 'Número Total de Piezas'
FROM `set` s INNER JOIN contiene cn ON s.NUM_SET = cn.NUM_SET
GROUP BY s.NUM_SET
HAVING COUNT(DISTINCT cn.NUM_PIEZA) >= ALL (SELECT COUNT(DISTINCT NUM_PIEZA)
											FROM contiene
                                            GROUP BY NUM_SET);

-- 11. Obtener el nombre de las piezas que figuran en todos los sets con cualquier gama de color verde y transparente.
SELECT p.NOMBRE
FROM pieza p INNER JOIN contiene cn ON cn.NUM_PIEZA = p.NUM_PIEZA
			  INNER JOIN `set`s 	ON s.NUM_SET = cn.NUM_SET
              INNER JOIN color cl 	ON cl.ID = cn.COLOR
WHERE cl.NOMBRE LIKE '%Green%' 
  AND cl.ES_TRANSPARENTE = 't';

-- 12. Obtener el nombre de las piezas que se han utilizado con 2 o más colores diferentes, mostrando además dicho número.
SELECT p.NOMBRE, COUNT(cn.COLOR) AS 'Número de Colores'
FROM pieza p INNER JOIN contiene cn ON cn.NUM_PIEZA = p.NUM_PIEZA
WHERE cn.NUM_PIEZA IN (SELECT NUM_PIEZA
					   FROM contiene
                       GROUP BY NUM_PIEZA
                       HAVING COUNT(DISTINCT COLOR) > 1)
GROUP BY p.NOMBRE;

-- 13. Obtener los nombres de las categorías de las piezas que pertenezcan a los sets del año más reciente.
SELECT DISTINCT c.NOMBRE
FROM categoria c INNER JOIN pieza p 	ON c.ID = p.CATEGORIA
				 INNER JOIN contiene cn ON p.NUM_PIEZA = cn.NUM_PIEZA
				 INNER JOIN `set` s 	ON cn.NUM_SET = s.NUM_SET
WHERE s.AÑO >= ALL (SELECT AÑO
					FROM `set`);

-- 14. Obtener el nombre de aquellos sets que tengan la misma pieza repetida, 
-- así como la cantidad de colores distintos de dichas piezas.
SELECT s.NOMBRE, COUNT(DISTINCT COLOR) AS 'Colores distintos de las piezas'
FROM contiene cn INNER JOIN `set` s ON s.NUM_SET = cn.NUM_SET
GROUP BY cn.NUM_SET, cn.NUM_PIEZA
HAVING COUNT(cn.NUM_PIEZA) > 1;

-- 15. Indicar los códigos RGB del color, las categorías y la temática de los sets con el mayor y el menor número de piezas respectivamente.
SELECT cl.RGB, p.CATEGORIA, s.TEMATICA
FROM color cl INNER JOIN contiene cn 	ON cn.COLOR = cl.ID
			  INNER JOIN pieza p 		ON p.NUM_PIEZA = cn.NUM_PIEZA
              INNER JOIN `set` s 		ON s.NUM_SET = cn.NUM_SET
WHERE p.NUM_PIEZA = (SELECT MAX(NUM_PIEZA)
					 FROM pieza)
	OR
    p.NUM_PIEZA = (SELECT MIN(NUM_PIEZA)
				   FROM pieza);
