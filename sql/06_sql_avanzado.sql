-- CVTM | Parte D: SQL avanzado | MySQL 8.0
-- Requiere 01, 02 y 03 ejecutados en ese orden, sobre una base recién creada.

USE veterinaria_db;

WITH cte_productos AS (
    SELECT dv.ID_Venta, SUM(dv.Subtotal) AS Total_Productos
    FROM Detalle_Venta dv
    GROUP BY dv.ID_Venta
),
cte_prestaciones AS (
    SELECT dp.ID_Venta, SUM(dp.Subtotal) AS Total_Prestaciones
    FROM Detalle_Prestacion dp
    GROUP BY dp.ID_Venta
)
SELECT v.ID_Venta,
       v.Fecha_Pago,
       v.Monto_Venta,
       COALESCE(p.Total_Productos, 0)     AS Total_Productos,
       COALESCE(s.Total_Prestaciones, 0)  AS Total_Prestaciones,
       v.Monto_Venta - COALESCE(p.Total_Productos, 0)
                     - COALESCE(s.Total_Prestaciones, 0) AS Diferencia
FROM Venta v
LEFT JOIN cte_productos p    ON p.ID_Venta = v.ID_Venta
LEFT JOIN cte_prestaciones s ON s.ID_Venta = v.ID_Venta
ORDER BY v.ID_Venta;

WITH cte_mascotas AS (
    SELECT m.Rut_Cliente, COUNT(*) AS Mascotas
    FROM Mascota m
    GROUP BY m.Rut_Cliente
),
cte_gasto AS (
    SELECT v.Rut_Cliente, COUNT(*) AS Compras, SUM(v.Monto_Venta) AS Gasto_Total
    FROM Venta v
    WHERE v.Rut_Cliente IS NOT NULL
    GROUP BY v.Rut_Cliente
)
SELECT c.Rut_Cliente,
       c.Nombre,
       COALESCE(m.Mascotas, 0)    AS Mascotas,
       COALESCE(g.Compras, 0)     AS Compras,
       COALESCE(g.Gasto_Total, 0) AS Gasto_Total
FROM Cliente c
LEFT JOIN cte_mascotas m ON m.Rut_Cliente = c.Rut_Cliente
LEFT JOIN cte_gasto g    ON g.Rut_Cliente = c.Rut_Cliente
ORDER BY Gasto_Total DESC, c.Nombre;

WITH cte_entradas AS (
    SELECT i.ID_Producto, i.Rut_Proveedor,
           SUM(i.Cantidad)         AS Unidades_Recibidas,
           MAX(i.Fecha_Movimiento) AS Ultima_Entrada
    FROM Inventario i
    WHERE i.Tipo_Movimiento = 'entrada'
      AND i.Rut_Proveedor IS NOT NULL
    GROUP BY i.ID_Producto, i.Rut_Proveedor
)
SELECT pr.Nombre_Proveedor,
       p.Nombre_Producto,
       e.Unidades_Recibidas,
       e.Ultima_Entrada
FROM cte_entradas e
JOIN Proveedor pr ON pr.Rut_Proveedor = e.Rut_Proveedor
JOIN Producto p   ON p.ID_Producto = e.ID_Producto
ORDER BY pr.Nombre_Proveedor, p.Nombre_Producto;

WITH RECURSIVE cte_calendario AS (
    SELECT DATE('2026-10-01') AS Fecha
    UNION ALL
    SELECT cal.Fecha + INTERVAL 1 DAY
    FROM cte_calendario cal
    WHERE cal.Fecha < '2026-10-31'
),
cte_citas_dia AS (
    SELECT DATE(ci.Fecha_Hora) AS Fecha, COUNT(*) AS Citas
    FROM Cita ci
    WHERE ci.Fecha_Hora >= '2026-10-01'
      AND ci.Fecha_Hora <  '2026-11-01'
    GROUP BY DATE(ci.Fecha_Hora)
)
SELECT cal.Fecha,
       ELT(WEEKDAY(cal.Fecha) + 1, 'lunes', 'martes', 'miércoles', 'jueves',
           'viernes', 'sábado', 'domingo') AS Dia,
       COALESCE(cd.Citas, 0) AS Citas
FROM cte_calendario cal
LEFT JOIN cte_citas_dia cd ON cd.Fecha = cal.Fecha
ORDER BY cal.Fecha;

WITH RECURSIVE cte_bloques AS (
    SELECT CAST('2026-10-10 09:00:00' AS DATETIME) AS Inicio
    UNION ALL
    SELECT b.Inicio + INTERVAL 30 MINUTE
    FROM cte_bloques b
    WHERE b.Inicio < '2026-10-10 17:30:00'
)
SELECT b.Inicio AS Bloque_Libre
FROM cte_bloques b
LEFT JOIN Cita ci
       ON ci.Rut_Veterinario = '14.890.123-4'
      AND ci.Bloque_Activo   = b.Inicio
WHERE ci.N_Cita IS NULL
ORDER BY b.Inicio;

CREATE OR REPLACE VIEW v_agenda_clinica AS
SELECT ci.N_Cita,
       ci.Fecha_Hora,
       ci.Estado,
       m.ID_Mascota,
       m.Nombre  AS Mascota,
       c.Nombre  AS Dueno,
       v.Nombre  AS Veterinario
FROM Cita ci
JOIN Mascota m     ON m.ID_Mascota = ci.ID_Mascota
JOIN Cliente c     ON c.Rut_Cliente = m.Rut_Cliente
JOIN Veterinario v ON v.Rut_Veterinario = ci.Rut_Veterinario;

CREATE OR REPLACE VIEW v_venta_resumen AS
SELECT v.ID_Venta,
       v.Fecha_Pago,
       v.Forma_Pago,
       v.Monto_Venta,
       COALESCE(p.Total_Productos, 0)     AS Total_Productos,
       COALESCE(s.Total_Prestaciones, 0)  AS Total_Prestaciones,
       v.Monto_Venta - COALESCE(p.Total_Productos, 0)
                     - COALESCE(s.Total_Prestaciones, 0) AS Diferencia
FROM Venta v
LEFT JOIN (SELECT dv.ID_Venta, SUM(dv.Subtotal) AS Total_Productos
           FROM Detalle_Venta dv
           GROUP BY dv.ID_Venta) p ON p.ID_Venta = v.ID_Venta
LEFT JOIN (SELECT dp.ID_Venta, SUM(dp.Subtotal) AS Total_Prestaciones
           FROM Detalle_Prestacion dp
           GROUP BY dp.ID_Venta) s ON s.ID_Venta = v.ID_Venta;

CREATE OR REPLACE VIEW v_stock_critico AS
SELECT p.ID_Producto,
       p.Nombre_Producto,
       p.Stock,
       p.Fecha_Vencimiento,
       pr.Nombre_Proveedor
FROM Producto p
LEFT JOIN Proveedor pr ON pr.Rut_Proveedor = p.Rut_Proveedor
WHERE p.Stock <= 20
   OR (p.Fecha_Vencimiento IS NOT NULL
       AND p.Fecha_Vencimiento <= CURDATE() + INTERVAL 60 DAY);

SELECT a.N_Cita, a.Fecha_Hora, a.Estado, a.Mascota, a.Dueno, a.Veterinario
FROM v_agenda_clinica a
ORDER BY a.Fecha_Hora;

SELECT r.ID_Venta, r.Monto_Venta, r.Total_Productos, r.Total_Prestaciones, r.Diferencia
FROM v_venta_resumen r
ORDER BY r.ID_Venta;

SELECT s.ID_Producto, s.Nombre_Producto, s.Stock, s.Fecha_Vencimiento
FROM v_stock_critico s
ORDER BY s.Stock;

CREATE DATABASE IF NOT EXISTS veterinaria_dw;

DROP TABLE IF EXISTS veterinaria_dw.mv_ingresos_mensuales;
CREATE TABLE veterinaria_dw.mv_ingresos_mensuales (
    Periodo         CHAR(7)        NOT NULL,
    Forma_Pago      VARCHAR(20)    NOT NULL,
    Ventas          INT            NOT NULL,
    Ingreso_Total   DECIMAL(12,2)  NOT NULL,
    Ticket_Promedio DECIMAL(10,2)  NOT NULL,
    Actualizado_En  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Periodo, Forma_Pago)
);

DELIMITER $$
DROP PROCEDURE IF EXISTS veterinaria_dw.sp_refrescar_mv_ingresos$$
CREATE PROCEDURE veterinaria_dw.sp_refrescar_mv_ingresos()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    DELETE FROM veterinaria_dw.mv_ingresos_mensuales;
    INSERT INTO veterinaria_dw.mv_ingresos_mensuales
           (Periodo, Forma_Pago, Ventas, Ingreso_Total, Ticket_Promedio)
    SELECT DATE_FORMAT(v.Fecha_Pago, '%Y-%m'),
           COALESCE(v.Forma_Pago, 'Sin informar'),
           COUNT(*),
           SUM(v.Monto_Venta),
           ROUND(AVG(v.Monto_Venta), 2)
    FROM veterinaria_db.Venta v
    GROUP BY DATE_FORMAT(v.Fecha_Pago, '%Y-%m'),
             COALESCE(v.Forma_Pago, 'Sin informar');
    COMMIT;
END$$
DELIMITER ;

SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS veterinaria_dw.ev_refrescar_mv_ingresos;
CREATE EVENT veterinaria_dw.ev_refrescar_mv_ingresos
    ON SCHEDULE EVERY 1 DAY
    STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 2 HOUR)
    DO CALL veterinaria_dw.sp_refrescar_mv_ingresos();

CALL veterinaria_dw.sp_refrescar_mv_ingresos();

SELECT mv.Periodo, mv.Forma_Pago, mv.Ventas, mv.Ingreso_Total, mv.Ticket_Promedio
FROM veterinaria_dw.mv_ingresos_mensuales mv
ORDER BY mv.Periodo, mv.Forma_Pago;

SELECT ci.N_Cita, ci.Fecha_Hora, ci.Estado, m.Nombre AS Mascota
FROM Cita ci
JOIN Mascota m ON m.ID_Mascota = ci.ID_Mascota
WHERE ci.Rut_Veterinario = '14.890.123-4'
  AND ci.Fecha_Hora >= '2026-10-10'
  AND ci.Fecha_Hora <  '2026-10-11'
ORDER BY ci.Fecha_Hora;

SELECT p.ID_Producto, p.Nombre_Producto, p.Stock
FROM Producto p
WHERE p.ID_Producto = 2;

SELECT DATE_FORMAT(v.Fecha_Pago, '%Y-%m')   AS Periodo,
       COALESCE(v.Forma_Pago, 'Sin informar') AS Forma_Pago,
       COUNT(*)                              AS Ventas,
       SUM(v.Monto_Venta)                    AS Ingreso_Total,
       ROUND(AVG(v.Monto_Venta), 2)          AS Ticket_Promedio
FROM Venta v
GROUP BY DATE_FORMAT(v.Fecha_Pago, '%Y-%m'), COALESCE(v.Forma_Pago, 'Sin informar')
ORDER BY Periodo, Forma_Pago;

SELECT mv.Periodo, mv.Forma_Pago, mv.Ventas, mv.Ingreso_Total, mv.Ticket_Promedio
FROM veterinaria_dw.mv_ingresos_mensuales mv
ORDER BY mv.Periodo, mv.Forma_Pago;

WITH cte_ingreso_producto AS (
    SELECT p.ID_Producto,
           p.Nombre_Producto,
           SUM(dv.Cantidad) AS Unidades,
           SUM(dv.Subtotal) AS Ingreso
    FROM Detalle_Venta dv
    JOIN Producto p ON p.ID_Producto = dv.ID_Producto
    GROUP BY p.ID_Producto, p.Nombre_Producto
)
SELECT RANK()       OVER (ORDER BY i.Ingreso DESC)  AS Ranking,
       DENSE_RANK() OVER (ORDER BY i.Unidades DESC) AS Ranking_Unidades,
       i.Nombre_Producto,
       i.Unidades,
       i.Ingreso,
       ROUND(100 * i.Ingreso / SUM(i.Ingreso) OVER (), 1) AS Porcentaje_Total
FROM cte_ingreso_producto i
ORDER BY Ranking, i.Nombre_Producto;

WITH cte_ventas_dia AS (
    SELECT v.Fecha_Pago, SUM(v.Monto_Venta) AS Total_Dia
    FROM Venta v
    GROUP BY v.Fecha_Pago
)
SELECT d.Fecha_Pago,
       d.Total_Dia,
       SUM(d.Total_Dia) OVER (ORDER BY d.Fecha_Pago
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Acumulado,
       LAG(d.Total_Dia) OVER (ORDER BY d.Fecha_Pago)                             AS Dia_Anterior,
       d.Total_Dia - LAG(d.Total_Dia) OVER (ORDER BY d.Fecha_Pago)               AS Variacion
FROM cte_ventas_dia d
ORDER BY d.Fecha_Pago;

SELECT v.Nombre AS Veterinario,
       DATE(ci.Fecha_Hora) AS Dia,
       ROW_NUMBER() OVER (PARTITION BY ci.Rut_Veterinario, DATE(ci.Fecha_Hora)
                          ORDER BY ci.Fecha_Hora) AS Orden_En_El_Dia,
       COUNT(*)     OVER (PARTITION BY ci.Rut_Veterinario, DATE(ci.Fecha_Hora)) AS Citas_Del_Dia,
       ci.Fecha_Hora,
       ci.Estado
FROM Cita ci
JOIN Veterinario v ON v.Rut_Veterinario = ci.Rut_Veterinario
ORDER BY v.Nombre, ci.Fecha_Hora;