
WITH A AS (
    SELECT date_trunc('MONTH', TO_DATE(TO_VARCHAR(DATE_SK), 'YYYYMMDD')) AS year_month, CM_GEO_AREA, PRICE_NET_EUR
FROM BI.REVENUE r JOIN BI.PRODUCT p ON r.PRODUCT_SK = p.PRODUCT_SK
LEFT JOIN COUNTRY C on r.COUNTRY_CODE3 = C.COUNTRY_CODE3
WHERE r.CREATED_AT >= '2020-01-01' AND IS_FIRST_PERIOD LIKE 'TRUE' AND SUBSCRIPTION_MODE LIKE '12M12'
AND HAS_COUPON='FALSE'  )

, avg_total AS (
        SELECT AVG(PRICE_NET_EUR) AS avg_company
        FROM A
    )

, avg_geo AS (
        SELECT year_month, cm_geo_area, AVG(price_net_eur) avg_geo
        FROM A
        GROUP BY year_month, cm_geo_area
    )

SELECT year_month, cm_geo_area,
       CASE WHEN avg_geo < avg_company THEN 'lower'
            WHEN avg_geo > avg_company THEN 'higher'
            ELSE 'same' END geoprice_vs_company
FROM avg_geo, avg_total
ORDER BY  1, 2

