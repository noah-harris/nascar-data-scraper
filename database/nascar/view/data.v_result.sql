CREATE OR ALTER VIEW [data].[v_result]
	AS
SELECT DISTINCT 
	[sked_id], 
	[carno_id], 
	[team_now],
	t.name AS [team_name],
	[drv_id], 
	[make], 
	[start], 
	[finish], 
	[pts], 
	[laps], 
	[laps_led], 
	[status], 
	[stage_1], 
	[stage_2], 
	[stage_3], 
	[rating]
FROM [data].[v_race_result] AS rr
LEFT JOIN [api].[car_number] AS cn ON cn.[car_number] = rr.[car_no]
LEFT JOIN [api].[team] AS t ON t.[name] = rr.[team]
LEFT JOIN [api].[driver] AS d ON d.[name] = rr.[driver_name]
