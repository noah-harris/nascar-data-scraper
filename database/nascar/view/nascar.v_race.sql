CREATE VIEW [data].[v_race]
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
FROM (
    SELECT DISTINCT 
        [series], 
        [year], 
        [race_no], 
        [sked_id], 
        [event_name], 
        [event_info], 
        [date],
        t.[trk_id]
    FROM [nascar].[v_race_result] AS rr
    LEFT JOIN [drvavg].[track] AS t ON t.[name] = rr.[track]
) AS e
LEFT JOIN [data].[v_track_info] AS ti
ON 1=1 
	AND e.[trk_id] = ti.[trk_id]
	AND e.[date] BETWEEN ti.[effective_start_date] AND ti.[effective_end_date]
