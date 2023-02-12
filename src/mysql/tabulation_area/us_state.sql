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

alter table us_state
    add column intptlon_dec decimal(10, 7);

update us_state set intptlon_dec = cast(intptlon as decimal(10, 7));

alter table us_state
    drop column intptlon;

alter table us_state
    rename column intptlon_dec to intptlon;

alter table us_state
    modify intptlon decimal(10, 7) not null;

alter table us_state
    add column intptlat_dec decimal(10, 7);

update us_state set intptlat_dec = cast(intptlat as decimal(11, 7));

alter table us_state
    drop column intptlat;

alter table us_state
    rename column intptlat_dec to intptlat;

alter table us_state
    modify intptlat decimal(11, 7) not null;

alter table us_state
    modify shape multipolygon not null srid 4269;

alter table us_state
    modify statefp varchar(2) not null;

alter table us_state
    modify geoid varchar(2) not null;

alter table us_state
    modify region varchar(2) not null;

alter table us_state
    modify name varchar(100) not null;

alter table us_state
    modify mtfcc varchar(5) not null;

alter table us_state
    modify funcstat varchar(1) not null;

create index us_state_statefp_idx
    on us_state(statefp);

create unique index us_state_geoid_idx
    on us_state(geoid);

create spatial index us_state_shape_geom_idx
    on us_state(shape);