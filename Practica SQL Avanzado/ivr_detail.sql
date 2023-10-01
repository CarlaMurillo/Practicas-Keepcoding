CREATE OR REPLACE TABLE keepcoding.ivr_detail AS
SELECT CAST(c.ivr_id AS STRING) AS ivr_id
  , c.phone_number
  , c.ivr_result
  , c.vdn_label
  , c.start_date
  , CAST(start_date AS DATE) AS start_date_id
  , c.end_date
  , CAST(end_date AS DATE) AS end_date_id
  , c.total_duration
  , c.customer_segment
  , c.ivr_language
  , c.steps_module
  , c.module_aggregation
  , m.module_sequece
  , m.module_name
  , m.module_duration
  , m.module_result
  , s.step_sequence
  , s.step_name
  , s.step_result
  , s.step_description_error
  , s.document_type
  , s.document_identification
  , s.customer_phone
  , s.billing_account_id

 FROM keepcoding.calls AS c
 LEFT 
 JOIN keepcoding.modules AS m
 ON c.ivr_id = m.ivr_id
 LEFT 
 JOIN keepcoding.steps AS s
 ON m.ivr_id = s.ivr_id
 AND m.module_sequece = s.module_sequece;
