------------------------------------------------------------------------------
--Report 8
------------------------------------------------------------------------------ 
--SQL command (Version 1-Level 2):
SELECT
    *
FROM
    clientfact_v1;

SELECT
    cf.budget_type,
    cf.time_id,
    to_char(SUM(total_visit_clients + total_rent_clients + total_sale_clients), '9,999,999,999'
    ) AS totalclients,
    to_char(SUM(SUM(total_visit_clients + total_rent_clients + total_sale_clients
    )) OVER(
        ORDER BY
            cf.time_id
        ROWS UNBOUNDED PRECEDING
    ), '9,999,999,999') AS cummulative_no_of_clients
FROM
    clientallyearsfact_v1 cf
WHERE
    cf.budget_type = 'High'
GROUP BY
    cf.budget_type,
    cf.time_id;
    
--SQL command (Version 2-Level 0):
SELECT
    year,
    total_count,
    SUM(total_count) OVER(
        ORDER BY
            year
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_clients
FROM
    (
        SELECT
            year,
            COUNT(client_person_id) AS total_count
        FROM
            (
                SELECT
                    to_char(visit_date, 'yyyy') AS year,
                    client_person_id
                FROM
                    visitfact_v2
                WHERE
                    client_person_id IN (
                        SELECT
                            person_id
                        FROM
                            clientfact_v2
                        WHERE
                            max_budget >= 100001
                    )
                UNION ALL
                SELECT
                    to_char(rent_start_date, 'yyyy'),
                    client_person_id
                FROM
                    rentfact_v2
                WHERE
                    client_person_id IN (
                        SELECT
                            person_id
                        FROM
                            clientfact_v2
                        WHERE
                            max_budget >= 100001
                    )
                UNION ALL
                SELECT
                    to_char(sale_date, 'yyyy'),
                    client_person_id
                FROM
                    salesfact_v2
                WHERE
                    client_person_id IN (
                        SELECT
                            person_id
                        FROM
                            clientfact_v2
                        WHERE
                            max_budget >= 100001
                    )
            ) data
        GROUP BY
            year
    )
GROUP BY
    year,
    total_count;


------------------------------------------------------------------------------
--Report 9
------------------------------------------------------------------------------ 
--SQL command (Version 1-Level 2):
SELECT
    od.office_name,
    ad.gender,
    SUM("Total Revenue") AS total_revenue,
    to_char(SUM(SUM("Total Revenue")) OVER(PARTITION BY od.office_name
        ORDER BY
            od.office_name, ad.gender
        ROWS UNBOUNDED PRECEDING
    ), '9,999,999,999') AS cumulative_revenue
FROM
    agentrevenuefact_v1  afc,
    agentdim_v1          ad,
    agentofficedim_v1    aod,
    officedim_v1         od
WHERE
        afc.person_id = ad.person_id
    AND ad.person_id = "agent_id"
    AND aod.office_id = od.office_id
    AND od.office_name IN (
        'Ray White Sherwood',
        'Ray White Oakleigh'
    )
GROUP BY
    od.office_name,
    ad.gender;

--SQL command (Version 2-Level 0):
SELECT
    od.office_name,
    ad.gender,
    SUM("Total Revenue") AS total_revenue,
    to_char(SUM(SUM("Total Revenue")) OVER(PARTITION BY od.office_name
        ORDER BY
            od.office_name, ad.gender
        ROWS UNBOUNDED PRECEDING
    ), '9,999,999,999') AS cumulative_revenue
FROM
    agentrevenuefact_v2  afc,
    agentdim_v2          ad,
    agentofficedim_v2    aod,
    officedim_v2         od
WHERE
        afc.person_id = ad.person_id
    AND ad.person_id = aod.agent_id
    AND aod.office_id = od.office_id
    AND od.office_name IN (
        'Ray White Sherwood',
        'Ray White Oakleigh'
    )
GROUP BY
    od.office_name,
    ad.gender;
    
    
------------------------------------------------------------------------------
--Report 10
------------------------------------------------------------------------------ 
--SQL command (Version 1-Level 2):
SELECT
    pd.property_type,
    to_char(sf.sale_date, 'Mon')                         AS month,
    to_char(SUM("Total_Sale"), '9,999,999,999')        AS total_sales_amount,
    to_char(SUM(SUM("Total_Sale")) OVER(PARTITION BY pd.property_type
        ORDER BY
            to_char(sf.sale_date, 'Mon'), pd.property_type
        ROWS UNBOUNDED PRECEDING
    ), '9,999,999,999') AS cum_sales
FROM
    salesfact_v1    sf,
    propertydim_v1  pd
WHERE
        sf.property_id = pd.property_id
    AND to_char(sf.sale_date, 'yyyy') = '2020'
GROUP BY
    pd.property_type,
    to_char(sf.sale_date, 'Mon')
HAVING
    to_char(sf.sale_date, 'Mon') IN (
        'Feb',
        'Mar'
    );

--SQL command (Version 2-Level 0):
SELECT
    pd.property_type,
    to_char(sf.sale_date, 'Mon') AS month,
    to_char(SUM("Total_Sale"), '9,999,999,999') AS total_sales_amount,
    to_char(SUM(SUM("Total_Sale")) OVER(PARTITION BY pd.property_type
        ORDER BY
            to_char(sf.sale_date, 'Mon'), pd.property_type
        ROWS UNBOUNDED PRECEDING
    ), '9,999,999,999') AS cum_sales
FROM
    salesfact_v2    sf,
    propertydim_v2  pd
WHERE
        sf.property_id = pd.property_id
    AND to_char(sf.sale_date, 'yyyy') = '2020'
GROUP BY
    pd.property_type,
    to_char(sf.sale_date, 'Mon')
HAVING
    to_char(sf.sale_date, 'Mon') IN (
        'Feb',
        'Mar'
    );


