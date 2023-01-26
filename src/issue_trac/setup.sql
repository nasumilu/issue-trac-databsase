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

drop table if exists category;
drop table if exists issue_comment cascade;
drop table if exists issue_media cascade;
drop type if exists mime_type cascade;
----------------------------------------------------------

----------------- TYPES & DOMAINS ------------------------

create type mime_type as enum ('image/jpeg', 'image/png', 'image/webp');

----------------------------------------------------------

------------------------ CREATE TABLES -------------------
create table if not exists category
(
    id          bigserial primary key not null,
    geoid       character varying(8)  not null,
    name        character varying(64) not null,
    description text,
    parent      bigint
);

create table if not exists issue
(
    id          bigserial primary key not null,
    title       character varying(64) not null,
    description text,
    category    bigint                not null,
    shape       geometry(Point, 4269) not null
);

create table if not exists issue_comment
(
    id      bigserial primary key not null,
    issue   bigint                not null,
    comment text                  not null
);

create table if not exists issue_media
(
    id        bigserial primary key not null,
    issue     bigint                not null,
    mime_type mime_type             not null,
    image     bytea                 not null
);

----------------------------------------------------------

--------------- CREATE INDEX & CONSTRAINTS ---------------

create index if not exists category_geoid_idx
    on category (geoid);

alter table if exists category
    add constraint category_parent_fkey
        foreign key (parent) references category (id);

alter table if exists issue
    add constraint issue_category_fkey
        foreign key (category) references category (id);

alter table if exists issue_comment
    add constraint issue_comment_issue_fkey
        foreign key (issue) references issue (id);

alter table if exists issue_media
    add constraint issue_media_issue_fkey
        foreign key (issue) references issue (id);

------------------- MAINTENANCE -------------------------

vacuum full verbose;

---------------------------------------------------------