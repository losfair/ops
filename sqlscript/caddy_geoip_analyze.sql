with
  ipt as (select ts, host, substring_index(remote_addr, ':', 1) as ip from logs),
  unique_ipt as (
    select max(ip) as ip, max(ts) as ts, count(*) as cnt,
            group_concat(distinct host separator ',') as hosts
      from ipt group by ipt.ip
  ),
  ipgeo as (select ts, ip, cnt, hosts, geoip.query_city_geoname_id_by_ipv4(ip) as geoid from unique_ipt)
  select ipgeo.ip, ipgeo.ts, ipgeo.cnt, ipgeo.hosts, loc.country_name, loc.city_name from ipgeo
    left join geoip.geoip_city_locations as loc on loc.geoname_id = ipgeo.geoid
    where loc.locale_code = 'zh-CN'
    order by ipgeo.ts asc;
