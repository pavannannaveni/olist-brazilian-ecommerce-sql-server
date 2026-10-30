/*
============================================================
Project: Brazilian E-Commerce SQL Analytics
Database: Ecommerce
Script: 01_table_row_counts.sql

Purpose:
    Review row counts for user tables in the current database.
    Uses SQL Server metadata for a quick initial audit.

Notes:
    Metadata row counts are approximate. For final validation,
    compare against exact COUNT_BIG(*) queries.

Author: Pavan Nannaveni
============================================================
*/

USE Ecommerce;
GO

SET NOCOUNT ON;

SELECT
    DB_NAME() AS DatabaseName,
    s.name AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS ApproxRowCount
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
INNER JOIN sys.partitions AS p
    ON t.object_id = p.object_id
WHERE
    p.index_id IN (0, 1)
    AND t.is_ms_shipped = 0
GROUP BY
    s.name,
    t.name
ORDER BY
    s.name,
    t.name;
GO
