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

alter table place
    add column intptlon_dec decimal(11, 7);

update place set intptlon_dec = cast(intptlon as decimal(11, 7));

alter table place
    drop column intptlon;

alter table place
    rename column intptlon_dec to intptlon;

alter table place
    modify intptlon decimal(11, 7) not null;

alter table place
    add column intptlat_dec decimal(11, 7);

update place set intptlat_dec = cast(intptlat as decimal(11, 7));

alter table place
    drop column intptlat;

alter table place
    rename column intptlat_dec to intptlat;

alter table place
    modify intptlat decimal(11,7) not null;

alter table place
    drop column pcicbsa;

alter table place
    drop column pcinecta;

alter table place
    modify shape multipolygon not null srid 4269;

alter table place
    modify statefp varchar(2) not null;

alter table place
    alter column geoid set not null;

alter table place
    alter column placefp set not null;

alter table place
    modify name varchar(100) not null;

alter table place
    modify mtfcc varchar(5) not null;

alter table place
    modify funcstat varchar(1) not null;

-- add an index to the statefp column
create index place_statefp_idx
    ON place (statefp);

-- add an index to the countyfp column
create index place_countyfp_idx
    ON place (placefp);

-- add a unique index to the geoid column
create unique index place_geoid_idx
    ON place (geoid);

-- spatial index to the spape geometry column
create spatial index place_shape_geom_idx
    ON place (shape);