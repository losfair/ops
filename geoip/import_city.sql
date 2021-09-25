create table geoip_city_ipv4 (
  network varchar(100) not null,
  network_start binary(4) not null,
  network_end binary(4) not null,
  geoname_id int not null,
  latitude float not null,
  longitude float not null,
  accuracy_radius int not null
);

load data local infile '../GeoLite2-City-CSV_20210914/GeoLite2-City-Blocks-IPv4.csv'
into table geoip_city_ipv4
fields terminated by ',' enclosed by '"' lines terminated by '\n' ignore 1 rows
(@network, @geoname_id, @registered_country_geoname_id, @represented_country_geoname_id,
  @is_anonymous_proxy, @is_satellite_provider, @postal_code, @latitude, @longitude, @accuracy_radius)
set network = @network,
    network_start = unhex(hex(INET_ATON( SUBSTRING_INDEX(@network, '/', 1))
                   & 0xffffffff ^ ((0x1 << ( 32 - SUBSTRING_INDEX(@network, '/', -1))  ) -1 ))),
    network_end = unhex(hex(INET_ATON( SUBSTRING_INDEX(@network, '/', 1))
                   | ((0x100000000 >> SUBSTRING_INDEX(@network, '/', -1) ) -1 ))),
    geoname_id = @geoname_id,
    latitude = @latitude,
    longitude = @longitude,
    accuracy_radius = @accuracy_radius;

create unique index by_network_start on geoip_city_ipv4 (network_start);
