-- =====================================================
-- Paso 1: Exploración del esquema
-- Objetivo: entender la estructura de las tablas disponibles
-- e identificar las claves de unión entre ellas.
-- =====================================================

-- Vista rápida de cada tabla (repetir para las 5 tablas)
SELECT *
FROM campanas
LIMIT 10;

-- Repetir el mismo patrón para: ventas_2017, productos, productos_categorias, territorios

-- Claves de unión identificadas:
--   ventas_2017.clave_producto     -> productos.clave_producto
--   productos.clave_subcategoria   -> productos_categorias.clave_subcategoria
--   ventas_2017.clave_territorio   -> territorios.clave_territorio
--   campanas.clave_territorio      -> territorios.clave_territorio
