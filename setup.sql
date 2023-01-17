---------------------- EXTENSION -------------------------

create extension if not exists postgis;

----------------------------------------------------------

--------------------- DROP TABLES ------------------------

drop table if exists feature_class cascade;
drop table if exists tabulation_area cascade;
drop table if exists us_state cascade;
drop table if exists county cascade;
drop table if exists incorporated_place cascade;

---------------------- TABLES ----------------------------

create table feature_class
(
    id          varchar(5)   not null primary key,
    name        varchar(100),
    title       varchar(100) not null,
    description text,
    envelope    geometry(MultiPolygon, 4269)
);

create table tabulation_area
(
    id        varchar(16)                  not null primary key,
    name      varchar(100)                 not null,
    funcstat  character                    not null,
    lsad_name varchar(100),
    lsad_code varchar(2)                   not null,
    mtfcc     varchar(5)                   not null,
    shape     geometry(MultiPolygon, 4269) not null
);

create table us_state
(
    id       varchar(2) not null primary key,
    region   varchar(2) not null,
    division varchar(2) not null,
    statefp  varchar(2) not null,
    statens  varchar(8) not null,
    stusps   varchar(2) not null
);

create table county
(
    id       varchar(16) not null primary key,
    statefp  varchar(2)  not null,
    countyfp varchar(3)  not null,
    countyns varchar(8)  not null,
    classfp  varchar(2)  not null,
    csafp    varchar(3),
    cbsafp   varchar(5),
    metdivfp varchar(5)
);

create table incorporated_place
(
    id      varchar(16) not null primary key,
    statefp varchar(2)  not null,
    placefp varchar(5)  not null,
    placens varchar(8)  not null,
    classfp varchar(2)  not null
);

----------------------------------------------------------

------------------- FOREIGN KEYS -------------------------

-- tabulation_area.mtfcc -> feature_class.id foreign key constraint
alter table tabulation_area
    add constraint tabulation_area_mtfcc_feature_class_id_fkey
        foreign key (mtfcc) references feature_class (id);

-- us_state.id -> tabulation_area.id foreign key constraint
alter table us_state
    add constraint us_state_id_tabulation_area_id_fkey
        foreign key (id) references tabulation_area (id);

-- county.id -> tabulation_area.id foreign key constraint
alter table county
    add constraint county_id_tabulation_area_id_fkey
        foreign key (id) references tabulation_area (id);

-- incorporated_place.id -> tabulation_area.id foreign key constraint
alter table incorporated_place
    add constraint incorporated_place_id_tabulation_area_id_fkey
        foreign key (id) references tabulation_area (id);

-------------------------------------------------------------

----------------------- INDEXES -----------------------------

-- feature_class.name unique index
create unique index unique_feature_class_idx on feature_class (name);

-- us_state.statefp index
create index us_state_statefp_idx on us_state (statefp);

-- county.countyfp index
create index county_countyfp_idx on county (countyfp);

-- county.statefp index
create index county_statefp_idx on county (statefp);

-- incorporated_place.placefp index
create index incorporated_place_placefp_idx on incorporated_place (placefp);

-- incorporated_place.statefp index
create index incorporated_place_statefp_idx on incorporated_place (statefp);

------------------------------------------------------------

------------------ SPATIAL INDEXES -------------------------

-- spatial index for tabluation_area.shape using gist
create index tabulation_area_shape_spidx on tabulation_area using gist (shape);

-- spatial index for featre_class.envelope using gist
create index feature_class_envelope_spidx on feature_class using gist (envelope);

------------------------------------------------------------

insert into feature_class (id, name, title, description)
values ('G4020', 'counties', 'Counties or Equivalent',
        'Counties and equivalent entities are primary legal divisions of states. In most states, these entities are termed counties.'),
       ('G4000', 'us_states', 'US States and Equivalent',
        'States and equivalent entities are the primary governmental divisions of the United States. In addition to the fifty states, included are District of Columbia, Puerto Rico, and the Island areas (American Samoa, the Commonwealth of the Northern Mariana Islands, Guam, and the U.S. Virgin Islands) as equivalents of states.'),
       ('G4110', 'incorporated_places', 'Incorporated Places',
        'Incorporated places are those reported which legally in exist under the laws of their respective states. An incorporated place provides governmental functions for a concentration of people. Incorporated places may extend across county and county subdivision boundaries, but never across state boundaries. An incorporated place usually is a city, town, village, or borough, but can have other legal descriptions.');

insert into tabulation_area (id, name, funcstat, lsad_name, lsad_code, mtfcc, shape)
select geoid, name, funcstat, namelsad, lsad, mtfcc, wkb_geometry
from county_staging;

insert into county (id, statefp, countyfp, countyns, classfp, csafp, cbsafp, metdivfp)
select geoid,
       statefp,
       countyfp,
       countyns,
       classfp,
       csafp,
       cbsafp,
       metdivfp
from county_staging;

insert into tabulation_area (id, name, funcstat, lsad_name, lsad_code, mtfcc, shape)
select geoid, name, funcstat, null, lsad, mtfcc, wkb_geometry
from us_state_staging;

insert into us_state (id, region, division, statefp, statens, stusps)
select geoid, region, division, statefp, statens, stusps
from us_state_staging;

insert into tabulation_area (id, name, funcstat, lsad_name, lsad_code, mtfcc, shape)
select geoid, name, funcstat, namelsad, lsad, mtfcc, wkb_geometry
from incorporated_place_staging
WHERE mtfcc = 'G4110';

insert into incorporated_place (id, statefp, placefp, placens, classfp)
select geoid, statefp, placefp, placens, classfp
from incorporated_place_staging
WHERE mtfcc = 'G4110';

update feature_class
set envelope = (select st_collect(array_agg(bbox))
                from (select st_extent(shape)::geometry bbox
                      from tabulation_area ta
                               join us_state us on ta.id = us.id
                      group by region) envelope)
WHERE id = 'G4000';

update feature_class
set envelope = (select st_collect(array_agg(bbox))
                from (select st_extent(shape)::geometry bbox
                      from tabulation_area ta
                               join county c on ta.id = c.id
                               join us_state us on c.statefp = us.statefp
                      group by region) envelope)
WHERE id = 'G4020';

update feature_class
set envelope = (select st_collect(array_agg(bbox))
                from (select st_extent(shape)::geometry bbox
                      from tabulation_area ta
                               join incorporated_place ic on ta.id = ic.id
                               join us_state us on ic.statefp = us.statefp
                      group by region) envelope)
WHERE id = 'G4110';