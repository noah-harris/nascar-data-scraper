CREATE OR ALTER VIEW [data].[v_event_info]
	AS
SELECT DISTINCT 
	[series], 
	[year], 
	[race_no], 
	[sked_id], 
	[event_name], 
	[event_info], 
	[date],
	ti.*
FROM [data].[v_event] AS e
LEFT JOIN [data].[v_track_info] AS ti
ON 1=1 
	AND e.[trk_id] = ti.[trk_id]
	AND e.[date] BETWEEN ti.[effective_start_date] AND ti.[effective_end_date]
