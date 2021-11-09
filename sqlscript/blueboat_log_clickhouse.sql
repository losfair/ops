use blueboat_analytics;

create table `logstream_queue` (
  `raw` String
)
engine = Kafka()
settings
  kafka_broker_list = '10.147.17.6:9093',
  kafka_topic_list = 'net.univalent.blueboat-log.default',
  kafka_group_name = 'net.univalent.lab.clickhouse',
  kafka_format = 'RawBLOB';

create table `logstream_queue_lab` (
  `raw` String
)
engine = Kafka()
settings
  kafka_broker_list = 'kafkasvc.default.svc.cluster.local:9092',
  kafka_topic_list = 'net.univalent.blueboat-log.default',
  kafka_group_name = 'net.univalent.lab.clickhouse',
  kafka_format = 'RawBLOB';

create table `logstream_data`  (
  `ts` DateTime64(3),
  `apppath` String,
  `appversion` String,
  `request_id` String,
  `message` String,
  `logseq` UInt32
)
engine = MergeTree()
order by `ts`
partition by toYYYYMMDD(ts);

create table `logstream_data_lab`  (
  `ts` DateTime64(3),
  `apppath` String,
  `appversion` String,
  `request_id` String,
  `message` String,
  `logseq` UInt32
)
engine = MergeTree()
order by `ts`
partition by toYYYYMMDD(ts);

create materialized view `logstream_data_consumer` to `logstream_data` as
select
  JSONExtract(raw, 'time', 'Array(Int64)') as raw_time,
  fromUnixTimestamp64Milli(cast(
    dateAdd(second, raw_time[3],
      dateAdd(day, raw_time[2] - 1,
        toDate(concat(toString(raw_time[1]), '-01-01'))
      )
    ) as Int64
  ) * 1000 + intDiv(raw_time[4], 1000000)) as ts,
  JSONExtract(raw, 'app', 'path', 'String') as apppath,
  JSONExtract(raw, 'app', 'version', 'String') as appversion,
  JSONExtract(raw, 'request_id', 'String') as request_id,
  JSONExtract(raw, 'message', 'String') as `message`,
  JSONExtract(raw, 'logseq', 'UInt32') as logseq
  from logstream_queue;

create materialized view `logstream_data_lab_consumer` to `logstream_data_lab` as
select
  JSONExtract(raw, 'time', 'Array(Int64)') as raw_time,
  fromUnixTimestamp64Milli(cast(
    dateAdd(second, raw_time[3],
      dateAdd(day, raw_time[2] - 1,
        toDate(concat(toString(raw_time[1]), '-01-01'))
      )
    ) as Int64
  ) * 1000 + intDiv(raw_time[4], 1000000)) as ts,
  JSONExtract(raw, 'app', 'path', 'String') as apppath,
  JSONExtract(raw, 'app', 'version', 'String') as appversion,
  JSONExtract(raw, 'request_id', 'String') as request_id,
  JSONExtract(raw, 'message', 'String') as `message`,
  JSONExtract(raw, 'logseq', 'UInt32') as logseq
  from logstream_queue_lab;
