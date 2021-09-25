delimiter //
create function query_city_geoname_id_by_ipv4 (ipv4 varchar(100))
returns int
reads sql data
begin
  return (select geoname_id from (
    select * from geoip_city_ipv4
      where network_start <= unhex(hex(inet_aton(ipv4)))
      order by network_start desc limit 1
  ) as t1 where t1.network_end >= unhex(hex(inet_aton(ipv4))));
end //
delimiter ;
