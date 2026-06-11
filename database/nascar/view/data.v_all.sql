CREATE VIEW [data].[v_all]
 	AS
SELECT 
	r.[sked_id], 
	r.[year], 
	s.[drvavg_series_text_id] AS [series], 
	r.[race_no], 
	r.[event_name], 
	r.[event_info], 
	r.[date],
	r.[trk_id], 
	tr.[name] AS [track_name], 
	r.[trk_type_id],
	tr.[track_type],
	tr.[length],
	tr.[length_units],
	tr.[turns],
	tr.[latitude],
	tr.[longitude],
	rr.[team_now],
	t.[name] AS [team_name],
	cn.[carno_id],
	cn.[car_number],
	rr.[make],
	s.[generation_name] AS [generation],
	di.[drv_id],
	di.[name],
	di.[birthday],
	di.[deathday],
	DATEDIFF(YEAR, di.[birthday], r.[date]) AS [age],
	rr.[start],
	rr.[finish],
	rr.[position_delta],
	rr.[laps_down],
	rr.[status],
	rr.[laps],
	rr.[laps_led],
	rr.[pts],
	rr.[stage_1],
	rr.[stage_2],
	rr.[rating],
	rr.[start_elo],
	rr.[end_elo],
	rr.[elo_change]
FROM [nascar].[v_race_result] AS rr
JOIN [nascar].[v_race] AS r ON rr.[sked_id] = r.[sked_id]
JOIN [nascar].[v_series] AS s 
ON 1=1 
    AND r.[drvavg_series_id] = s.[drvavg_series_id]
    AND r.[date] BETWEEN s.[start_date] AND s.[end_date]
LEFT JOIN [nascar].[v_driver] AS di ON di.[drv_id] = rr.[drv_id]
LEFT JOIN [nascar].[v_car_number] AS cn ON cn.[carno_id] = rr.[carno_id]
LEFT JOIN [nascar].[v_team] AS t ON t.[team_now] = rr.[team_now]
LEFT JOIN [nascar].[v_track] AS tr 
ON 1=1 
	AND tr.[trk_id] = r.[trk_id]
	AND r.[date] BETWEEN tr.[start_date] AND tr.[end_date]
