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
ALTER TABLE IF EXISTS place
    ALTER COLUMN intptlon TYPE numeric USING intptlon::numeric(10, 7);

-- change the data type for intptlat to a numeric type
ALTER TABLE IF EXISTS place
    ALTER COLUMN intptlat TYPE numeric USING intptlat::numeric(10, 7);

ALTER TABLE IF EXISTS place
    DROP COLUMN IF EXISTS pcicbsa;

ALTER TABLE IF EXISTS place
    DROP COLUMN IF EXISTS pcinecta;

-- add an index to the statefp column
CREATE INDEX IF NOT EXISTS place_statefp_idx
    ON place (statefp);

-- add an index to the countyfp column
CREATE INDEX IF NOT EXISTS place_countyfp_idx
    ON place (placefp);

-- add a unique index to the geoid column
CREATE UNIQUE INDEX IF NOT EXISTS place_geoid_idx
    ON place (geoid);

-- spatial index to the spape geometry column
CREATE INDEX IF NOT EXISTS place_shape_geom_idx
    ON place USING gist (shape);