------------------------------------------------------------------------------
--Report 1
------------------------------------------------------------------------------
--SQL Query (Version 1-Level 2):
SELECT
    *
FROM
    (
        SELECT
            t.month,
            pd.state_code,
            SUM("Number of Rent") AS no_of_rent,
            RANK() OVER(
                ORDER BY
                    SUM("Number of Rent") DESC
            )         AS suburb_rank
        FROM
            rentfact_v1     rf,
            locationdim_v1  ld,
            timedim_v1      t,
            postcodedim_v1  pd
        WHERE
                rf.address_id = ld.address_id
            AND t.time_id = "Timeid"
            AND ld.postcode = pd.postcode
            AND t.year = 2020
        GROUP BY
            t.month,
            pd.state_code
        HAVING
            t.month = 'Jan'
    )
WHERE
    suburb_rank <= 3;


--SQL Query (Version 2-Level 0):

SELECT
    *
FROM
    (
        SELECT
            to_char(rf.rent_start_date, 'Mon') AS month,
            pd.state_code,
            SUM("Number of Rent") AS no_of_rent,
            RANK() OVER(
                ORDER BY
                    SUM("Number of Rent") DESC
            )         AS suburb_rank
        FROM
            rentfact_v2     rf,
            locationdim_v2  ld,
            postcodedim_v2  pd
        WHERE
                rf.address_id = ld.address_id
            AND ld.postcode = pd.postcode
            AND to_char(rf.rent_start_date, 'yyyy') = 2020
        GROUP BY
            to_char(rf.rent_start_date, 'Mon'),
            pd.state_code
        HAVING
            to_char(rf.rent_start_date, 'Mon') = 'Jan'
    )
WHERE
    suburb_rank <= 3;
    
-------------------------------------------------------------------------------
--Report 2
--------------------------------------------------------------------------------
--SQL Query (Version 1-Level 2):
  Select *
          from (

        SELECT
            to_char(af.property_date_added,'Mon') as month,
            af.advert_name,
            COUNT("NUMBER_OF_PROPERTIES") AS Total_Properties,
            round(PERCENT_RANK() OVER(PARTITION BY to_char(af.property_date_added,'Mon')
                ORDER BY
                    COUNT("NUMBER_OF_PROPERTIES")
            ),2) AS "Percent_Rank"
            
        FROM
            advertisementfact_v1     af,
            propertydim_v1   pd,
            advertdim_v1 ad
        WHERE
                af.property_id = pd.property_id
                and 
                af.advert_name = ad.advert_name
            
        GROUP BY
           to_char(af.property_date_added,'Mon'),
           af.advert_name
           )
           where "Percent_Rank" > 0.5;

--SQL Query (Version 2-Level 0):

 Select *
          from (

        SELECT
            to_char(af.property_date_added,'Mon') as month,
            af.advert_name,
            COUNT("NUMBER_OF_PROPERTIES") AS Total_Properties,
            round(PERCENT_RANK() OVER(PARTITION BY to_char(af.property_date_added,'Mon')
                ORDER BY
                    COUNT("NUMBER_OF_PROPERTIES")
            ),2) AS "Percent_Rank"
            
        FROM
            advertisementfact_v2     af,
            propertydim_v2   pd,
            advertdim_v2 ad
        WHERE
                af.property_id = pd.property_id
                and 
                af.advert_name = ad.advert_name
            
        GROUP BY
           to_char(af.property_date_added,'Mon'),
           af.advert_name
           )
           where "Percent_Rank" > 0.5;
    
    
------------------------------------------------------------------------------
--Report 3
------------------------------------------------------------------------------
--SQL Query (Version 1-Level 2):
SELECT
    od.office_name,
    ad.gender,
    SUM("TOTAL_AGENTS") AS total_agents,
    DENSE_RANK() OVER(
        ORDER BY
            SUM("TOTAL_AGENTS") DESC
    )         AS rank
FROM
    agentfact_v1       afc,
    agentdim_v1        ad,
    agentofficedim_v1  aod,
    officedim_v1       od
WHERE
        afc.agent_person_id = ad.person_id
    AND ad.person_id = "agent_id"
    AND aod.office_id = od.office_id
GROUP BY
    od.office_name,
    ad.gender
HAVING od.office_name LIKE 'Ray%'
       AND ad.gender = 'Female';


--SQL Query (Version 2-Level 0):
SELECT
    od.office_name,
    ad.gender,
    SUM("TOTAL_AGENTS") AS total_agents,
    DENSE_RANK() OVER(
        ORDER BY
            SUM("TOTAL_AGENTS") DESC
    )         AS rank
FROM
    agentfact_v2       afc,
    agentdim_v2        ad,
    agentofficedim_v2  aod,
    officedim_v2       od
WHERE
        afc.agent_person_id = ad.person_id
    AND ad.person_id = aod.agent_id
    AND aod.office_id = od.office_id
GROUP BY
    od.office_name,
    ad.gender
HAVING od.office_name LIKE 'Ray%'
       AND ad.gender = 'Female';
    
           
    
           

