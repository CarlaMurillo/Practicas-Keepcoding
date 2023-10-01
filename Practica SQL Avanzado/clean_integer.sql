CREATE OR REPLACE FUNCTION keepcoding.fnc_limpieza_enteros(valor INTEGER) RETURNS INTEGER
AS (IFNULL(valor,-999999));