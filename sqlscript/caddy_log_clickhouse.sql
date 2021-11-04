create table `logstream_queue` (
  `raw` String
)
engine = Kafka()
settings
  kafka_broker_list = '100.99.11.35:9093',
  kafka_topic_list = 'net.univalent.caddy-log.app,net.univalent.caddy-log.lab',
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
