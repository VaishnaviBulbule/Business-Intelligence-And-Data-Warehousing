--------------------------------------------------------------------------------
--Star Schema Version 1 (Aggregation)
--------------------------------------------------------------------------------

DROP TABLE rentpricetemporal_v1;

CREATE TABLE rentpricetemporal_v1
    AS
        SELECT DISTINCT
            property_id,
            rent_id,
            rent_start_date,
            rent_end_date,
            price
        FROM
            rent;

DROP TABLE propertyrentdim_v1;

CREATE TABLE propertyrentdim_v1
    AS
        SELECT DISTINCT
            r.property_id,
            p.property_type
        FROM
            rent

R,property p where client_person_id is not null and r.property_id=p.property_id; 

drop table timedim_v1;
CREATE TABLE timedim_v1
    AS
        SELECT DISTINCT
            rent_start_date AS time_id,
            to_char(rent_start_date, 'Mon') AS month,
            to_char(rent_start_date, 'yyyy') AS year
        FROM
            rent
        WHERE
            rent_start_date IS NOT NULL;

drop table temprentfact_v1 cascade constraints;
create table temprentfact_v1 as 
SELECT DISTINCT
    p.property_id,
    p.address_id,
    r.rent_start_date   AS "Timeid",
    COUNT(*) AS "Number of Rent",
    r.price             AS "Total_Rent"
FROM
    property   p,
    rent       r
WHERE
    r.property_id = p.property_id
    AND r.client_person_id IS NOT NULL
GROUP BY
    p.property_id,
    p.address_id,
    r.rent_start_date,
    r.price;

ALTER TABLE temprentfact_v1 ADD period_type NVARCHAR2(20);

UPDATE temprentfact_v1
SET
    period_type = 'Short'
WHERE
    property_id IN (
        SELECT
            p.property_id
        FROM
            temprentfact   p,
            rent           r
        WHERE
            p.property_id = r.property_id
            AND months_between(rent_end_date, rent_start_date) < 6
            AND r.rent_start_date = "Timeid"
    );

UPDATE temprentfact_v1
SET
    period_type = 'Medium'
WHERE
    property_id IN (
        SELECT
            p.property_id
        FROM
            temprentfact   p,
            rent           r
        WHERE
            p.property_id = r.property_id
            AND months_between(rent_end_date, rent_start_date) >= 6
            AND months_between(rent_end_date, rent_start_date) <= 12
            AND r.rent_start_date = "Timeid"
    );

UPDATE temprentfact_v1
SET
    period_type = 'Long'
WHERE
    property_id IN (
        SELECT
            p.property_id
        FROM
            temprentfact   p,
            rent           r
        WHERE
            p.property_id = r.property_id
            AND months_between(rent_end_date, rent_start_date) > 12
            AND r.rent_start_date = "Timeid"
    );
ALTER TABLE temprentfact_v1 ADD property_scale NVARCHAR2(20);

UPDATE temprentfact_v1
SET
    property_scale = 'Extra Small'
WHERE
    property_id IN (
        SELECT
            property_id
        FROM
            property
        WHERE
            property_no_of_bedrooms <= 1
    );

UPDATE temprentfact_v1
SET
    property_scale = 'Small'
WHERE
    property_id IN (
        SELECT
            property_id
        FROM
            property
        WHERE
            property_no_of_bedrooms BETWEEN 2 AND 3
    );

UPDATE temprentfact_v1
SET
    property_scale = 'Medium'
WHERE
    property_id IN (
        SELECT
            property_id
        FROM
            property
        WHERE
            property_no_of_bedrooms BETWEEN 4 AND 6
    );

UPDATE temprentfact_v1
SET
    property_scale = 'Large'
WHERE
    property_id IN (
        SELECT
            property_id
        FROM
            property
        WHERE
            property_no_of_bedrooms BETWEEN 7 AND 10
    );

UPDATE temprentfact_v1
SET
    property_scale = 'Extra Large'
WHERE
    property_id IN (
        SELECT
            property_id
        FROM
            property
        WHERE
            property_no_of_bedrooms >= 11
    );

ALTER TABLE temprentfact_v1 ADD feature_category NVARCHAR2(20);

UPDATE temprentfact_v1
SET
    feature_category = 'Very Basic'
WHERE
    property_id IN (
        SELECT
            property_id
        FROM
            property_feature
        GROUP BY
            property_id
        HAVING
            COUNT(feature_code) BETWEEN 0 AND 10
    );

UPDATE temprentfact_v1
SET
    feature_category = 'Standard'
WHERE
    property_id IN (
        SELECT
            property_id
        FROM
            property_feature
        GROUP BY
            property_id
        HAVING COUNT(feature_code) >= 10
               AND COUNT(feature_code) <= 20
    );

UPDATE temprentfact_v1
SET
    feature_category = 'Luxurious'
WHERE
    property_id IN (
        SELECT
            property_id
        FROM
            property_feature
        GROUP BY
            property_id
        HAVING
            COUNT(feature_code) > 20
    );

UPDATE temprentfact_v1
SET
    feature_category = 'Very Basic'
WHERE
    feature_category IS NULL;

DROP TABLE rentfact_v1;
create table rentfact_v1 as select * from temprentfact_v1;

DROP TABLE propertyfeaturecategorydim_v1 CASCADE CONSTRAINTS;

CREATE TABLE propertyfeaturecategorydim_v1 (
    feature_category     VARCHAR2(20),
    feature_low_range    NUMBER(2),
    feature_high_range   NUMBER(5)
);

INSERT INTO propertyfeaturecategorydim_v1 VALUES (
    'Very Basic',
    0,
    9
);

INSERT INTO propertyfeaturecategorydim_v1 VALUES (
    'Standard',
    10,
    20
);

INSERT INTO propertyfeaturecategorydim_v1 VALUES (
    'Luxurious',
    21,
    99999
);

DROP TABLE propertyscaledim_v1 CASCADE CONSTRAINTS;

CREATE TABLE propertyscaledim_v1 (
    property_scale     VARCHAR2(20),
    scale_low_range    NUMBER(2),
    scale_high_range   NUMBER(2)
);

INSERT INTO propertyscaledim_v1 VALUES (
    'Extra Small',
    0,
    1
);

INSERT INTO propertyscaledim_v1 VALUES (
    'Small',
    2,
    3
);

INSERT INTO propertyscaledim_v1 VALUES (
    'Medium',
    4,
    6
);

INSERT INTO propertyscaledim_v1 VALUES (
    'Large',
    7,
    10
);

INSERT INTO propertyscaledim_v1 VALUES (
    'Extra large',
    11,
    99
);
DROP TABLE rentalperioddim_v1 CASCADE CONSTRAINTS;

CREATE TABLE rentalperioddim_v1 (
    period_type         VARCHAR2(20),
    period_low_range    NUMBER(2),
    period_high_range   NUMBER(5)
);

INSERT INTO rentalperioddim_v1 VALUES (
    'Short',
    0,
    5
);

INSERT INTO rentalperioddim_v1 VALUES (
    'Medium',
    6,
    12
);

INSERT INTO rentalperioddim_v1 VALUES (
    'Long',
    13,
    99999
);

DROP TABLE seasondim_v1 CASCADE CONSTRAINTS;

CREATE TABLE seasondim_v1 (
    season        VARCHAR2(20),
    begin_month   VARCHAR(20),
    end_month     VARCHAR2(20)
);

INSERT INTO seasondim_v1 VALUES (
    'Summer',
    12,
    02
);

INSERT INTO seasondim_v1 VALUES (
    'Autum',
    03,
    05
);

INSERT INTO seasondim_v1 VALUES (
    'Winter',
    06,
    08
);

INSERT INTO seasondim_v1 VALUES (
    'Spring',
    09,
    11
);
DROP TABLE visitdatedim_v1 CASCADE CONSTRAINTS;

CREATE TABLE visitdatedim_v1
    AS
        SELECT DISTINCT
            visit_date,
            to_char(visit_date, 'DY') AS "Day",
            to_char(visit_date, 'Mon') AS "Month",
            to_char(visit_date, 'yyyy') AS "Year"
        FROM
            visit;

DROP TABLE visittempfact_v1;

CREATE TABLE visittempfact_v1
    AS
        SELECT
            property_id,
            visit_date
        FROM
            visit;

ALTER TABLE visittempfact_v1 ADD season VARCHAR2(20);

UPDATE visittempfact_v1
SET
    season = 'Summer'
WHERE
    to_char(visit_date, 'MM') IN (
        12,
        1,
        2
    );

UPDATE visittempfact_v1
SET
    season = 'Autumn'
WHERE
    to_char(visit_date, 'MM') IN (
        3,
        4,
        5
    );

UPDATE visittempfact_v1
SET
    season = 'Winter'
WHERE
    to_char(visit_date, 'MM') IN (
        6,
        7,
        8
    );

UPDATE visittempfact_v1
SET
    season = 'Spring'
WHERE
    to_char(visit_date, 'MM') IN (
        9,
        10,
        11
    );

DROP TABLE visitfact_v1;

CREATE TABLE visitfact_v1
    AS
        SELECT
            property_id,
            visit_date,
            season,
            COUNT(*) AS "Number of Visits"
        FROM
            visittempfact_v1
        GROUP BY
            property_id,
            visit_date,
            season;

DROP TABLE advertisementfact_v1;

CREATE TABLE advertisementfact_v1
    AS
        SELECT DISTINCT
            p.property_id,
            a.advert_name,
            p.property_date_added,
            COUNT(p.property_id) AS number_of_properties
        FROM
            property          p,
            advertisement     a,
            property_advert   pa
        WHERE
            p.property_id = pa.property_id
            AND a.advert_id = pa.advert_id
        GROUP BY
            p.property_id,
            a.advert_name,
            p.property_date_added;

DROP TABLE advertdim_v1;

CREATE TABLE advertdim_v1
    AS
        SELECT DISTINCT
            advert_name
        FROM
            advertisement;

DROP TABLE propertydim_v1;

CREATE TABLE propertydim_v1
    AS
        SELECT DISTINCT
            p.property_id,
            p.property_type,
            p.address_id,
            round(1 / COUNT(*), 2) AS weight_factor,
            LISTAGG(pf.feature_code, '_') WITHIN GROUP(
                ORDER BY
                    pf.feature_code
            ) AS featuregrouplist
        FROM
            property           p
            LEFT JOIN property_feature   pf
            ON p.property_id = pf.property_id
        GROUP BY
            p.property_id,
            p.property_type,
            p.address_id;

DROP TABLE propertyfeaturebridge_v1;

CREATE TABLE propertyfeaturebridge_v1
    AS
        SELECT
            *
        FROM
            property_feature;

DROP TABLE featuredim_v1 CASCADE CONSTRAINTS;

CREATE TABLE featuredim_v1
    AS
        SELECT
            *
        FROM
            feature;

DROP TABLE client_wishlist_dimtemp_v1;

CREATE TABLE client_wishlist_dimtemp_v1
    AS
        SELECT
            person_id,
            LISTAGG(feature_code, '_') WITHIN GROUP(
                ORDER BY
                    feature_code
            ) AS feature_group_list,
            round(1.0 / COUNT(feature_code), 2) AS weight_factor
        FROM
            client_wish
        GROUP BY
            person_id;

DROP TABLE clientwishdim_v1;

CREATE TABLE clientwishdim_v1
    AS
        SELECT DISTINCT
            feature_group_list
        FROM
            client_wishlist_dimtemp_v1;

DROP TABLE tempclientfact_v1;

CREATE TABLE tempclientfact_v1
    AS
        SELECT DISTINCT
            c.person_id,
            max_budget,
            LISTAGG(feature_code, '_') WITHIN GROUP(
                ORDER BY
                    feature_code
            ) AS feature_group_list,
            COUNT(DISTINCT c.person_id) AS "Total_Clients"
        FROM
            client        c
            LEFT JOIN client_wish   w
            ON c.person_id = w.person_id
        GROUP BY
            c.person_id,
            max_budget;

ALTER TABLE tempclientfact_v1 ADD budget_type NVARCHAR2(20);

UPDATE tempclientfact_v1
SET
    budget_type = 'Low'
WHERE
    max_budget BETWEEN 0 AND 1000;

UPDATE tempclientfact_v1
SET
    budget_type = 'Medium'
WHERE
    max_budget BETWEEN 1001 AND 100000;

UPDATE tempclientfact_v1
SET
    budget_type = 'High'
WHERE
    max_budget BETWEEN 100001 AND 10000000;

DROP TABLE clientfact_v1;

CREATE TABLE clientfact_v1
    AS
        SELECT
            budget_type,
            feature_group_list,
            SUM("Total_Clients") AS "Total_Clients"
        FROM
            tempclientfact_v1
        GROUP BY
            budget_type,
            feature_group_list;

DROP TABLE clientbudgetdim_v1 CASCADE CONSTRAINTS;

CREATE TABLE clientbudgetdim_v1 (
    budget_type   VARCHAR2(20),
    low_range     NUMBER(10),
    high_range    NUMBER(10)
);

INSERT INTO clientbudgetdim_v1 VALUES (
    'Low',
    0,
    1000
);

INSERT INTO clientbudgetdim_v1 VALUES (
    'Medium',
    1001,
    100000
);

INSERT INTO clientbudgetdim_v1 VALUES (
    'High',
    100001,
    10000000
);

DROP TABLE tempsalesfact_v1;

CREATE TABLE tempsalesfact_v1
    AS
        SELECT
            s.price AS "Total_Sale",
            s.property_id,
            p.address_id,
            COUNT(sale_id) AS "Total_Number_Sale",
            s.sale_date
        FROM
            sale       s,
            property   p
        WHERE
            s.property_id = p.property_id
            AND client_person_id IS NOT NULL
        GROUP BY
            s.price,
            s.property_id,
            p.address_id,
            s.sale_date;

ALTER TABLE tempsalesfact_v1 ADD season VARCHAR2(20);

UPDATE tempsalesfact_v1
SET
    season = 'Summer'
WHERE
    to_char(sale_date, 'MM') IN (
        12,
        1,
        2
    );

UPDATE tempsalesfact_v1
SET
    season = 'Autumn'
WHERE
    to_char(sale_date, 'MM') IN (
        3,
        4,
        5
    );

UPDATE tempsalesfact_v1
SET
    season = 'Winter'
WHERE
    to_char(sale_date, 'MM') IN (
        6,
        7,
        8
    );

UPDATE tempsalesfact_v1
SET
    season = 'Spring'
WHERE
    to_char(sale_date, 'MM') IN (
        9,
        10,
        11
    );

DROP TABLE salesfact_v1;

CREATE TABLE salesfact_v1
    AS
        SELECT
            *
        FROM
            tempsalesfact_v1;

DROP TABLE locationdim_v1 CASCADE CONSTRAINTS;

CREATE TABLE locationdim_v1
    AS
        SELECT DISTINCT
            address_id,
            postcode,
            suburb
        FROM
            address;

DROP TABLE postcodedim_v1 CASCADE CONSTRAINTS;

CREATE TABLE postcodedim_v1
    AS
        SELECT DISTINCT
            p.postcode,
            p.state_code
        FROM
            postcode

p;

DROP TABLE agentfact_v1;

CREATE TABLE agentfact_v1
    AS
        SELECT DISTINCT
            a.person_id   AS agent_person_id,
            salary        AS earning,
            COUNT(a.person_id) AS total_agents
        FROM
            agent    a,
            person   p
        WHERE
            a.person_id = p.person_id
        GROUP BY
            a.person_id,
            salary;

DROP TABLE agentrevenuefact_v1;

CREATE TABLE agentrevenuefact_v1
    AS
        SELECT
            at.person_id,
            a.property_id,
            nvl(SUM(a.price), 0) AS "Total Revenue"
        FROM
            agent at
            LEFT JOIN (
                SELECT
                    r.agent_person_id,
                    r.property_id,
                    round(SUM(r.price *((r.rent_end_date - r.rent_start_date) / 7
                    )), 2) AS price
                FROM
                    rent       r,
                    property   p
                WHERE
                    r.property_id = p.property_id
                    AND r.client_person_id IS NOT NULL
                GROUP BY
                    r.agent_person_id,
                    r.property_id
                UNION
                SELECT
                    s.agent_person_id,
                    s.property_id,
                    SUM(s.price) AS price
                FROM
                    sale       s,
                    property   p
                WHERE
                    s.property_id = p.property_id
                    AND s.client_person_id IS NOT NULL
                GROUP BY
                    s.agent_person_id,
                    s.property_id
            ) a
            ON a.agent_person_id = at.person_id
        GROUP BY
            at.person_id,
            property_id;

DROP TABLE agentdim_v1 CASCADE CONSTRAINTS;

CREATE TABLE agentdim_v1
    AS
        SELECT DISTINCT
            a.person_id,
            p.gender,
            a.salary,
            round(1 / COUNT(*), 2) AS weight_factor,
            LISTAGG(ao.office_id, '_') WITHIN GROUP(
                ORDER BY
                    ao.office_id
            ) AS officegrouplist
        FROM
            agent

A
left

JOIN person p
ON a.person_id = p.person_id
LEFT JOIN agent_office ao
ON ao.person_id = p.person_id group BY a.person_id,
                                       p.gender,
                                       a.salary;

DROP TABLE agentofficebridge_v1 CASCADE CONSTRAINTS;

CREATE TABLE agentofficebridge_v1
    AS
        SELECT DISTINCT
            person_id AS "agent_id",
            office_id
        FROM
            agent_office;

DROP TABLE officedim_v1 CASCADE CONSTRAINTS;

CREATE TABLE officedim_v1
    AS
        SELECT
            o.office_id,
            o.office_name,
            COUNT(DISTINCT ao.person_id) AS "count"
        FROM
            office         o
            LEFT JOIN agent_office   ao
            ON o.office_id = ao.office_id
        GROUP BY
            o.office_id,
            o.office_name
        ORDER BY
            "count";

ALTER TABLE officedim_v1 ADD office_size VARCHAR2(10);

UPDATE officedim_v1
SET
    office_size = 'Small'
WHERE
    "count" BETWEEN 0 AND 3;

UPDATE officedim_v1
SET
    office_size = 'Medium'
WHERE
    "count" BETWEEN 4 AND 12;

UPDATE officedim_v1
SET
    office_size = 'Big'
WHERE
    "count" BETWEEN 13 AND 999999;

ALTER TABLE officedim_v1 DROP COLUMN "count";

DROP TABLE officesizedim_v1 CASCADE CONSTRAINTS;

CREATE TABLE officesizedim_v1 (
    office_size   VARCHAR2(10),
    beginning     NUMBER(2),
    ending        NUMBER(6),
    PRIMARY KEY ( office_size )
);

INSERT INTO officesizedim_v1 VALUES (
    'Small',
    0,
    3
);

INSERT INTO officesizedim_v1 VALUES (
    'Medium',
    4,
    12
);

INSERT INTO officesizedim_v1 VALUES (
    'Big',
    13,
    999999
);

DROP TABLE tempclientvisit_v1;

CREATE TABLE tempclientvisit_v1
    AS
        SELECT
            client_person_id,
            visit_date,
            to_char(visit_date, 'yyyy') AS time_id,
            max_budget
        FROM
            visit    v,
            client   c
        WHERE
            v.client_person_id = c.person_id;

ALTER TABLE tempclientvisit_v1 ADD budget_type NVARCHAR2(20);

UPDATE tempclientvisit
SET
    budget_type = 'Low'
WHERE
    max_budget BETWEEN 0 AND 1000;

UPDATE tempclientvisit_v1
SET
    budget_type = 'Medium'
WHERE
    max_budget BETWEEN 1001 AND 100000;

UPDATE tempclientvisit_v1
SET
    budget_type = 'High'
WHERE
    max_budget BETWEEN 100001 AND 10000000;

DROP TABLE tempclientrent_v1;

CREATE TABLE tempclientrent_v1
    AS
        SELECT
            client_person_id,
            rent_start_date,
            to_char(rent_start_date, 'yyyy') AS time_id,
            max_budget
        FROM
            rent

R,client c where r.client_person_id=c.person_id;
ALTER TABLE tempclientrent_v1 ADD budget_type NVARCHAR2(20);

UPDATE tempclientrent_v1
SET
    budget_type = 'Low'
WHERE
    max_budget BETWEEN 0 AND 1000;

UPDATE tempclientrent_v1
SET
    budget_type = 'Medium'
WHERE
    max_budget BETWEEN 1001 AND 100000;

UPDATE tempclientrent_v1
SET
    budget_type = 'High'
WHERE
    max_budget BETWEEN 100001 AND 10000000;

DROP TABLE tempclientsale_v1;
CREATE TABLE tempclientsale_v1
    AS
        SELECT
            client_person_id,
            sale_date,
            to_char(sale_date, 'yyyy') AS time_id,
            max_budget
        FROM
            sale     s,
            client   c
        WHERE
            s.client_person_id = c.person_id;

ALTER TABLE tempclientsale_v1 ADD budget_type NVARCHAR2(20);

UPDATE tempclientsale_v1
SET
    budget_type = 'Low'
WHERE
    max_budget BETWEEN 0 AND 1000;

UPDATE tempclientsale_v1
SET
    budget_type = 'Medium'
WHERE
    max_budget BETWEEN 1001 AND 100000;

UPDATE tempclientsale_v1
SET
    budget_type = 'High'
WHERE
    max_budget BETWEEN 100001 AND 10000000;

drop table clienttimetempfact_v1;
CREATE TABLE clienttimetempfact_v1
    AS
        SELECT
            client_person_id,
            visit_date,
            NULL AS rent_start_date,
            NULL AS sale_date,
            time_id,
            budget_type
        FROM
            tempclientvisit_v1
        UNION
        SELECT
            client_person_id,
            NULL,
            rent_start_date,
            NULL,
            time_id,
            budget_type
        FROM
            tempclientrent_v1
        UNION
        SELECT
            client_person_id,
            NULL,
            NULL,
            sale_date,
            time_id,
            budget_type
        FROM
            tempclientsale_v1;

DROP TABLE clientallyearsfact_v1;

CREATE TABLE clientallyearsfact_v1
    AS
        SELECT
            budget_type,
            time_id,
            COUNT(visit_date) AS total_visit_clients,
            COUNT(rent_start_date) AS total_rent_clients,
            COUNT(sale_date) AS total_sale_clients
        FROM
            clienttimetempfact_v1
        GROUP BY
            budget_type,
            time_id;

DROP TABLE tempalltimedim_v1;

CREATE TABLE tempalltimedim_v1
    AS
        SELECT
            TRIM(to_char(visit_date, 'Mon-yyyy')) AS time_id,
            visit_date
        FROM
            tempclientvisit_v1
        UNION
        SELECT
            TRIM(to_char(rent_start_date, 'Mon-yyyy')) AS time_id,
            rent_start_date
        FROM
            tempclientrent_v1
        UNION
        SELECT
            TRIM(to_char(sale_date, 'Mon-yyyy')) AS time_id,
            sale_date
        FROM
            tempclientsale_v1;

DROP TABLE alltimedim_v1;

CREATE TABLE alltimedim_v1
    AS
        SELECT DISTINCT
            to_char(visit_date, 'yyyy') AS time_id
        FROM
            tempalltimedim_v1;
            
            
------------------------------------------------------------------------------     
--Star Schema Version 2 (0 level)
------------------------------------------------------------------------------
DROP TABLE rentpricetemporal_v2;

CREATE TABLE rentpricetemporal_v2
    AS
        SELECT
            property_id,
            rent_id,
            rent_start_date,
            rent_end_date,
            price
        FROM
            rent;

DROP TABLE propertyrentdim_v2;

CREATE TABLE propertyrentdim_v2
    AS
        SELECT DISTINCT
            r.property_id,
            p.property_type
        FROM
            rent

R,property p where client_person_id is not null and r.property_id=p.property_id; 

DROP TABLE bedrooms_count_v2;

CREATE TABLE bedrooms_count_v2
    AS
        SELECT DISTINCT
            property_no_of_bedrooms AS no_of_bedrooms
        FROM
            property p,
            rent

R

WHERE
    p.property_id = r.property_id;

DROP TABLE feature_count_v2;

CREATE TABLE feature_count_v2
    AS
        SELECT DISTINCT
            COUNT(feature_code) AS no_of_features
        FROM
            property           p,
            property_feature   f
        WHERE
            p.property_id = f.property_id
        GROUP BY
            f.property_id;

DROP TABLE rentfact_v2;

CREATE TABLE rentfact_v2
    AS
        SELECT
            r.rent_start_date,
            r.rent_end_date,
            p.property_id,
            p.property_no_of_bedrooms,
            p.address_id,
            r.price AS "Total_Rent",
            r.agent_person_id,
            r.client_person_id,
            COUNT(*) AS "Number of Rent"
        FROM
            property p,
            rent

R

WHERE
   p.property_id = r.property_id
AND r.client_person_id IS NOT NULL
GROUP BY
    r.rent_start_date,
    r.rent_end_date,
    p.property_id,
    p.property_no_of_bedrooms,
    p.address_id,
    r.price,
    r.agent_person_id,
    r.client_person_id;
ALTER TABLE rentfact_v2 ADD no_of_features NUMBER(2);
update rentfact_v2
r

SET no_of_features = nvl((
    SELECT
        COUNT(feature_code)
    FROM
        property_feature f
    WHERE
        r.property_id = f.property_id
    GROUP BY
        f.property_id
), 0);

DROP TABLE visitdatedim_v2 CASCADE CONSTRAINTS;

CREATE TABLE visitdatedim_v2
    AS
        SELECT DISTINCT
            visit_date,
            to_char(visit_date, 'DY') AS "Day",
            to_char(visit_date, 'Mon') AS "Month",
            to_char(visit_date, 'yyyy') AS "Year"
        FROM
            visit;

DROP TABLE visittimedim_v2 CASCADE CONSTRAINTS;

CREATE TABLE visittimedim_v2
    AS
        SELECT DISTINCT
            to_char(visit_date, 'hh24:mi') AS visittimeid,
            to_char(visit_date, 'hh24') AS hours,
            to_char(visit_date, 'mi') AS minutes
        FROM
            visit;

DROP TABLE advertisementfact_v2;

CREATE TABLE advertisementfact_v2
    AS
        SELECT DISTINCT
            p.property_id,
            a.advert_name,
            p.property_date_added,
            COUNT(p.property_id) AS number_of_properties
        FROM
            property          p,
            advertisement     a,
            property_advert   pa
        WHERE
            p.property_id = pa.property_id
            AND a.advert_id = pa.advert_id
        GROUP BY
            p.property_id,
            a.advert_name,
            p.property_date_added;

DROP TABLE advertdim_v2;

CREATE TABLE advertdim_v2
    AS
        SELECT DISTINCT
            advert_name
        FROM
            advertisement;

DROP TABLE propertydim_v2;

CREATE TABLE propertydim_v2
    AS
        SELECT DISTINCT
            p.property_id,
            p.property_type,
            p.address_id,
            round(1 / COUNT(*), 2) AS weight_factor,
            LISTAGG(pf.feature_code, '_') WITHIN GROUP(
                ORDER BY
                    pf.feature_code
            ) AS featuregrouplist
        FROM
            property           p
            LEFT JOIN property_feature   pf
            ON p.property_id = pf.property_id
        GROUP BY
            p.property_id,
            p.property_type,
            p.address_id;

DROP TABLE propertyfeaturebridge_v2 CASCADE CONSTRAINTS;

CREATE TABLE propertyfeaturebridge_v2
    AS
        SELECT
            *
        FROM
            property_feature;
DROP TABLE featuredim_v2 CASCADE CONSTRAINTS;

CREATE TABLE featuredim_v2
    AS
        SELECT
            *
        FROM
            feature;

DROP TABLE visitfact_v2;

CREATE TABLE visitfact_v2
    AS
        SELECT
            property_id,
            visit_date,
            client_person_id,
            agent_person_id,
            to_char(visit_date, 'hh24:mi') AS visittimeid,
            COUNT(property_id) AS "Number of Visits"
        FROM
            visit
        GROUP BY
            property_id,
            visit_date,
            client_person_id,
            agent_person_id,
            to_char(visit_date, 'hh24:mi');

DROP TABLE clientwishbridge_v2 CASCADE CONSTRAINTS;

CREATE TABLE clientwishbridge_v2
    AS
        SELECT
            *
        FROM
            client_wish;

DROP TABLE clientfact_v2;

CREATE TABLE clientfact_v2
    AS
        SELECT DISTINCT
            person_id,
            max_budget,
            COUNT(person_id) AS "Total_Clients"
        FROM
            client
        GROUP BY
            person_id,
            max_budget;

DROP TABLE clientbudgetdim_v2;

CREATE TABLE clientbudgetdim_v2
    AS
        SELECT DISTINCT
            max_budget
        FROM
            client;

DROP TABLE agentdim_v2 CASCADE CONSTRAINTS;

CREATE TABLE agentdim_v2
    AS
        SELECT DISTINCT
            a.person_id,
            p.gender,
            a.salary,
            round(1 / COUNT(*), 2) AS weight_factor,
            LISTAGG(ao.office_id, '_') WITHIN GROUP(
                ORDER BY
                    ao.office_id
            ) AS officegrouplist
        FROM
            agent

A
left

JOIN person p
ON a.person_id = p.person_id left join agent_office ao on ao.person_id = p.person_id group by a.person_id,p.gender,a.salary;

DROP TABLE agentofficebridge_v2 CASCADE CONSTRAINTS;

CREATE TABLE agentofficebridge_v2
    AS
        SELECT
            person_id AS agent_id,
            office_id
        FROM
            agent_office;

DROP TABLE officedim_v2 CASCADE CONSTRAINTS;

CREATE TABLE officedim_v2
    AS
        SELECT
            o.office_id,
            o.office_name,
            COUNT(DISTINCT ao.person_id) AS no_of_employees
        FROM
            office         o
            LEFT JOIN agent_office   ao
            ON o.office_id = ao.office_id
        GROUP BY
            o.office_id,
            o.office_name
        ORDER BY
            COUNT(DISTINCT ao.person_id);

drop table agentrevenuefact_v2;
CREATE TABLE agentrevenuefact_v2
    AS
        SELECT
            at.person_id,
            a.property_id,
            nvl(SUM(a.price), 0) AS "Total Revenue"
        FROM
            agent at
            LEFT JOIN (
                SELECT
                    r.agent_person_id,
                    r.property_id,
                    round(SUM(r.price *((r.rent_end_date - r.rent_start_date) / 7
                    )), 2) AS price
                FROM
                    rent       r,
                    property   p
                WHERE
                    r.property_id = p.property_id
                    AND r.client_person_id IS NOT NULL
                GROUP BY
                    r.agent_person_id,
                    r.property_id
                UNION
                SELECT
                    s.agent_person_id,
                    s.property_id,
                    SUM(s.price) AS price
                FROM
                    sale       s,
                    property   p
                WHERE
                    s.property_id = p.property_id
                    AND s.client_person_id IS NOT NULL
                GROUP BY
                    s.agent_person_id,
                    s.property_id
            ) a
            ON a.agent_person_id = at.person_id
        GROUP BY
            at.person_id,
            property_id;

DROP TABLE agentfact_v2;

CREATE TABLE agentfact_v2
    AS
        SELECT DISTINCT
            a.person_id   AS agent_person_id,
            salary        AS earning,
            COUNT(a.person_id) AS total_agents
        FROM
            agent    a,
            person   p
        WHERE
            a.person_id = p.person_id
        GROUP BY
            a.person_id,
            salary;

drop table client_v2;
create table client_v2 as select distinct person_id from client;

drop table locationdim_v2 cascade constraints;
create table locationdim_v2 as select DISTINCT
    address_id,
    postcode,
    suburb, street FROM
address;

DROP TABLE postcodedim_v2 CASCADE CONSTRAINTS;

CREATE TABLE postcodedim_v2
    AS
        SELECT DISTINCT
            p.postcode,
            p.state_code
        FROM
            postcode p;

DROP TABLE salesfact_v2;

CREATE TABLE salesfact_v2
    AS
        SELECT
            s.price AS "Total_Sale",
            s.property_id,
            p.address_id,
            s.sale_date,
            COUNT(sale_id) AS "Total_Number_Sale",
            client_person_id,
            agent_person_id
        FROM
            sale       s,
            property   p
        WHERE
            s.property_id = p.property_id
            AND client_person_id IS NOT NULL
        GROUP BY
            s.price,
            s.property_id,
            p.address_id,
            s.sale_date,
            client_person_id,
            agent_person_id;