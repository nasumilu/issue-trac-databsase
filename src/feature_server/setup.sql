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

drop table if exists feature_class cascade;
drop table if exists attribute cascade;
drop table if exists us_state cascade;
drop table if exists county cascade;
drop table if exists place cascade;
drop type feature_attribute_type cascade;

----------------------------------------------------------

------------------------ TYPES ---------------------------

create type feature_attribute_type as enum ('number', 'string', 'boolean', 'date');

----------------------------------------------------------

------------------------ CREATE TABLES -------------------
create table if not exists feature_class
(
    id           bigserial primary key not null,
    name         character varying(64) not null,
    nspace       character varying(64) not null,
    srid         integer               not null,
    extent       box2d                 not null,
    is_published boolean default true
);

create table if not exists  attribute
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

create unique index if not exists feature_class_unique_nspace_name_idx
    on feature_class (nspace, name);

create unique index if not exists attribute_feature_class_unique_name_idx
    on attribute (feature_class, name);

alter table if exists feature_class
    add constraint feautre_class_srid_fkey
        foreign key (srid) references spatial_ref_sys (srid);

alter table if exists attribute
    add constraint attribute_feature_class_fkey
        foreign key (feature_class) references feature_class (id);

----------------------------------------------------------
