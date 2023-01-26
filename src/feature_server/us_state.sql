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

-- change the data type for intptlon to a numeric type
alter table if exists us_state
    alter column intptlon type numeric using intptlon::numeric(10, 7);

-- change the data type for intptlat to a numeric type
alter table if exists us_state
    alter column intptlat type numeric using intptlat::numeric(10, 7);

alter table if exists us_state
    alter column shape set not null;

alter table if exists us_state
    alter column statefp set not null;

alter table if exists us_state
    alter column geoid set not null;

alter table if exists us_state
    alter column region set not null;

alter table if exists us_state
    alter column name set not null;

alter table if exists us_state
    alter column mtfcc set not null;

alter table if exists us_state
    alter column funcstat set not null;


-- add an index to the statefp column
create index if not exists us_state_statefp_idx
    on us_state (statefp);

-- add a unique index to the geoid column
create unique index if not exists us_state_geoid_idx
    on us_state (geoid);

-- spatial index to the spape geometry column
create index if not exists us_state_shape_geom_idx
    on us_state using gist (shape);