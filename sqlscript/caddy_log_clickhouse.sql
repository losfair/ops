create table `logstream_queue` (
  `raw` String
)
engine = Kafka()
settings
  kafka_broker_list = '10.147.17.6:9093',
  kafka_topic_list = 'net.univalent.caddy-log.app,net.univalent.caddy-log.lab,net.univalent.caddy-log.invariant-cn',
  kafka_group_name = 'net.univalent.lab.clickhouse',
  kafka_format = 'LineAsString';

create table `logstream_rawdata`  (
  `ts` DateTime64(3),
  `raw` String
)
engine = MergeTree()
order by `ts`
partition by toYYYYMMDD(ts);

create materialized view `logstream_rawdata_consumer` to `logstream_rawdata` as
  select fromUnixTimestamp64Milli(toInt64(JSONExtractFloat(`raw`, 'ts') * 1000)) as ts, `raw` from `logstream_queue`;

create table logstream_requests (
  `ts` DateTime64(3),
  `duration` Float64,
  `user_id` String,
  `status` UInt16,
  `size` UInt64,
  `remote_addr` String,
  `proto` String,
  `method` String,
  `host` String,
  `uri` String,
  `req_headers` Array(Tuple(String, Array(String))),
  `resp_headers` Array(Tuple(String, Array(String)))
)
engine = MergeTree()
order by `ts`
partition by toYYYYMMDD(ts);

create materialized view logstream_requests_consumer to logstream_requests as
  select
    fromUnixTimestamp64Milli(toInt64(JSONExtractFloat(raw, 'ts') * 1000)) as ts,
    JSONExtractFloat(raw, 'duration') as duration,
    JSONExtractString(raw, 'user_id') as user_id,
    JSONExtractInt(raw, 'status') as `status`,
    JSONExtractInt(raw, 'size') as `size`,
    JSONExtractString(raw, 'request', 'proto') as proto,
    JSONExtractString(raw, 'request', 'remote_addr') as remote_addr,
    JSONExtractString(raw, 'request', 'method') as method,
    JSONExtractString(raw, 'request', 'host') as host,
    JSONExtractString(raw, 'request', 'uri') as uri,
    arrayMap(x ->
      tuple(
        tupleElement(x, 1),
        JSONExtract(tupleElement(x, 2), 'Array(String)')
      ),
      JSONExtractKeysAndValuesRaw(raw, 'request', 'headers')
    ) as req_headers,
    arrayMap(x ->
      tuple(
        tupleElement(x, 1),
        JSONExtract(tupleElement(x, 2), 'Array(String)')
      ),
      JSONExtractKeysAndValuesRaw(raw, 'resp_headers')
    ) as resp_headers
    from logstream_queue \
    where JSONExtractString(raw, 'msg') = 'handled request';

create view logstream_requestinfo as
  select
    ts, duration, user_id, status, size,
    splitByChar(':', remote_addr)[1] as ip,
    proto, method, host, uri,
    tupleElement(arrayFirst(x -> tupleElement(x, 1) = 'User-Agent', req_headers), 2)[1] as ua,
    tupleElement(arrayFirst(x -> tupleElement(x, 1) = 'Referer', req_headers), 2)[1] as referrer,
    tupleElement(arrayFirst(x -> tupleElement(x, 1) = 'Origin', req_headers), 2)[1] as origin,
    tupleElement(arrayFirst(x -> tupleElement(x, 1) = 'X-Blueboat-Request-Id', resp_headers), 2)[1] as blueboat_reqid,
    loc.country_name, loc.subdivision_1_name, loc.subdivision_2_name, loc.city_name
  from logstream_requests as req
  left any join geoip.city_locations as loc on loc.geoname_id = dictGetUInt32(
    'geoip_city_blocks_ipv4',
    'geoname_id',
    tuple(IPv4StringToNum(ip))
  );
