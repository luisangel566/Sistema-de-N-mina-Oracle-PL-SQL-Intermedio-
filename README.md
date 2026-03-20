# 💰 Sistema de Nómina — Oracle PL/SQL (Intermedio)

Sistema de liquidación de nómina desarrollado en Oracle, que automatiza el cálculo de salarios, deducciones y generación de reportes utilizando PL/SQL.

---

## 🎯 Objetivo del Proyecto

Diseñar e implementar un sistema de nómina que permita calcular el pago de empleados considerando salario base, horas extra, deducciones legales y generación de reportes por período.

---

## 🧠 Conceptos Aplicados

* PL/SQL (Oracle)
* Stored Procedures
* Functions
* Cursores (`CURSOR`)
* Manejo de excepciones (`EXCEPTION`)
* Triggers
* Modelado relacional
* Constraints:

  * PRIMARY KEY
  * FOREIGN KEY
  * UNIQUE
  * CHECK
* Secuencias (`SEQUENCE`)
* Funciones de fecha (`SYSDATE`, `MONTHS_BETWEEN`)
* Operaciones financieras y cálculos

---

## 🧱 Modelo de Datos

### Tablas principales:

* **departamentos** → Áreas de la empresa
* **cargos** → Roles con salario base
* **empleados** → Información del personal
* **tipos_deduccion** → Deducciones legales
* **liquidaciones** → Resultado de la nómina
* **deducciones_det** → Detalle de deducciones

---

## ⚙️ Funcionalidades Implementadas

* Gestión de empleados, cargos y departamentos
* Cálculo automático de nómina
* Aplicación de deducciones legales (salud, pensión)
* Cálculo de horas extra
* Generación de reportes por período
* Validaciones mediante triggers

---

## 🔧 Funciones Implementadas

### 🔹 fn_antiguedad_anios

Calcula los años de antigüedad de un empleado.

---

### 🔹 fn_auxilio_transporte

Determina si el empleado aplica al auxilio de transporte según su salario.

---

### 🔹 fn_valor_hora_extra

Calcula el valor de horas extra con recargo del 25%.

---

## ⚙️ Stored Procedures

### 🔹 sp_liquidar_nomina

* Calcula la nómina completa de un empleado
* Aplica deducciones mediante cursor
* Inserta registros en liquidaciones y detalle
* Maneja validaciones y errores

---

### 🔹 sp_reporte_nomina

* Genera reporte de nómina por período
* Muestra resultados en consola (`DBMS_OUTPUT`)
* Calcula el total general de pagos

---

## ⚠️ Trigger Implementado

### 🔹 trg_validar_empleado_activo

* Evita liquidar empleados inactivos
* Valida existencia del empleado

---

## 📊 Consultas Destacadas

* Resumen de nómina por departamento
* Total devengado, deducciones y neto a pagar
* Reportes estructurados por período

---

## 🚀 Ejecución

Ejecutar el script completo en Oracle:

```sql id="q9x2wd"
@04_sistema_nomina.sql
```

---

## 🧪 Datos de Prueba

Incluye:

* Empleados con distintos cargos
* Deducciones legales en Colombia
* Simulación de liquidación mensual
* Ejecución automática de nómina

---

## 🏗️ Estructura del Proyecto

```id="z8m1pl"
04-sistema-nomina/
├── sql/
│   └── 04_sistema_nomina.sql
└── README.md
```

---

## 💡 Lo que demuestra este proyecto

* Automatización de procesos empresariales con PL/SQL
* Implementación de lógica de negocio en base de datos
* Manejo de cursores y estructuras de control
* Validaciones mediante triggers
* Desarrollo de soluciones tipo empresa real (nómina)

---

## 👨‍💻 Autor

Luis Ángel Tapias Madroñero
Ingeniero de Sistemas — Bogotá, Colombia

🔗 https://github.com/luisangel566

