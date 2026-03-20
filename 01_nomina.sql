-- ============================================================
-- PROYECTO 4: SISTEMA DE NÓMINA
-- Nivel: INTERMEDIO
-- Motor: Oracle Database 19c+
-- Conceptos: Stored Procedures, Functions, Cursores básicos,
--            Manejo de excepciones PL/SQL, Triggers
-- Autor: Luis Angel Tapias Madronero
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE liquidaciones CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE deducciones_det CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE empleados CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE cargos CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE departamentos CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE tipos_deduccion CASCADE CONSTRAINTS';
    FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name LIKE 'SEQ_NOM%') LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE SEQUENCE seq_nom_depto   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_nom_cargo   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_nom_emp     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_nom_liq     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_nom_ded     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_nom_tipded  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================================
-- TABLAS
-- ============================================================
CREATE TABLE departamentos (
    id_depto    NUMBER        DEFAULT seq_nom_depto.NEXTVAL PRIMARY KEY,
    nombre      VARCHAR2(100) NOT NULL UNIQUE,
    ubicacion   VARCHAR2(100)
);

CREATE TABLE cargos (
    id_cargo        NUMBER         DEFAULT seq_nom_cargo.NEXTVAL PRIMARY KEY,
    nombre          VARCHAR2(100)  NOT NULL,
    salario_base    NUMBER(12,2)   NOT NULL,
    id_depto        NUMBER         NOT NULL,
    CONSTRAINT fk_cargo_depto FOREIGN KEY (id_depto) REFERENCES departamentos(id_depto),
    CONSTRAINT chk_salario    CHECK (salario_base > 0)
);

CREATE TABLE empleados (
    id_empleado     NUMBER        DEFAULT seq_nom_emp.NEXTVAL PRIMARY KEY,
    cedula          VARCHAR2(20)  NOT NULL UNIQUE,
    nombre          VARCHAR2(100) NOT NULL,
    apellido        VARCHAR2(100) NOT NULL,
    id_cargo        NUMBER        NOT NULL,
    fecha_ingreso   DATE          DEFAULT SYSDATE NOT NULL,
    activo          NUMBER(1)     DEFAULT 1 NOT NULL,
    CONSTRAINT fk_emp_cargo FOREIGN KEY (id_cargo) REFERENCES cargos(id_cargo),
    CONSTRAINT chk_emp_activo CHECK (activo IN (0,1))
);

CREATE TABLE tipos_deduccion (
    id_tipo_ded NUMBER        DEFAULT seq_nom_tipded.NEXTVAL PRIMARY KEY,
    nombre      VARCHAR2(100) NOT NULL UNIQUE,
    porcentaje  NUMBER(5,2)   NOT NULL,  -- % del salario
    obligatorio NUMBER(1)     DEFAULT 0,
    CONSTRAINT chk_pct_ded CHECK (porcentaje > 0 AND porcentaje < 100)
);

CREATE TABLE liquidaciones (
    id_liquidacion  NUMBER         DEFAULT seq_nom_liq.NEXTVAL PRIMARY KEY,
    id_empleado     NUMBER         NOT NULL,
    periodo         VARCHAR2(7)    NOT NULL,  -- Ej: '2025-07'
    salario_base    NUMBER(12,2)   NOT NULL,
    aux_transporte  NUMBER(12,2)   DEFAULT 0,
    horas_extra     NUMBER(5,2)    DEFAULT 0,
    valor_hora_extra NUMBER(12,2)  DEFAULT 0,
    total_devengado NUMBER(12,2)   NOT NULL,
    total_deducciones NUMBER(12,2) DEFAULT 0,
    neto_pagar      NUMBER(12,2)   NOT NULL,
    fecha_proceso   DATE           DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_liq_emp   FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    CONSTRAINT uq_liq_per   UNIQUE (id_empleado, periodo)
);

CREATE TABLE deducciones_det (
    id_deduccion    NUMBER        DEFAULT seq_nom_ded.NEXTVAL PRIMARY KEY,
    id_liquidacion  NUMBER        NOT NULL,
    id_tipo_ded     NUMBER        NOT NULL,
    valor           NUMBER(12,2)  NOT NULL,
    CONSTRAINT fk_ded_liq FOREIGN KEY (id_liquidacion) REFERENCES liquidaciones(id_liquidacion),
    CONSTRAINT fk_ded_tip FOREIGN KEY (id_tipo_ded)    REFERENCES tipos_deduccion(id_tipo_ded)
);

-- ============================================================
-- DATOS BASE
-- ============================================================
INSERT INTO departamentos (nombre, ubicacion) VALUES ('Tecnología',        'Piso 3 - Bogotá');
INSERT INTO departamentos (nombre, ubicacion) VALUES ('Recursos Humanos',  'Piso 1 - Bogotá');
INSERT INTO departamentos (nombre, ubicacion) VALUES ('Contabilidad',      'Piso 2 - Bogotá');
INSERT INTO departamentos (nombre, ubicacion) VALUES ('Operaciones',       'Bodega Principal');

INSERT INTO cargos (nombre, salario_base, id_depto) VALUES ('Desarrollador Junior',    2500000, 1);
INSERT INTO cargos (nombre, salario_base, id_depto) VALUES ('Desarrollador Senior',    5500000, 1);
INSERT INTO cargos (nombre, salario_base, id_depto) VALUES ('DBA',                     6000000, 1);
INSERT INTO cargos (nombre, salario_base, id_depto) VALUES ('Analista RRHH',            3000000, 2);
INSERT INTO cargos (nombre, salario_base, id_depto) VALUES ('Contador',                4000000, 3);
INSERT INTO cargos (nombre, salario_base, id_depto) VALUES ('Operario',                1423500, 4);

INSERT INTO empleados (cedula, nombre, apellido, id_cargo, fecha_ingreso) VALUES
('1023000001', 'Luisa',    'Pedraza',  1, DATE '2024-03-01');
INSERT INTO empleados (cedula, nombre, apellido, id_cargo, fecha_ingreso) VALUES
('1023000002', 'Hernando', 'Salcedo',  2, DATE '2022-01-15');
INSERT INTO empleados (cedula, nombre, apellido, id_cargo, fecha_ingreso) VALUES
('1023000003', 'Gloria',   'Ramírez',  3, DATE '2021-06-10');
INSERT INTO empleados (cedula, nombre, apellido, id_cargo, fecha_ingreso) VALUES
('1023000004', 'Javier',   'Morales',  4, DATE '2023-09-01');
INSERT INTO empleados (cedula, nombre, apellido, id_cargo, fecha_ingreso) VALUES
('1023000005', 'Marcela',  'Quintero', 5, DATE '2020-11-20');
INSERT INTO empleados (cedula, nombre, apellido, id_cargo, fecha_ingreso) VALUES
('1023000006', 'Pedro',    'Castillo', 6, DATE '2024-07-01');

-- Deducciones legales Colombia 2025
INSERT INTO tipos_deduccion (nombre, porcentaje, obligatorio) VALUES ('Salud empleado',      4.00, 1);
INSERT INTO tipos_deduccion (nombre, porcentaje, obligatorio) VALUES ('Pensión empleado',    4.00, 1);
INSERT INTO tipos_deduccion (nombre, porcentaje, obligatorio) VALUES ('Fondo Solidaridad',   1.00, 0);
INSERT INTO tipos_deduccion (nombre, porcentaje, obligatorio) VALUES ('Retención en Fuente', 0.00, 0);

COMMIT;

-- ============================================================
-- FUNCIONES
-- ============================================================

-- Función: Calcular años de antigüedad de un empleado
CREATE OR REPLACE FUNCTION fn_antiguedad_anios(p_id_empleado NUMBER)
RETURN NUMBER IS
    v_fecha_ingreso DATE;
BEGIN
    SELECT fecha_ingreso INTO v_fecha_ingreso
    FROM empleados WHERE id_empleado = p_id_empleado;

    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_ingreso) / 12);
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN -1;
END fn_antiguedad_anios;
/

-- Función: Calcular si aplica auxilio de transporte (salarios < 2 SMMLV)
CREATE OR REPLACE FUNCTION fn_auxilio_transporte(p_salario_base NUMBER)
RETURN NUMBER IS
    c_smmlv         CONSTANT NUMBER := 1423500;  -- SMMLV 2025
    c_aux_transporte CONSTANT NUMBER := 200000;   -- Aux transporte 2025
BEGIN
    IF p_salario_base <= (c_smmlv * 2) THEN
        RETURN c_aux_transporte;
    ELSE
        RETURN 0;
    END IF;
END fn_auxilio_transporte;
/

-- Función: Calcular valor hora extra (25% recargo diurno)
CREATE OR REPLACE FUNCTION fn_valor_hora_extra(p_salario_base NUMBER, p_horas NUMBER)
RETURN NUMBER IS
    v_valor_hora NUMBER;
BEGIN
    v_valor_hora := (p_salario_base / 240) * 1.25;  -- 240 horas/mes, +25%
    RETURN ROUND(v_valor_hora * p_horas, 0);
END fn_valor_hora_extra;
/

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- SP: Liquidar nómina de un empleado para un período
CREATE OR REPLACE PROCEDURE sp_liquidar_nomina(
    p_id_empleado   IN  NUMBER,
    p_periodo       IN  VARCHAR2,   -- formato YYYY-MM
    p_horas_extra   IN  NUMBER DEFAULT 0,
    p_id_liquidacion OUT NUMBER,
    p_mensaje        OUT VARCHAR2
) IS
    v_salario       NUMBER(12,2);
    v_aux_trans     NUMBER(12,2);
    v_val_he        NUMBER(12,2);
    v_devengado     NUMBER(12,2);
    v_deduccion_tot NUMBER(12,2) := 0;
    v_neto          NUMBER(12,2);
    v_ya_existe     NUMBER;

    CURSOR c_deducciones IS
        SELECT id_tipo_ded, nombre, porcentaje
        FROM tipos_deduccion
        WHERE obligatorio = 1;

BEGIN
    -- Verificar si ya existe liquidación para ese período
    SELECT COUNT(*) INTO v_ya_existe
    FROM liquidaciones
    WHERE id_empleado = p_id_empleado AND periodo = p_periodo;

    IF v_ya_existe > 0 THEN
        p_mensaje := 'ERROR: Ya existe liquidación para el período ' || p_periodo;
        p_id_liquidacion := -1;
        RETURN;
    END IF;

    -- Obtener salario base del empleado
    SELECT c.salario_base INTO v_salario
    FROM empleados e
    INNER JOIN cargos c ON e.id_cargo = c.id_cargo
    WHERE e.id_empleado = p_id_empleado AND e.activo = 1;

    -- Calcular conceptos
    v_aux_trans := fn_auxilio_transporte(v_salario);
    v_val_he    := fn_valor_hora_extra(v_salario, p_horas_extra);
    v_devengado := v_salario + v_aux_trans + v_val_he;

    -- Insertar liquidación cabecera
    INSERT INTO liquidaciones (
        id_empleado, periodo, salario_base, aux_transporte,
        horas_extra, valor_hora_extra, total_devengado, neto_pagar
    ) VALUES (
        p_id_empleado, p_periodo, v_salario, v_aux_trans,
        p_horas_extra, v_val_he, v_devengado, v_devengado
    ) RETURNING id_liquidacion INTO p_id_liquidacion;

    -- Calcular y registrar deducciones con cursor
    FOR r_ded IN c_deducciones LOOP
        DECLARE v_valor_ded NUMBER(12,2);
        BEGIN
            v_valor_ded := ROUND(v_salario * r_ded.porcentaje / 100, 0);
            v_deduccion_tot := v_deduccion_tot + v_valor_ded;

            INSERT INTO deducciones_det (id_liquidacion, id_tipo_ded, valor)
            VALUES (p_id_liquidacion, r_ded.id_tipo_ded, v_valor_ded);
        END;
    END LOOP;

    -- Actualizar neto
    v_neto := v_devengado - v_deduccion_tot;
    UPDATE liquidaciones
    SET total_deducciones = v_deduccion_tot, neto_pagar = v_neto
    WHERE id_liquidacion = p_id_liquidacion;

    COMMIT;
    p_mensaje := 'ÉXITO: Nómina liquidada. Neto a pagar: $' || TO_CHAR(v_neto, '999,999,999');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        p_id_liquidacion := -1;
        p_mensaje := 'ERROR: Empleado no encontrado o inactivo.';
    WHEN OTHERS THEN
        ROLLBACK;
        p_id_liquidacion := -1;
        p_mensaje := 'ERROR: ' || SQLERRM;
END sp_liquidar_nomina;
/

-- SP: Reporte de nómina por período con cursor
CREATE OR REPLACE PROCEDURE sp_reporte_nomina(p_periodo IN VARCHAR2) IS
    CURSOR c_nomina IS
        SELECT
            e.nombre || ' ' || e.apellido   AS empleado,
            c.nombre                         AS cargo,
            d.nombre                         AS departamento,
            l.salario_base,
            l.aux_transporte,
            l.valor_hora_extra,
            l.total_devengado,
            l.total_deducciones,
            l.neto_pagar
        FROM liquidaciones l
        INNER JOIN empleados     e ON l.id_empleado = e.id_empleado
        INNER JOIN cargos        c ON e.id_cargo    = c.id_cargo
        INNER JOIN departamentos d ON c.id_depto    = d.id_depto
        WHERE l.periodo = p_periodo
        ORDER BY d.nombre, e.apellido;

    v_total_nomina NUMBER(15,2) := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================');
    DBMS_OUTPUT.PUT_LINE('REPORTE DE NÓMINA — Período: ' || p_periodo);
    DBMS_OUTPUT.PUT_LINE('====================================');

    FOR r IN c_nomina LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.empleado, 30) || ' | ' ||
            RPAD(r.cargo, 25)    || ' | ' ||
            'Neto: $' || TO_CHAR(r.neto_pagar, '999,999,999')
        );
        v_total_nomina := v_total_nomina + r.neto_pagar;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TOTAL NÓMINA: $' || TO_CHAR(v_total_nomina, '999,999,999'));
END sp_reporte_nomina;
/

-- ============================================================
-- TRIGGER: Validar que el empleado esté activo al liquidar
-- ============================================================
CREATE OR REPLACE TRIGGER trg_validar_empleado_activo
BEFORE INSERT ON liquidaciones
FOR EACH ROW
DECLARE
    v_activo NUMBER(1);
BEGIN
    SELECT activo INTO v_activo FROM empleados WHERE id_empleado = :NEW.id_empleado;
    IF v_activo = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede liquidar un empleado inactivo.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Empleado no encontrado.');
END;
/

-- ============================================================
-- EJECUCIÓN DE EJEMPLO
-- ============================================================
SET SERVEROUTPUT ON;

DECLARE
    v_id_liq NUMBER;
    v_msg    VARCHAR2(500);
BEGIN
    -- Liquidar todos los empleados para julio 2025
    FOR r IN (SELECT id_empleado FROM empleados WHERE activo = 1) LOOP
        sp_liquidar_nomina(r.id_empleado, '2025-07', 0, v_id_liq, v_msg);
        DBMS_OUTPUT.PUT_LINE(v_msg);
    END LOOP;
END;
/

-- Empleado con horas extra
DECLARE
    v_id NUMBER; v_msg VARCHAR2(500);
BEGIN
    sp_liquidar_nomina(1, '2025-08', 10, v_id, v_msg);
    DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/

-- Ver reporte de nómina
EXEC sp_reporte_nomina('2025-07');

-- Consulta de resumen por departamento
SELECT
    d.nombre                       AS departamento,
    COUNT(DISTINCT e.id_empleado)  AS empleados,
    SUM(l.total_devengado)         AS total_devengado,
    SUM(l.total_deducciones)       AS total_deducciones,
    SUM(l.neto_pagar)              AS total_neto
FROM liquidaciones l
INNER JOIN empleados     e ON l.id_empleado = e.id_empleado
INNER JOIN cargos        c ON e.id_cargo    = c.id_cargo
INNER JOIN departamentos d ON c.id_depto    = d.id_depto
WHERE l.periodo = '2025-07'
GROUP BY d.nombre
ORDER BY total_neto DESC;
