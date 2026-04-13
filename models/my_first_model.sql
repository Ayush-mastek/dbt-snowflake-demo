{{ config(materialized='table') }}

SELECT
    1 AS id,
    'Ayush' AS name,
    'Chennai' AS city,
    CURRENT_DATE AS created_date

UNION ALL

SELECT 2, 'Priya', 'Mumbai', CURRENT_DATE

UNION ALL

SELECT 3, 'Ram', 'Pune', CURRENT_DATE