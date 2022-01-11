use blueboat_syslog;

create table `inbound_2` (
  `raw` String
)
engine = Kafka()
settings
  kafka_broker_list = 'redpanda.core.svc.cluster.local:9092',
  kafka_topic_list = 'net.univalent.usw-miniprod.blueboat-log.sys',
  kafka_group_name = 'net.univalent.usw-miniprod.clickhouse',
  kafka_format = 'RawBLOB';

create table `logs`  (
  `host` String,
  `pid` Int32,
  `tid` String,
  `ts` DateTime64(6),
  `name` String,
  `target` String,
  `level` String,
  `module_path` String,
  `file` String,
  `line` Int32,
  `fields` Map(String, String),
  `span_id` String
)
engine = MergeTree()
order by `ts`
partition by toYYYYMM(ts);

create materialized view `logs_consumer_2` to `logs` as
select
  JSONExtract(raw, 'host', 'String') as host,
  JSONExtract(raw, 'pid', 'Int32') as pid,
  JSONExtract(raw, 'tid', 'String') as tid,
  fromUnixTimestamp64Micro(cast(JSONExtract(raw, 'ts', 'Float64') * 1000000 as Int64)) as ts,
  JSONExtract(raw, 'name', 'String') as name,
  JSONExtract(raw, 'target', 'String') as target,
  JSONExtract(raw, 'level', 'String') as level,
  JSONExtract(raw, 'module_path', 'String') as module_path,
  JSONExtract(raw, 'file', 'String') as file,
  JSONExtract(raw, 'line', 'Int32') as line,
  cast(JSONExtractKeysAndValues(raw, 'fields', 'String'), 'Map(String, String)') as fields,
  JSONExtract(raw, 'span_id', 'String') as span_id
  from inbound_2;
