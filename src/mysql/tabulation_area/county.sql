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

use tabulation_area;

# change the data type for intptlon to a numeric type
alter table county
    add column intptlon_dec decimal(10, 7);

update county set intptlon_dec = cast(intptlon as decimal(10, 7));

alter table county
    drop column intptlon;

alter table county
    rename column intptlon_dec to intptlon;

alter table county
    modify column intptlon decimal(10, 7) not null;

alter table county
    add column intptlat_dec decimal(11, 7);

update county set intptlat_dec = cast(intptlat as decimal(11, 7));

alter table county
    drop column intptlat;

alter table county
    rename column intptlat_dec to intptlat;

alter table county
    modify intptlat decimal(11, 7) not null;

alter table county
    modify shape multipolygon not null srid 4269;

alter table county
    modify statefp varchar(2) not null;

alter table county
    modify geoid varchar(5) not null;

alter table county
    modify countyfp varchar(3) not null;

alter table county
    modify name varchar(100) not null;

alter table county
    modify mtfcc varchar(5) not null;

alter table county
    modify funcstat varchar(1) not null;

-- drop the csafp column
alter table county
    drop column csafp;

-- drop the cbsafp column
alter table county
    drop column cbsafp;

-- add an index to the statefp column
create index county_statefp_idx
    ON county (statefp);

-- add an index to the countyfp column
create index county_countyfp_idx
    ON county (countyfp);

-- add a unique index to the geoid column
create unique index county_geoid_idx
    ON county (geoid);

-- spatial index to the spape geometry column
create spatial index county_shape_geom_idx
    ON county (shape);