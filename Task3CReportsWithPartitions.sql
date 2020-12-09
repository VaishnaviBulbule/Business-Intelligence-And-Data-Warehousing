------------------------------------------------------------------------------
--Report 11
------------------------------------------------------------------------------ 
--SQL command (Version 1-Level 2):
SELECT
    to_char(sale_date, 'yyyy')       AS year,
    pd.property_type,
    pc.state_code,
    SUM("Total_Number_Sale")        AS total_sales,
    RANK() OVER(PARTITION BY pd.property_type
        ORDER BY
            SUM("Total_Number_Sale") DESC
    ) AS rank_by_property_type,
    RANK() OVER(PARTITION BY pc.state_code
        ORDER BY
            SUM("Total_Number_Sale") DESC
    ) AS rank_by_state
FROM
    salesfact_v1    sf,
    propertydim_v1  pd,
    locationdim_v1  ld,
    postcodedim_v1  pc
WHERE
        sf.property_id = pd.property_id
    AND sf.address_id = ld.address_id
    AND ld.postcode = pc.postcode
GROUP BY
    to_char(sale_date, 'yyyy'),
    pd.property_type,
    pc.state_code;

--SQL command (Version 2-Level 0):
SELECT
    to_char(sale_date, 'yyyy')       AS year,
    pd.property_type,
    pc.state_code,
    SUM("Total_Number_Sale")        AS total_sales,
    RANK() OVER(PARTITION BY pd.property_type
        ORDER BY
            SUM("Total_Number_Sale") DESC
    ) AS rank_by_property_type,
    RANK() OVER(PARTITION BY pc.state_code
        ORDER BY
            SUM("Total_Number_Sale") DESC
    ) AS rank_by_state
FROM
    salesfact_v2    sf,
    propertydim_v2  pd,
    locationdim_v2  ld,
    postcodedim_v2  pc
WHERE
        sf.property_id = pd.property_id
    AND sf.address_id = ld.address_id
    AND ld.postcode = pc.postcode
GROUP BY
    to_char(sale_date, 'yyyy'),
    pd.property_type,
    pc.state_code;
    

------------------------------------------------------------------------------
--Report 12
------------------------------------------------------------------------------ 
--SQL command (Version 1-Level 2):
SELECT
    to_char("Timeid", 'yyyy') AS year,
    prd.property_type,
    r.property_scale,
    SUM("Total_Rent") AS total_rent,
    RANK() OVER(
        PARTITION BY prd.property_type
        ORDER BY
            SUM("Total_Rent") DESC
    ) AS rank_by_property_type,
    RANK() OVER(
        PARTITION BY r.property_scale
        ORDER BY
            SUM("Total_Rent") DESC
    ) AS rank_by_scale
FROM
    rentfact_v1          r,
    propertyrentdim_v1   prd
WHERE
    r.property_id = prd.property_id
GROUP BY
    to_char("Timeid", 'yyyy'),
    prd.property_type,
    r.property_scale;

--SQL command (Version 2-Level 0):
select to_char(rent_start_date,'yyyy'),
property_type,
(case when property_no_of_bedrooms <=1 then 'EXTRA SMALL'
when property_no_of_bedrooms between 2 and 3 then 'SMALL'
when property_no_of_bedrooms between 3 and 6 then 'MEDIUM'
when property_no_of_bedrooms between 7 and 10 then 'LARGE'
else 'EXTRA LARGE' end) as Property_Scale,
SUM("Total_Rent") AS total_rent,
RANK() OVER(
PARTITION BY property_type
ORDER BY
SUM("Total_Rent") DESC
) AS rank_by_property_type,
RANK() OVER(
PARTITION BY (case when property_no_of_bedrooms <=1 then 'EXTRA SMALL'
when property_no_of_bedrooms between 2 and 3 then 'SMALL'
when property_no_of_bedrooms between 3 and 6 then 'MEDIUM'
when property_no_of_bedrooms between 7 and 10 then 'LARGE'
else 'EXTRA LARGE' end)
ORDER BY
SUM("Total_Rent") DESC
) AS rank_by_scale
FROM
rentfact_v2,
propertyrentdim_v2
WHERE
rentfact_v2.property_id = propertyrentdim_v2.property_id
GROUP BY
to_char(rent_start_date, 'yyyy'),
property_type,
(case when property_no_of_bedrooms <=1 then 'EXTRA SMALL'
when property_no_of_bedrooms between 2 and 3 then 'SMALL'
when property_no_of_bedrooms between 3 and 6 then 'MEDIUM'
when property_no_of_bedrooms between 7 and 10 then 'LARGE'
else 'EXTRA LARGE' end);

