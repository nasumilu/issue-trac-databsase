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

# Switch to database
USE feature_server;

# DROP TABLES
drop table if exists attribute cascade;
drop table if exists feature_class cascade;
drop table if exists service cascade;
drop table if exists datasource cascade;

# CREATE TABLES
create table if not exists service
(
    id          bigint primary key not null auto_increment,
    name        varchar(64)        not null,
    title       varchar(64),
    description text
);

create table if not exists datasource
(
    id       bigint primary key                                                                                                       not null auto_increment,
    name     varchar(64)                                                                                                              not null,
    comment  text,
    dbname   varchar(64)                                                                                                              not null,
    username varchar(64)                                                                                                              not null,
    password varchar(255)                                                                                                             not null, # must encrypt password (no plain-text)
    host     varchar(128)                                                                                                             not null,
    port     integer                                                                                                                  not null,
    driver   enum ('pdo_mysql', 'mysqli', 'pdo_pgsql', 'pdo_sqlsrv', 'sqlsrv', 'pdo_oci', 'oci8', 'ibm_db2', 'pdo_sqlite', 'sqlite3') not null
);

create table if not exists feature_class
(
    id           bigint primary key not null auto_increment,
    service      bigint             not null,
    datasource   bigint             not null,
    name         varchar(64)        not null,
    title        varchar(64)        not null,
    description  text,
    nspace       varchar(64)        not null,
    srid         integer            not null,
    extent       varchar(100)       not null,
    is_published boolean default true
);

create table if not exists attribute
(
    id            bigint primary key                                       not null auto_increment,
    feature_class bigint                                                   not null,
    name          varchar(64)                                              not null,
    type          enum ('number', 'string', 'boolean', 'date', 'geometry') not null,
    label         varchar(64),
    is_geometry   boolean default false,
    is_published  boolean default true
);

#CREATE INDEX & CONSTRAINTS
create unique index datasource_unique_name_idx
    on datasource (name);

create unique index service_unique_name_idx
    on service (name);

create unique index feature_class_unique_nspace_name_idx
    on feature_class (nspace, name);

create unique index attribute_feature_class_unique_name_idx
    on attribute (feature_class, name);

alter table feature_class
    add constraint feature_class_datasource_fkey
        foreign key (datasource) references datasource (id);

alter table feature_class
    add constraint feature_class_service_fkey
        foreign key (service) references service (id);

alter table attribute
    add constraint attribute_feature_class_fkey
        foreign key (feature_class) references feature_class (id);
