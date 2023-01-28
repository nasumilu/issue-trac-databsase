/*
    Copyright 2023 Michael Lucas

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

---------------------- EXTENSION -------------------------

create extension if not exists postgis;

----------------------------------------------------------

--------------------- DROP TABLES ------------------------
drop table if exists service cascade;
drop table if exists datasource cascade;
drop table if exists feature_class cascade;
drop table if exists attribute cascade;
drop domain if exists email cascade;
drop domain if exists postal_code cascade;
drop type if exists feature_attribute_type cascade;
drop type if exists driver cascade;

----------------------------------------------------------

----------------- TYPES & DOMAINS ------------------------

create type feature_attribute_type as enum ('number', 'string', 'boolean', 'date');
create type driver as enum ('pdo_mysql', 'mysqli', 'pdo_pgsql', 'pdo_sqlsrv', 'pdo_sqlite', 'sqlite3');
create domain email AS text
    check ( value ~
            '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );
create domain postal_code as character varying(10)
    check (value ~ '\d{5}([ \-]\d{4})?');
----------------------------------------------------------

------------------------ CREATE TABLES -------------------
create table if not exists service
(
    id          bigserial primary key not null,
    name        character varying(64) not null,
    address1    character varying(100),
    address2    character varying(100),
    city        character varying(64),
    region      character varying(64),
    postal_code postal_code,
    email       email
);

create table if not exists datasource
(
    id       bigserial primary key  not null,
    dbname   character varying(64)  not null,
    username     character varying(64)  not null,
    password character varying(255) not null, -- must encrypt password (no plain-text)
    host     character varying(128) not null,
    driver   driver                 not null
    -- need to add ssl configuration
);

create table if not exists feature_class
(
    id           bigserial primary key not null,
    service      bigint                not null,
    datasource   bigint                not null,
    name         character varying(64) not null,
    title        character varying(64) not null,
    description  text,
    nspace       character varying(64) not null,
    srid         integer               not null,
    extent       box2d                 not null,
    is_published boolean default true
);

create table if not exists attribute
(
    id            bigserial primary key  not null,
    feature_class bigint                 not null,
    name          character varying(64)  not null,
    type          feature_attribute_type not null,
    label         character varying(64),
    is_geometry   boolean default false,
    is_published  boolean default true
);

----------------------------------------------------------

--------------- CREATE INDEX & CONSTRAINTS ---------------

create unique index if not exists service_unique_name_idx
    on service (name);

create unique index if not exists feature_class_unique_nspace_name_idx
    on feature_class (nspace, name);

create unique index if not exists attribute_feature_class_unique_name_idx
    on attribute (feature_class, name);

alter table if exists feature_class
    add constraint feature_class_datasource_fkey
        foreign key (datasource) references datasource (id);

alter table if exists feature_class
    add constraint feature_class_service_fkey
        foreign key (service) references service (id);

alter table if exists feature_class
    add constraint feautre_class_srid_fkey
        foreign key (srid) references spatial_ref_sys (srid);

alter table if exists attribute
    add constraint attribute_feature_class_fkey
        foreign key (feature_class) references feature_class (id);

----------------------------------------------------------

------------------- MAINTENANCE -------------------------

vacuum full verbose;

---------------------------------------------------------
