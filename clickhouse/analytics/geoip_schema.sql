create table geoip.city_locations (
  geoname_id UInt32,
  locale_code String,
  continent_code String,
  continent_name String,
  country_iso_code String,
  country_name String,
  subdivision_1_iso_code String,
  subdivision_1_name String,
  subdivision_2_iso_code String,
  subdivision_2_name String,
  city_name String,
  metro_code String,
  time_zone String,
  is_in_european_union Boolean
)
engine = Join(any, left, geoname_id);
