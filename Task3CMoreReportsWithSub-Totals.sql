------------------------------------------------------------------------------
--Report 4
------------------------------------------------------------------------------
--SQL command (Version 1-Level 2):
--Cube
SELECT
    decode(GROUPING(suburb), 1, 'All Suburbs', suburb) AS suburb,
    decode(GROUPING(r.period_type), 1, 'All time periods', r.period_type) AS timeperiod,
    decode(GROUPING(pr.property_type), 1, 'All property types', pr.property_type)
    AS propertytype,
    SUM("Total_Rent") as Total_Rent
FROM
    rentfact_v1          r,
    locationdim_v1       l,
    propertyrentdim_v1   pr
WHERE
    r.address_id = l.address_id
    AND r.property_id = pr.property_id
GROUP BY
    CUBE(suburb,
         period_type,
         pr.property_type);
         
--SQL command (Version 2-Level 0):
SELECT
    decode(GROUPING(ad.suburb), 1, 'All Suburbs', ad.suburb) AS suburb,
    decode(GROUPING(round(months_between(rent_end_date, rent_start_date), 1)), 1,
    'All time periods',
           CASE
               WHEN round((months_between(rent_end_date, rent_start_date)), 1) < 6             THEN
                   'SHORT'
               WHEN round((months_between(rent_end_date, rent_start_date)), 1) BETWEEN
               6 AND 12 THEN
                   'MEDIUM'
               ELSE
                   'LONG'
           END
    ) AS start_time_period,
    decode(GROUPING(pd.property_type), 1, 'All Property Types', pd.property_type)
    AS property_type,
    SUM(rf."Total_Rent") AS total_rent
FROM
    rentfact_v2          rf,
    locationdim_v2       ad,
    propertyrentdim_v2   pd
WHERE
    rf.property_id = pd.property_id
    AND rf.address_id = ad.address_id
GROUP BY
    CUBE(ad.suburb,
         round(months_between(rent_end_date, rent_start_date), 1),
         pd.property_type);
         
     
------------------------------------------------------------------------------
--Report 5
------------------------------------------------------------------------------
--Partial Cube
--SQL command (Version 1-Level 2):
SELECT
    decode(GROUPING(suburb), 1, 'All Suburbs', suburb) AS suburb,
    decode(GROUPING(r.period_type), 1, 'All time periods', r.period_type) AS timeperiod
    ,
    decode(GROUPING(pr.property_type), 1, 'All property types', pr.property_type)
    AS propertytype,
    SUM("Total_Rent") AS total_rent
FROM
    rentfact_v1          r,
    locationdim_v1       l,
    propertyrentdim_v1   pr
WHERE
    r.address_id = l.address_id
    AND r.property_id = pr.property_id
GROUP BY suburb,
    CUBE(
         period_type,
         pr.property_type);
         
         
--SQL command (Version 2-Level 0):
SELECT
    decode(GROUPING(ad.suburb), 1, 'All Suburbs', ad.suburb) AS suburb,
    decode(GROUPING(round(months_between(rent_end_date, rent_start_date), 1)), 1,
    'All time periods',
           CASE
               WHEN round((months_between(rent_end_date, rent_start_date)), 1) < 6  THEN
                   'SHORT'
               WHEN round((months_between(rent_end_date, rent_start_date)), 1) BETWEEN
               6 AND 12 THEN
                   'MEDIUM'
               ELSE
                   'LONG'
           END
    ) AS start_time_period,
    decode(GROUPING(pd.property_type), 1, 'All Property Types', pd.property_type)
    AS property_type,
    SUM(rf."Total_Rent") AS total_rent
FROM
    rentfact_v2          rf,
    locationdim_v2       ad,
    propertyrentdim_v2   pd
WHERE
    rf.property_id = pd.property_id
    AND rf.address_id = ad.address_id
GROUP BY ad.suburb,
    CUBE(
         round(months_between(rent_end_date, rent_start_date), 1),
         pd.property_type);
         
         
------------------------------------------------------------------------------
--Report 6
------------------------------------------------------------------------------         
--SQL command (Version 1-Level 2):

SELECT
    decode(GROUPING(p.property_type), 1, 'All property types', p.property_type) AS
    propertytype,
    decode(GROUPING(po.state_code), 1, 'All states', po.state_code) AS State,
    SUM("Total_Sale") as Total_Sale
FROM
    salesfact_v1   s,
    propertydim_v1   p, locationdim_v1 l,postcodedim_v1 po
WHERE
    s.property_id = p.property_id and s.address_id=l.address_id and l.postcode=po.postcode
GROUP BY
    ROLLUP(p.property_type,
           po.state_code);
           
           
--SQL command (Version 2-Level 0):           
SELECT
    decode(GROUPING(p.property_type), 1, 'All property types', p.property_type) AS
    propertytype,
    decode(GROUPING(po.state_code), 1, 'All states', po.state_code) AS state,
    SUM("Total_Sale") AS total_sale
FROM
    salesfact_v2     s,
    propertydim_v2   p,
    locationdim_v2   l,
    postcodedim_v2   po
WHERE
    s.property_id = p.property_id
    AND s.address_id = l.address_id
    AND l.postcode = po.postcode
GROUP BY
    ROLLUP(p.property_type,
           po.state_code);
           
           
------------------------------------------------------------------------------
--Report 7
------------------------------------------------------------------------------         
--Partial Roll-up
--SQL command (Version 1-Level 2):
 SELECT
    decode(GROUPING(p.property_type), 1, 'All property types', p.property_type) AS
    propertytype,
    decode(GROUPING(po.state_code), 1, 'All states', po.state_code) AS State,
    SUM("Total_Sale") as Total_Sale
FROM
    salesfact_v1   s,
    propertydim_v1   p, locationdim_v1 l,postcodedim_v1 po
WHERE
    s.property_id = p.property_id and s.address_id=l.address_id and l.postcode=po.postcode
GROUP BY p.property_type,
    ROLLUP(
           po.state_code);

--SQL command (Version 2-Level 0):  
SELECT
    decode(GROUPING(p.property_type), 1, 'All property types', p.property_type) AS
    propertytype,
    decode(GROUPING(po.state_code), 1, 'All states', po.state_code) AS state,
    SUM("Total_Sale") AS total_sale
FROM
    salesfact_v2     s,
    propertydim_v2   p,
    locationdim_v2   l,
    postcodedim_v2   po
WHERE
    s.property_id = p.property_id
    AND s.address_id = l.address_id
    AND l.postcode = po.postcode
GROUP BY p.property_type,
    ROLLUP(
           po.state_code);
         









