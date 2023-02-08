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

# Drop Tables
drop table if exists category;
drop table if exists issue_comment cascade;
drop table if exists issue_media cascade;


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
    shape       Point              not null srid 4269
);

create table if not exists issue_comment
(
    id      bigint primary key not null auto_increment,
    issue   bigint             not null,
    comment text               not null
);

create table if not exists issue_media
(
    id        bigint primary key                             not null auto_increment,
    issue     bigint                                         not null,
    mime_type enum ('image/jpeg', 'image/png', 'image/webp') not null,
    image     longblob                                       not null
);

# CREATE INDEX & CONSTRAINTS

create index category_geoid_idx
    on category (geoid);

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
