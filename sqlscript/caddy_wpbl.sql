explain analyze with
  clog as (select *, unhex(hex(inet_aton(substring_index(remote_addr, ':', 1)))) as ip from caddy_log.logs order by ts desc limit 10)
select * from clog where exists (
  select /*+ NO_MERGE(t) */ 1 from (
    select rangeend from wpbl.wpbl as wpbl force index (by_rangestart) where wpbl.rangestart <= clog.ip
  ) as t where clog.ip <= t.rangeend
) limit 2;
