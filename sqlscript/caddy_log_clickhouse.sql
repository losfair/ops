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
  `ts` DateTime,
  `raw` String
)
engine = MergeTree()
order by `ts`;

create materialized view `logstream_rawdata_consumer` to `logstream_rawdata` as
  select fromUnixTimestamp64Milli(toInt64(JSONExtractFloat(`raw`, 'ts') * 1000)) as ts, `raw` from `logstream_queue`;
