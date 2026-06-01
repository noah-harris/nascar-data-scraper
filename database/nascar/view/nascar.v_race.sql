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
LEFT JOIN [nascar].[v_track] AS ti
ON 1=1 
	AND e.[trk_id] = ti.[trk_id]
	AND e.[date] BETWEEN ti.[start_date] AND ti.[end_date]
