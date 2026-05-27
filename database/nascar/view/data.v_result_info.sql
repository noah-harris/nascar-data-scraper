CREATE OR ALTER VIEW [data].[v_result_info]
	AS
SELECT DISTINCT 
	r.[sked_id], 
	[carno_id], 
	[team_now],
	[team_name],
	r.[drv_id], 
	[make], 
	[start], 
	r.[finish], 
	(r.[start] - r.[finish]) AS [position_delta],
	[pts], 
	[laps], 
	(SELECT MAX(rr.[laps]) FROM [data].[v_race_result] AS rr WHERE rr.[sked_id] = r.[sked_id]) - r.[laps] AS [laps_down],
	[laps_led], 
	[status], 
	[stage_1], 
	[stage_2], 
	[stage_3], 
	[rating],
	e.[start_elo],
	e.[end_elo],
	(e.[end_elo] - e.[start_elo]) AS [elo_change]
FROM [data].[v_result] AS r
LEFT JOIN [data].[elo] AS e 
ON 1=1 
	AND e.[drv_id] = r.[drv_id]
	AND e.[sked_id] = r.[sked_id]