-- CVTM | Parte E: roles, privilegios y usuarios | MySQL 8.0
-- Implementa la matriz Actor x Tabla (principio de mínimo privilegio) y RF-10.
-- Requiere 01 a 03 y 06 ejecutados antes (las vistas y veterinaria_dw deben existir).
-- Se ejecuta con una cuenta administradora (por ejemplo root).

DROP USER IF EXISTS 'usr_vet01'@'localhost', 'usr_recep01'@'localhost',
                    'usr_tienda01'@'localhost', 'usr_admin01'@'localhost',
                    'usr_aux01'@'localhost', 'usr_integra01'@'localhost';
DROP ROLE IF EXISTS 'rol_veterinario', 'rol_recepcionista', 'rol_encargado_tienda',
                    'rol_administrador', 'rol_auxiliar_vet', 'rol_integracion_lectura';

CREATE ROLE 'rol_veterinario', 'rol_recepcionista', 'rol_encargado_tienda',
            'rol_administrador', 'rol_auxiliar_vet', 'rol_integracion_lectura';

GRANT SELECT ON veterinaria_db.Cliente               TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Mascota               TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Historial_Responsable TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Cita                  TO 'rol_veterinario';
GRANT UPDATE (Estado) ON veterinaria_db.Cita         TO 'rol_veterinario';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Ficha_Medica TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Veterinario           TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Prestacion            TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Producto              TO 'rol_veterinario';

GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Cliente TO 'rol_recepcionista';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Mascota TO 'rol_recepcionista';
GRANT SELECT, INSERT ON veterinaria_db.Historial_Responsable TO 'rol_recepcionista';
GRANT UPDATE (Fecha_Fin) ON veterinaria_db.Historial_Responsable TO 'rol_recepcionista';
GRANT SELECT ON veterinaria_db.Cita TO 'rol_recepcionista';
GRANT INSERT (Fecha_Hora, Estado, ID_Mascota, Rut_Veterinario)
      ON veterinaria_db.Cita TO 'rol_recepcionista';
GRANT UPDATE (Fecha_Hora, Estado, ID_Mascota, Rut_Veterinario)
      ON veterinaria_db.Cita TO 'rol_recepcionista';
GRANT SELECT ON veterinaria_db.Veterinario TO 'rol_recepcionista';
GRANT SELECT ON veterinaria_db.Cajero      TO 'rol_recepcionista';
GRANT SELECT ON veterinaria_db.Prestacion  TO 'rol_recepcionista';
GRANT SELECT ON veterinaria_db.Producto    TO 'rol_recepcionista';
GRANT UPDATE (Stock) ON veterinaria_db.Producto TO 'rol_recepcionista';
GRANT SELECT, INSERT ON veterinaria_db.Venta              TO 'rol_recepcionista';
GRANT SELECT, INSERT ON veterinaria_db.Detalle_Venta      TO 'rol_recepcionista';
GRANT SELECT, INSERT ON veterinaria_db.Detalle_Prestacion TO 'rol_recepcionista';

GRANT INSERT (ID_Producto, Tipo_Movimiento, Cantidad, Fecha_Movimiento)
      ON veterinaria_db.Inventario TO 'rol_recepcionista';

GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Producto  TO 'rol_encargado_tienda';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Proveedor TO 'rol_encargado_tienda';
GRANT SELECT, INSERT         ON veterinaria_db.Inventario TO 'rol_encargado_tienda';

GRANT SELECT ON veterinaria_db.Cliente               TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.Mascota               TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.Historial_Responsable TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.Cita                  TO 'rol_administrador';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Veterinario TO 'rol_administrador';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Cajero      TO 'rol_administrador';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Prestacion  TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.Producto              TO 'rol_administrador';
GRANT UPDATE (Precio_Unitario) ON veterinaria_db.Producto TO 'rol_administrador';
GRANT SELECT, INSERT, UPDATE, DELETE ON veterinaria_db.Proveedor TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.Inventario            TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.Venta                 TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.Detalle_Venta         TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.Detalle_Prestacion    TO 'rol_administrador';

GRANT SELECT ON veterinaria_db.Mascota      TO 'rol_auxiliar_vet';
GRANT SELECT ON veterinaria_db.Cita         TO 'rol_auxiliar_vet';
GRANT SELECT ON veterinaria_db.Ficha_Medica TO 'rol_auxiliar_vet';

GRANT SELECT ON veterinaria_db.v_venta_resumen            TO 'rol_integracion_lectura';
GRANT SELECT ON veterinaria_db.v_stock_critico            TO 'rol_integracion_lectura';
GRANT SELECT ON veterinaria_dw.mv_ingresos_mensuales      TO 'rol_integracion_lectura';

GRANT SELECT ON veterinaria_db.v_agenda_clinica TO 'rol_veterinario', 'rol_recepcionista',
                                                   'rol_auxiliar_vet', 'rol_administrador';
GRANT SELECT ON veterinaria_db.v_venta_resumen  TO 'rol_administrador';
GRANT SELECT ON veterinaria_db.v_stock_critico  TO 'rol_encargado_tienda', 'rol_administrador';
GRANT SELECT ON veterinaria_dw.mv_ingresos_mensuales TO 'rol_administrador';

CREATE USER 'usr_vet01'@'localhost'    IDENTIFIED BY 'Cambiar#Vet01'
    PASSWORD EXPIRE FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;
CREATE USER 'usr_recep01'@'localhost'  IDENTIFIED BY 'Cambiar#Recep01'
    PASSWORD EXPIRE FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;
CREATE USER 'usr_tienda01'@'localhost' IDENTIFIED BY 'Cambiar#Tienda01'
    PASSWORD EXPIRE FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;
CREATE USER 'usr_admin01'@'localhost'  IDENTIFIED BY 'Cambiar#Admin01'
    PASSWORD EXPIRE FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;
CREATE USER 'usr_aux01'@'localhost'    IDENTIFIED BY 'Cambiar#Aux01'
    PASSWORD EXPIRE FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;
CREATE USER 'usr_integra01'@'localhost' IDENTIFIED BY 'Cambiar#Integra01'
    PASSWORD EXPIRE FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;

GRANT 'rol_veterinario'          TO 'usr_vet01'@'localhost';
GRANT 'rol_recepcionista'        TO 'usr_recep01'@'localhost';
GRANT 'rol_encargado_tienda'     TO 'usr_tienda01'@'localhost';
GRANT 'rol_administrador'        TO 'usr_admin01'@'localhost';
GRANT 'rol_auxiliar_vet'         TO 'usr_aux01'@'localhost';
GRANT 'rol_integracion_lectura'  TO 'usr_integra01'@'localhost';

SET DEFAULT ROLE 'rol_veterinario'         TO 'usr_vet01'@'localhost';
SET DEFAULT ROLE 'rol_recepcionista'       TO 'usr_recep01'@'localhost';
SET DEFAULT ROLE 'rol_encargado_tienda'    TO 'usr_tienda01'@'localhost';
SET DEFAULT ROLE 'rol_administrador'       TO 'usr_admin01'@'localhost';
SET DEFAULT ROLE 'rol_auxiliar_vet'        TO 'usr_aux01'@'localhost';
SET DEFAULT ROLE 'rol_integracion_lectura' TO 'usr_integra01'@'localhost';

SHOW GRANTS FOR 'rol_veterinario';
SHOW GRANTS FOR 'rol_recepcionista';
SHOW GRANTS FOR 'rol_encargado_tienda';
SHOW GRANTS FOR 'rol_administrador';
SHOW GRANTS FOR 'rol_auxiliar_vet';
SHOW GRANTS FOR 'usr_vet01'@'localhost' USING 'rol_veterinario';

SELECT tp.User AS Rol, tp.Table_name, tp.Table_priv
FROM mysql.tables_priv tp
WHERE tp.Db = 'veterinaria_db' AND tp.Table_name = 'Ficha_Medica'
ORDER BY tp.User;

SELECT cp.User AS Rol, cp.Table_name, cp.Column_name, cp.Column_priv
FROM mysql.columns_priv cp
WHERE cp.Db = 'veterinaria_db' AND cp.Table_name IN ('Cita', 'Producto')
ORDER BY cp.Table_name, cp.User, cp.Column_name;