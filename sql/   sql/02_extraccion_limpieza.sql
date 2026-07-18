-- Parte 2: Extraer y limpiar datos
-- --------------------------------------------------------
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    COALESCE(p.precio_producto, 0)  AS precio_producto,
    COALESCE(v.cantidad_pedido, 0)  AS cantidad_pedido,
    COALESCE(p.costo_producto, 0)   AS costo_producto,
    t.pais,
    t.continente,
    v.clave_territorio,
-- Calcula  ingreso_total y costo_total
(COALESCE(v.cantidad_pedido, 0) * COALESCE(p.precio_producto, 0)) AS ingreso_total,
(COALESCE(v.cantidad_pedido, 0) * COALESCE(p.costo_producto, 0)) AS costo_total
FROM ventas_2017 AS v
JOIN productos AS p
  ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc
  ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t
  ON v.clave_territorio = t.clave_territorio;
