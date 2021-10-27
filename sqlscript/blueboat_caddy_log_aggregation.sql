with
  applog as (
    select * from rwv2.applog where apppath = "managed/gh_6104981/net.univalent.id/metadata.json" order by logtime desc limit 5, 1
  )
select * from applog left join caddy_log.logs as clog on applog.reqid = json_value(clog.resp_headers, '$."X-Blueboat-Request-Id"[0]');
