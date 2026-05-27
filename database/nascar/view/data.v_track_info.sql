CREATE OR ALTER VIEW [data].[v_track_info]
	AS
SELECT
	t.[trk_id],
	ti.[trk_type_id],
	t.[name],
	tt.[track_type],
	ti.[length],
	ti.[length_units],
	ti.[turns],
	ti.[effective_start_date],
	ti.[effective_end_date],
	ti.[longitude],
	ti.[latitude]
FROM [data].[v_track] AS t
LEFT JOIN [map].[track_info] AS ti ON ti.[trk_id] = t.[trk_id]
LEFT JOIN [api].[track_type] AS tt ON ti.[trk_type_id] = tt.[trk_type_id]

