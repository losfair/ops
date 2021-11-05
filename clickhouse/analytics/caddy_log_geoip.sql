select
  ts, remote_addr, uri, method, status, size,
  loc.country_name, loc.subdivision_1_name, loc.subdivision_2_name, loc.city_name
  from logstream_requests as req
  left any join geoip.city_locations as loc on loc.geoname_id = dictGetUInt32(
    'geoip_city_blocks_ipv4',
    'geoname_id',
    tuple(IPv4StringToNum(splitByChar(':', req.remote_addr)[1]))
  )
  where host = 'your_host'
    and ts >= toDateTime64(date_sub(day, 1, now()), 0)
  order by ts desc
  limit 10;
