CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH tabla_aux
  AS(SELECT ivr_id 
    , phone_number
    , ivr_result
    , CASE WHEN STARTS_WITH(vdn_label, 'ATC') THEN 'FRONT'
      WHEN STARTS_WITH(vdn_label, 'TECH') THEN 'TECH'
      WHEN vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
      ELSE 'RESTO'
      END AS vdn_aggregation
  
    , start_date
    , end_date
    , total_duration
    , customer_segment
    , ivr_language
    , steps_module
    , module_aggregation 
  
  FROM keepcoding.ivr_detail 
  GROUP BY ivr_id, phone_number, ivr_result, vdn_label, start_date, end_date
    , total_duration
    , customer_segment
    , ivr_language
    , steps_module
    , module_aggregation
  )

  , tipo_documento
  AS(SELECT ivr_id
    , document_type
  FROM keepcoding.ivr_detail 
  QUALIFY ROW_NUMBER() OVER (PARTITION BY ivr_id ORDER BY document_type ASC) = 1)

  , documento_identificacion
  AS(SELECT ivr_id
    , document_type
    , document_identification
  FROM keepcoding.ivr_detail 
  QUALIFY ROW_NUMBER() OVER (PARTITION BY ivr_id ORDER BY document_type ASC, document_identification) = 1)

  ,telefono
  AS(SELECT ivr_id
    , document_type
    , customer_phone
  FROM keepcoding.ivr_detail 
  QUALIFY ROW_NUMBER() OVER (PARTITION BY ivr_id ORDER BY document_type ASC, customer_phone) = 1)

  , cuenta
  AS(SELECT ivr_id
    , billing_account_id
  FROM keepcoding.ivr_detail 
  QUALIFY ROW_NUMBER() OVER (PARTITION BY ivr_id ORDER BY billing_account_id ASC) = 1)

  , averias
  AS(SELECT ivr_id
    , MAX(IF(module_name = 'AVERIA MASIVA',1,0)) AS masiva_lg
    , MAX(IF(step_name = 'CUSTOMERINFOBYPHONE.TX' AND step_description_error = 'NULL',1,0)) AS info_by_phone_lg
    , MAX(IF(step_name = 'CUSTOMERINFOBYDNI.TX' AND step_description_error = 'NULL',1,0)) AS info_by_dni_lg
  FROM keepcoding.ivr_detail
  GROUP BY ivr_id)

  SELECT tabla_aux.ivr_id
    , phone_number
    , ivr_result
    , vdn_aggregation
    , start_date
    , end_date
    , total_duration
    , customer_segment
    , ivr_language
    , steps_module
    , module_aggregation
    , tipo_documento.document_type
    , document_identification
    , customer_phone
    , billing_account_id
    , averias.masiva_lg
    , averias.info_by_phone_lg
    , averias.info_by_dni_lg
  FROM tabla_aux
  LEFT 
  JOIN tipo_documento
  ON tabla_aux.ivr_id = tipo_documento.ivr_id
  LEFT 
  JOIN documento_identificacion
  ON tipo_documento.ivr_id = documento_identificacion.ivr_id
  LEFT
  JOIN telefono
  ON documento_identificacion.ivr_id = telefono.ivr_id
  LEFT
  JOIN cuenta
  ON telefono.ivr_id = cuenta.ivr_id
  LEFT
  JOIN averias
  ON cuenta.ivr_id = averias.ivr_id;
