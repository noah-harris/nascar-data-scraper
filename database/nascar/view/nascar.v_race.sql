CREATE VIEW [nascar].[v_race]
	AS
SELECT DISTINCT 
    [drvavg_series_id], 
    [year], 
    [race_no], 
    [sked_id], 
    [event_name], 
    [event_info], 
    [date],
    t.*
FROM [nascar].[v_race_result] AS rr
JOIN [nascar].[v_track] AS t 
ON 1=1
	AND rr.[track] = t.[name]
	AND rr.[date] BETWEEN t.[start_date] AND t.[end_date]