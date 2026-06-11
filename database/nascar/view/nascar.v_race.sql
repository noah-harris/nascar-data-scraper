CREATE VIEW [nascar].[v_race]
    AS
WITH CTE AS (
    SELECT DISTINCT
        rrc.[drvavg_series_id], 
        rrc.[year], 
        rrc.[race_no], 
        rrc.[sked_id], 
        rrc.[date],
        t.[trk_id],
        t.[name],
        rrc.[event_name], 
        rrc.[event_info], 
        t.[trk_type_id],
        t.[track_type],
        t.[length]
    FROM [drvavg].[v_race_result_clean] AS rrc
    LEFT JOIN [nascar].[v_track] AS t 
    ON 1=1 
        AND t.[name] = rrc.[track] 
        AND rrc.[date] BETWEEN t.[start_date] AND t.[end_date]
)
SELECT 
    [drvavg_series_id], 
    [year], 
    [race_no], 
    [sked_id], 
    [date],
    [trk_id],
    [name],
    [event_name], 
    [event_info], 
    [trk_type_id],
    [track_type],
    [length],
    (SELECT COUNT(DISTINCT rr.[carno_id]) FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = rcc.[sked_id]) AS [entries],
    (SELECT MAX([laps]) FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = rcc.[sked_id]) AS [laps],
    CAST((SELECT MAX([laps])*1.0 FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = rcc.[sked_id])* [length] AS DECIMAL(20,0)) AS [distance],
    (SELECT rr.[drv_id] FROM [nascar].[v_race_result] AS rr WHERE rr.[sked_id] = rcc.[sked_id] AND rr.[finish] = 1) AS [winner]
FROM CTE AS rcc