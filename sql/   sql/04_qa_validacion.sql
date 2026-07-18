-- Parte 4: Validar resultados y QA
-- --------------------------------------------------------
-- =====================================================
-- Paso 4: Validación de resultados y QA
-- Objetivo: comprobar totales, consistencia, anomalías
-- y calidad de las claves antes de reportar cifras finales.
--
-- ⚠️ NOTA: a partir del check 1 (precios negativos), el resto
-- es un borrador reconstruido siguiendo la guía del proyecto.
-- Verificar y ejecutar en el entorno SQL original antes de
-- considerarlos definitivos.
-- =====================================================

-- --------------------------------------------------------
-- Check 1: Precios de producto no válidos (negativos)
-- --------------------------------------------------------
SELECT
    COUNT(*) AS productos_precio_no_valido
FROM productos
WHERE precio_producto < 0;

-- --------------------------------------------------------
-- Check 2: Cantidades de pedido no válidas (negativas)
-- --------------------------------------------------------
SELECT
    COUNT(*) AS pedidos_cantidad_no_valida
FROM ventas_2017
WHERE cantidad_pedido < 0;

-- --------------------------------------------------------
-- Check 3: Validación de totales — ventas_clean vs. recálculo
-- directo desde las tablas base
-- --------------------------------------------------------
SELECT
    (SELECT SUM(ingreso_total) FROM ventas_clean) AS ingreso_total_vista,
    (SELECT SUM(v.cantidad_pedido * p.precio_producto)
     FROM ventas_2017 AS v
     JOIN productos AS p ON v.clave_producto = p.clave_producto) AS ingreso_total_recalculado;

-- --------------------------------------------------------
-- Check 4: Consistencia — la suma de los agregados por país
-- debe coincidir con el total general
-- --------------------------------------------------------
SELECT
    (SELECT SUM(ingresos) FROM pais_ingreso_costo) AS suma_por_pais,
    (SELECT SUM(ingreso_total) FROM ventas_clean) AS total_general;

-- --------------------------------------------------------
-- Check 5: Anomalías — productos/países con margen negativo
-- --------------------------------------------------------
SELECT
    pais,
    clave_territorio,
    ((SUM(ingresos) - SUM(costos)) * 100.0) / NULLIF(SUM(ingresos), 0) AS margen_pct
FROM pais_ingreso_costo
GROUP BY pais, clave_territorio
HAVING ((SUM(ingresos) - SUM(costos)) * 100.0) / NULLIF(SUM(ingresos), 0) < 0;

-- --------------------------------------------------------
-- Check 6: Nulos en claves críticas y duplicados de pedido
-- --------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE clave_producto IS NULL)    AS nulos_clave_producto,
    COUNT(*) FILTER (WHERE clave_territorio IS NULL)  AS nulos_clave_territorio
FROM ventas_2017;

SELECT
    numero_pedido,
    COUNT(*) AS repeticiones
FROM ventas_2017
GROUP BY numero_pedido
HAVING COUNT(*) > 1;
