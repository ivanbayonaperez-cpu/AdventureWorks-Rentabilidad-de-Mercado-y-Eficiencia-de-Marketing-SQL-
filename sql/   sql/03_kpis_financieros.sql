-- =====================================================
-- Paso 3: KPIs financieros
-- Objetivo: calcular ingresos, costos, beneficio bruto,
-- margen % y ROI % por país/territorio.
--
-- ⚠️ NOTA: las vistas "pais_ingreso_costo" y "pais_campanas"
-- son un borrador reconstruido a partir de la lógica descrita
-- en el enunciado del proyecto. Verificar contra el entorno
-- SQL original antes de considerarlas definitivas.
-- =====================================================

-- --------------------------------------------------------
-- Sub-paso 3.1: Ingresos y costos por país/territorio
-- --------------------------------------------------------
CREATE VIEW pais_ingreso_costo AS
SELECT
    pais,
    clave_territorio,
    SUM(ingreso_total) AS ingresos,
    SUM(costo_total)   AS costos
FROM ventas_clean
GROUP BY pais, clave_territorio
ORDER BY ingresos DESC;

-- --------------------------------------------------------
-- Sub-paso 3.2: Gasto en campañas de marketing por territorio
-- --------------------------------------------------------
CREATE VIEW pais_campanas AS
SELECT
    clave_territorio,
    SUM(COALESCE(costo_campana, 0)) AS costo_campana
FROM campanas
GROUP BY clave_territorio;

-- --------------------------------------------------------
-- Sub-paso 3.3: Beneficio Bruto, Margen % y ROI % (query final)
-- --------------------------------------------------------
SELECT
    p.pais,
    p.clave_territorio,
    SUM(p.ingresos)::integer AS ingresos,
    SUM(p.costos)::integer AS costos,
    COALESCE(SUM(c.costo_campana), 0)::integer AS costo_campana,

    -- 1. Beneficio Bruto: conversión individual de sumas
    SUM(p.ingresos)::integer - SUM(p.costos)::integer AS beneficio_bruto,

    -- 2. Margen %: 100.0 fuerza precisión decimal (float)
    ((SUM(p.ingresos) - SUM(p.costos)) * 100.0) / NULLIF(SUM(p.ingresos), 0) AS margen_pct,

    -- 3. ROI %: retorno sobre el gasto en campañas
    ((SUM(p.ingresos) - SUM(p.costos)) * 100.0) / NULLIF(SUM(c.costo_campana), 0) AS roi_pct

FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c
  ON p.clave_territorio = c.clave_territorio
GROUP BY
    p.pais,
    p.clave_territorio
ORDER BY
    p.clave_territorio, ingresos, costos;
