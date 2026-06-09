CREATE OR ALTER VIEW [nascar].[v_race_result_info]
    AS
SELECT
    -- IDs
    d.[drv_id],
    cn.[carno_id],
    tm.[team_now],
    -- Names
    s.[series_name],
    s.[generation_name],
    -- All v_race_result columns
    rr.*
FROM [nascar].[v_race_result] AS rr
LEFT JOIN [nascar].[v_series] AS s
ON 1=1
    AND s.[drvavg_series_id] = rr.[drvavg_series_id]
    AND rr.[date] BETWEEN s.[start_date] AND s.[end_date]
LEFT JOIN [nascar].[v_driver] AS d ON d.[name] = rr.[driver_name]
LEFT JOIN [nascar].[v_team] AS tm ON tm.[name] = rr.[team]
LEFT JOIN [nascar].[v_car_number] AS cn ON cn.[car_number] = rr.[car_no]
