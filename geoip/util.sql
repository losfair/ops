-- List functions and procedures, show function/procedure code
show function status where db = database();
show procedure status where db = database();
show create function query_city_geoname_id_by_ipv4;

-- Query location by IP.
-- A trivial `where geoname_id = query_city_geoname_id_by_ipv4(...)` did a full table scan when I
-- tested, and is slow.
select * from geoip_city_locations as t1
  inner join (select query_city_geoname_id_by_ipv4("8.8.8.8") as id) as t2 on t1.geoname_id = t2.id;
