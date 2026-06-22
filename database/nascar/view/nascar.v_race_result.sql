CREATE VIEW [nascar].[v_race_result]
    AS
SELECT 
    r.[sked_id],
    t.[trk_id],
    d.[drv_id],
    cn.[carno_id],
    tm.[team_now],
    rr.[start],
    rr.[finish], 
    rr.[start] -rr.[finish] AS [position_delta],
    rr.[make], 
    rr.[pts], 
    rr.[laps], 
    rr.[laps_led], 
    (SELECT MAX([laps]) FROM [drvavg].[race_result] AS rr WHERE rr.[sked_id] = rr.[sked_id]) - rr.[laps] AS [laps_down],
    rr.[status], 
    rr.[stage_1], 
    rr.[stage_2], 
    rr.[rating],
    CAST(e.[start_elo] AS INT) AS [start_elo], 
    CAST(e.[end_elo] AS INT) AS [end_elo], 
    (CAST(e.[end_elo] AS INT) - CAST(e.[start_elo] AS INT)) AS [elo_change]
FROM [drvavg].[race_result] AS rr
LEFT JOIN [drvavg].[race] AS r ON r.[sked_id] = rr.[sked_id]
LEFT JOIN [drvavg].[driver] AS d ON d.[name] = rr.[driver_name]
LEFT JOIN [drvavg].[team] AS tm ON tm.[name] = rr.[team]
LEFT JOIN [drvavg].[car_number] AS cn ON cn.[car_number] = rr.[car_no]
LEFT JOIN [nascar].[v_track] AS t
ON 1=1 
    AND t.[name] = r.[track]
    AND r.[date] BETWEEN t.[start_date] AND t.[end_date]
LEFT JOIN [elo].[race_results_calc] AS e 
ON 1=1 
    AND e.[sked_id] = r.[sked_id] 
    AND e.[drv_id] = d.[drv_id]