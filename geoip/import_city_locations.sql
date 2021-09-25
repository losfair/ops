create table geoip_city_locations (
  geoname_id int not null,
  locale_code varchar(16) not null,
  continent_code char(2) not null,
  continent_name varchar(50) not null,
  country_iso_code char(2) not null,
  country_name varchar(100) not null,
  subdivision_1_iso_code varchar(10) not null,
  subdivision_1_name varchar(100) not null,
  subdivision_2_iso_code varchar(10) not null,
  subdivision_2_name varchar(100) not null,
  city_name varchar(100) not null,
  metro_code varchar(50) not null,
  time_zone varchar(50) not null,
  is_in_european_union tinyint not null,
  primary key (geoname_id, locale_code)
);

load data local infile '../GeoLite2-City-CSV_20210914/GeoLite2-City-Locations-zh-CN.csv'
into table geoip_city_locations
fields terminated by ',' enclosed by '"' lines terminated by '\n' ignore 1 rows
(@geoname_id, @locale_code, @continent_code, @continent_name, @country_iso_code, @country_name,
  @subdivision_1_iso_code, @subdivision_1_name,
  @subdivision_2_iso_code, @subdivision_2_name,
  @city_name, @metro_code, @time_zone, @is_in_european_union
)
set geoname_id = @geoname_id,
    locale_code = @locale_code,
    continent_code = @continent_code,
    continent_name = @continent_name,
    country_iso_code = @country_iso_code,
    country_name = @country_name,
    subdivision_1_iso_code = @subdivision_1_iso_code,
    subdivision_1_name = @subdivision_1_name,
    subdivision_2_iso_code = @subdivision_2_iso_code,
    subdivision_2_name = @subdivision_2_name,
    city_name = @city_name,
    metro_code = @metro_code,
    time_zone = @time_zone,
    is_in_european_union = @is_in_european_union;