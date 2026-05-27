CREATE OR ALTER VIEW [data].[v_event]
	AS
SELECT DISTINCT 
	[series], 
	[year], 
	[race_no], 
	[sked_id], 
	[event_name], 
	[event_info], 
	[date],
	t.[trk_id]
FROM [data].[v_race_result] AS rr
LEFT JOIN [api].[track] AS t ON t.[name] = rr.[track]