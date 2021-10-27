with
  ipt as (
    select ts, host, substring_index(remote_addr, ':', 1) as ip
    from logs
    where ts > date_sub(current_timestamp(6), interval 1 day)
  ),
  unique_ipt as (
    select max(ip) as ip, max(ts) as ts, count(*) as cnt,
            group_concat(distinct host separator ',') as hosts
      from ipt group by ipt.ip
  ),
  ipgeo as (select ts, ip, cnt, hosts, geoip.query_city_geoname_id_by_ipv4(ip) as geoid from unique_ipt)
  select /*+ NO_MERGE(ipgeo) */ ipgeo.ip, ipgeo.ts, ipgeo.cnt, ipgeo.hosts, iploc.country_name, iploc.city_name from ipgeo
    left join geoip.geoip_city_locations as iploc on iploc.geoname_id = ipgeo.geoid and iploc.locale_code = 'zh-CN'
    order by ipgeo.ts asc;
