CREATE VIEW [nascar].[v_track] 
	AS 
SELECT 
	t.[trk_id],
	ti.[trk_type_id],
	t.[name],
	tt.[track_type],
	ti.[length],
	ti.[length_units],
	ti.[turns],
	ti.[start_date],
	ti.[end_date],
	ti.[longitude],
	ti.[latitude]
FROM [drvavg].[track] AS t
LEFT JOIN [data].[track_info] AS ti ON ti.[trk_id] = t.[trk_id]
LEFT JOIN [drvavg].[track_type] AS tt ON ti.[trk_type_id] = tt.[trk_type_id]