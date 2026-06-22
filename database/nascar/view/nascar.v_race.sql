CREATE VIEW [nascar].[v_race]
    AS
SELECT
    r.[drvavg_series_id], 
    r.[year], 
    r.[race_no], 
    r.[sked_id], 
    r.[date],
    t.[trk_id],
    t.[name],
    r.[event_name], 
    r.[event_info], 
    t.[trk_type_id],
    t.[track_type],
    t.[length],
    (SELECT COUNT(DISTINCT rr.[carno_id]) FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = r.[sked_id]) AS [entries],
    (SELECT COUNT(DISTINCT rr.[carno_id]) FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = r.[sked_id] AND ISNULL(rr.[start], 0) = 0) AS [nonstarting_entries],
    (SELECT MAX([laps]) FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = r.[sked_id]) AS [laps],
    CAST((SELECT MAX([laps])*1.0 FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = r.[sked_id])* [length] AS DECIMAL(20,0)) AS [distance],
    (SELECT rr.[drv_id] FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = r.[sked_id] AND rr.[finish] = 1) AS [winner]
FROM [drvavg].[race] AS r
LEFT JOIN [nascar].[v_track] AS t 
ON 1=1 
    AND t.[name] = r.[track] 
    AND r.[date] BETWEEN t.[start_date] AND t.[end_date]