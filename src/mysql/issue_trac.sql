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

# Select database
USE issue_trac;

# Drop Tables
drop table if exists issue_comment cascade;
drop table if exists issue_media cascade;
drop table if exists issue cascade;
drop table if exists category cascade;


# CREATE TABLES
create table if not exists category
(
    id          bigint primary key not null auto_increment,
    geoid       varchar(8)         not null,
    name        varchar(64)        not null,
    description text,
    parent      bigint
);

create table if not exists issue
(
    id          bigint primary key not null auto_increment,
    title       varchar(64)        not null,
    description text,
    category    bigint             not null,
    shape       Point              not null srid 4269,
    geoid       varchar(16)        not null,
    sub         varchar(36)        not null,
    disposition varchar(16)      default 'NEW' not null
);

create table if not exists issue_comment
(
    id      bigint primary key not null auto_increment,
    issue   bigint             not null,
    comment text               not null,
    sub     varchar(36)        not null
);

create table if not exists issue_media
(
    id          bigint primary key not null auto_increment,
    issue       bigint             not null,
    mime_type   varchar(16)        not null,
    image       longblob           not null,
    sub         varchar(36)        not null
);

# CREATE INDEX & CONSTRAINTS

create index category_geoid_idx
    on category (geoid);

create index issue_sub_idx
    on issue (sub);

create index issue_disposition_idx
    on issue(disposition);

create index issue_comment_sub_idx
    on issue_comment (sub);

create index issue_media_sub_idx
    on issue_media (sub);

create spatial index category_shape_spx on issue (shape);

alter table category
    add constraint category_parent_fkey
    foreign key (parent) references category (id);

alter table issue
    add constraint issue_category_fkey
    foreign key (category) references category (id);

alter table issue_comment
    add constraint issue_comment_issue_fkey
    foreign key (issue) references issue (id);

alter table issue_media
    add constraint issue_media_issue_fkey
    foreign key (issue) references issue (id);
