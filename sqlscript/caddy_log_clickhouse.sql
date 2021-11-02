CREATE TABLE `logs` (
  `file_id` String,
  `line_no` Int32,
  `ts` DateTime,
  `user_id` String,
  `duration` Float64,
  `size` UInt64,
  `status_code` UInt16,
  `resp_headers` String,
  `remote_addr` String,
  `proto` String,
  `method` String,
  `host` String,
  `uri` String,
  `req_headers` String,
  `analytics_blueboat_request_id` String
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMMDD(ts)
ORDER BY (file_id, line_no);
