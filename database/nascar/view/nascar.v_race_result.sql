CREATE VIEW [nascar].[v_race_result]
    AS
SELECT 
    rrc.[sked_id],
    t.[trk_id],
    d.[drv_id],
    cn.[carno_id],
    tm.[team_now],
    rrc.[start],
    rrc.[finish], 
    rrc.[start] -rrc.[finish] AS [position_delta],
    rrc.[make], 
    rrc.[pts], 
    rrc.[laps], 
    rrc.[laps_led], 
    (SELECT MAX([laps]) FROM [drvavg].[v_race_result_clean] AS rr WHERE rr.[sked_id] = rrc.[sked_id]) - rrc.[laps] AS [laps_down],
    rrc.[status], 
    rrc.[stage_1], 
    rrc.[stage_2], 
    rrc.[rating],
    CAST(e.[start_elo] AS INT) AS [start_elo], 
    CAST(e.[end_elo] AS INT) AS [end_elo], 
    (CAST(e.[end_elo] AS INT) - CAST(e.[start_elo] AS INT)) AS [elo_change]
FROM [drvavg].[v_race_result_clean] AS rrc
LEFT JOIN [drvavg].[driver] AS d ON d.[name] = rrc.[driver_name]
LEFT JOIN [drvavg].[team] AS tm ON tm.[name] = rrc.[team]
LEFT JOIN [drvavg].[car_number] AS cn ON cn.[car_number] = rrc.[car_no]
LEFT JOIN [nascar].[v_track] AS t
ON 1=1 
    AND t.[name] = rrc.[track]
    AND rrc.[date] BETWEEN t.[start_date] AND t.[end_date]
LEFT JOIN [data].[elo] AS e 
ON 1=1 
    AND e.[sked_id] = rrc.[sked_id] 
    AND e.[drv_id] = d.[drv_id]