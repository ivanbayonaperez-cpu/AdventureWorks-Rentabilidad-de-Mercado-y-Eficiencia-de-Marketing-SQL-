# 💹 AdventureWorks: Rentabilidad de Mercado y Eficiencia de Marketing (SQL)

Análisis financiero con SQL sobre 6 mercados de AdventureWorks (2017) para responder a la Dirección Financiera dónde invertir el próximo dólar de marketing — separando el desempeño del producto (margen) del desempeño de la inversión publicitaria (ROI).

## 🎯 Contexto de negocio

El director financiero necesitaba decidir prioridades de presupuesto de marketing entre 6 países. Las preguntas centrales: ¿cuánto se gana por país?, y ¿qué tan rentable es cada mercado considerando lo que se invierte en campañas?

## 🧱 Esquema de datos

Se integraron 5 tablas relacionales: `ventas_2017` (transacciones), `productos` (catálogo, costo/precio), `productos_categorias` (jerarquía), `territorios` (país/continente) y `campanas` (gasto de marketing por territorio).

## 🧮 Metodología SQL

Consultas disponibles en [`/sql`](./sql) — cada archivo corresponde a una etapa del análisis.

**1. Exploración del esquema** ([`01_exploracion.sql`]([01_exploracion.sql](https://github.com/ivanbayonaperez-cpu/AdventureWorks-Rentabilidad-de-Mercado-y-Eficiencia-de-Marketing-SQL-/blob/main/sql/%20%20%20sql/01_exploracion.sql))) — identificación de claves de unión entre las 5 tablas.

**2. Extracción y limpieza** ([`02_extraccion_limpieza.sql`]([./sql/02_extraccion_limpieza.sql](https://github.com/ivanbayonaperez-cpu/AdventureWorks-Rentabilidad-de-Mercado-y-Eficiencia-de-Marketing-SQL-/blob/main/sql/%20%20%20sql/02_extraccion_limpieza.sql))) — construcción de la tabla base combinando ventas, productos y territorios, con manejo de nulos vía `COALESCE` y cálculo de ingreso/costo total por línea de pedido.

**3. KPIs financieros** ([`03_kpis_financieros.sql`]([./sql/03_kpis_financieros.sql](https://github.com/ivanbayonaperez-cpu/AdventureWorks-Rentabilidad-de-Mercado-y-Eficiencia-de-Marketing-SQL-/blob/main/sql/%20%20%20sql/03_kpis_financieros.sql))) — el query central del proyecto:

```sql
SELECT
    p.pais,
    p.clave_territorio,
    SUM(p.ingresos)::integer AS ingresos,
    SUM(p.costos)::integer AS costos,
    COALESCE(SUM(c.costo_campana), 0)::integer AS costo_campana,
    SUM(p.ingresos)::integer - SUM(p.costos)::integer AS beneficio_bruto,
    ((SUM(p.ingresos) - SUM(p.costos)) * 100.0) / NULLIF(SUM(p.ingresos), 0) AS margen_pct,
    ((SUM(p.ingresos) - SUM(p.costos)) * 100.0) / NULLIF(SUM(c.costo_campana), 0) AS roi_pct
FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c ON p.clave_territorio = c.clave_territorio
GROUP BY p.pais, p.clave_territorio
ORDER BY p.clave_territorio, ingresos, costos;
```

**4. QA y validación** ([`04_qa_validacion.sql`]([./sql/04_qa_validacion.sql](https://github.com/ivanbayonaperez-cpu/AdventureWorks-Rentabilidad-de-Mercado-y-Eficiencia-de-Marketing-SQL-/blob/main/sql/%20%20%20sql/04_qa_validacion.sql))) — comprobación de totales agregados contra recálculo directo desde tablas base, detección de productos con margen negativo, y conteo de precios/cantidades no válidas (`< 0`).

## 📊 Resultados por país (2017)

| País | Ingresos | Beneficio Bruto | Margen % | ROI % |
|---|---|---|---|---|
| Estados Unidos | $3,353,939.92 | $1,454,468.60 | 43.4% | **75.8%** |
| Australia | $2,532,003.49 | $1,057,045.31 | 41.8% | 49.2% |
| Reino Unido | $1,189,636.78 | $508,128.24 | 42.7% | 22.1% |
| Alemania | $1,071,460.42 | $460,165.06 | 43.0% | 20.3% |
| Francia | $924,316.93 | $396,519.79 | 42.9% | 18.0% |
| Canadá | $710,205.18 | $317,879.27 | 44.8% | 17.4% |

## 🔎 Hallazgo principal (C→F→I)

**Contexto:** El margen operativo es prácticamente uniforme entre los 6 mercados (~43%), lo que descarta un problema de producto. La variable que sí se dispara es el ROI de marketing.

**Hallazgo:** Estados Unidos invierte en campañas un monto similar o menor al de otros mercados ($1.92M, el segundo más bajo tras Canadá) pero genera el mayor beneficio bruto absoluto — resultando en un ROI de 75.8%, frente a apenas 17-22% en Europa y Canadá. El problema no es cuánto se vende, sino qué tan eficientemente se convierte el gasto en marketing en ingresos.

**Implicación:** (1) Auditar qué canales de marketing usa EE.UU. y evaluar su replicabilidad en Australia y Reino Unido, donde el gasto es alto pero el retorno bajo. (2) Reducir presupuesto ~15% en mercados de ROI más débil (Alemania, Francia) y reasignarlo hacia EE.UU., donde cada dólar genera casi 4 veces más beneficio que en Europa.

**Análisis de escenario:** Se modeló el efecto de un incremento del 50% en gasto de campañas manteniendo ventas constantes — el ROI de EE.UU. caería de 75.8% a ~50.5% (seguiría siendo rentable), mientras que en mercados como Canadá o Francia (ROI ~17%) el mismo incremento llevaría el ROI a ~11%, un nivel de riesgo cercano al costo de capital de la empresa.

## 📁 Estructura del repositorio

```
adventureworks-rentabilidad-mercado/
├── README.md
├── sql/
│   ├── 01_exploracion.sql
│   ├── 02_extraccion_limpieza.sql
│   ├── 03_kpis_financieros.sql
│   └── 04_qa_validacion.sql
├── visualizaciones/
│   └── ingresos_roi_por_pais.png
└── AdventureWorks_Dashboard_Financiero.xlsx
```

## 🛠️ Herramientas

SQL (JOINs, CTEs, funciones de agregación, `COALESCE`/`NULLIF` para manejo de nulos y división segura, casting de tipos) — Google Sheets/Excel para el dashboard final y comunicación ejecutiva C→F→I.
