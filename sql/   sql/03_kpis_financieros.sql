-- Parte 3: Calcular KPIs financieros
-- --------------------------------------------------------

SELECT
    p.pais,
    p.clave_territorio,
    SUM(p.ingresos)::integer AS ingresos,
    SUM(p.costos)::integer AS costos,
    COALESCE(SUM(c.costo_campana), 0)::integer AS costo_campana,
-- 1. Beneficio Bruto: Conversión individual de sumas
    SUM(p.ingresos)::integer - SUM(p.costos)::integer AS beneficio_bruto,

    -- 2. Margen %: Uso de 100.0 para forzar precisión decimal (Float)
    ((SUM(p.ingresos) - SUM(p.costos))*100.0) / NULLIF(SUM(p.ingresos), 0) AS margen_pct,

    -- 3. ROI %: Simplificación del denominador y precisión decimal
    ((SUM(p.ingresos) - SUM(p.costos))*100.0) / NULLIF(SUM(c.costo_campana), 0) AS roi_pct

   
FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c
  ON p.clave_territorio = c.clave_territorio
GROUP BY
    p.pais,
    p.clave_territorio
ORDER BY
    p.clave_territorio, ingresos, costos;
