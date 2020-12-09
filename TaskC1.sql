drop table address cascade constraints;
create table address as select * from monre.address;

drop table advertisement cascade constraints;
create table advertisement as select distinct * from monre.advertisement;

drop table agent_office cascade constraints;
create table agent_office as select distinct * from monre.agent_office;

drop table client_wish cascade constraints;
create table client_wish as select distinct * from monre.client_wish;

drop table feature cascade constraints;
create table feature as select distinct * from monre.feature;
delete from feature where feature_code=726;

drop table office cascade constraints;
create table office as select distinct * from monre.office;

drop table person cascade constraints;
create table person as select distinct * from monre.person;
--null value in person
delete from person where person_id=7001;

drop table client cascade constraints;
create table client as select * from monre.client;
delete from client where min_budget<0 or max_budget<0;
delete from client where min_budget>max_budget;
delete from client where person_id not in (select person_id from person);

drop table agent cascade constraints;
create table agent as select distinct * from monre.agent;
delete from agent where salary<0;
delete from agent where person_id not in (select person_id from person);

drop table postcode cascade constraints;
create table postcode as select distinct * from monre.postcode;

drop table property cascade constraints;
create table property as select distinct * from monre.property;

drop table property_advert cascade constraints;
create table property_advert as select * from monre.property_advert;

drop table property_feature cascade constraints;
create table property_feature as select * from monre.property_feature;

drop table rent cascade constraints;
create table rent as select * from monre.rent;
delete from rent where rent_start_date>rent_end_date;

drop table sale cascade constraints;
create table sale as select * from monre.sale;

drop table state cascade constraints;
create table state as select * from monre.state;
delete from state where state_name='Unknown';

drop table visit cascade constraints;
create table visit as select * from monre.visit;

--cleaning agent_id and client_id from other tables
delete from rent where agent_person_id not in (select person_id from agent);
delete from visit where agent_person_id not in (select person_id from agent);
delete from sale where agent_person_id not in (select person_id from agent);
delete from agent_office where person_id not in (select person_id from agent);
delete from property_advert where agent_person_id not in (select person_id from agent);

delete from client_wish where person_id not in (select person_id from client);
delete from rent where client_person_id not in (select person_id from client);
delete from sale where client_person_id not in (select person_id from client);
delete from visit where client_person_id not in (select person_id from client);
delete from client_wish where feature_code not in (select feature_code from feature);