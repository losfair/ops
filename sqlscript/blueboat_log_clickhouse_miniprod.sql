use blueboat_analytics;

create table logstream_queue_2
(
  `raw` String
)
ENGINE = Kafka
SETTINGS
  kafka_broker_list = 'redpanda.core.svc.cluster.local:9092',
  kafka_topic_list = 'net.univalent.usw-miniprod.blueboat-log.default',
  kafka_group_name = 'net.univalent.usw-miniprod.clickhouse',
  kafka_format = 'RawBLOB';

create materialized view `logstream_data_consumer_2` to `logstream_data` as
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
  from logstream_queue_2;
