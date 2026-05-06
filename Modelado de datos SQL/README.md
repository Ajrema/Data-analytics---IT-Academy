# Sprint 4 · Modelado de Datos SQL

## Descripción

Diseño e implementación de una base de datos relacional con **esquema estrella** a partir de datasets reales en formato CSV. El proyecto incluye la creación de tablas, relaciones, consultas avanzadas y análisis del estado de tarjetas de crédito.

## Datasets utilizados

- `american_users.csv` / `european_users.csv` — datos de usuarios
- `companies.csv` — empresas asociadas a tarjetas
- `credit_cards.csv` — tarjetas de crédito
- `transactions.csv` — historial de transacciones
- `products.csv` — catálogo de productos

## Tecnologías

- MySQL / MySQL Workbench
- SQL: DDL, DML, subconsultas, JOINs, funciones de agregación

## Contenido del repositorio

| Archivo | Descripción |
|---|---|
| `Practica Sprint 4.sql` | Scripts completos: creación de tablas, inserciones y consultas |
| `Modelado de datos SQL Sprint 4.pdf` | Capturas del Workbench con resultados de cada ejercicio |

## Ejercicios resueltos

**Nivel 1**
- Subconsulta para identificar usuarios con más de 80 transacciones
- Media de `amount` por IBAN para tarjetas de la empresa *Donec Ltd*

**Nivel 2**
- Clasificación de tarjetas como **activa** o **inactiva** según el estado de sus últimas 3 transacciones

**Nivel 3**
- Integración de la tabla `products` mediante `product_ids` desde `transactions`
- Consulta del número de ventas por producto