CREATE VIEW [nascar].[v_race_result] 
    AS
WITH [CTE_race_result_clean] AS (
    SELECT	
        [sked_id],
        [year],
        [drvavg_series_id],
        CAST([race_no] AS INT) AS [race_no],
        [event_name],
        [track],
        CAST([date] AS DATE) AS [date],
        [event_info],
        [finish], 
        [start], 
        CASE 
            WHEN [car_no] = '' THEN NULL 
            ELSE [car_no] 
        END
        AS [car_no], 
        CASE 
            WHEN [driver_name] IN ('', '-') THEN NULL 
            ELSE [driver_name]
        END
        AS [driver_name], 
        CASE 
            WHEN [make] IN ('', '-') THEN NULL 
            ELSE [make]
        END
        AS [make], 
        [pts], 
        [laps], 
        [laps_led], 
        CASE 
            WHEN [status] IN ('', '-') THEN NULL 
            ELSE [status]
        END 
        AS [status], 
        CASE 
            WHEN [team] IN ('', '-') THEN NULL 
            ELSE [team]
        END 
        AS [team], 
        ISNULL([stage_1], 0) AS [stage_1], 
        ISNULL([stage_2], 0) AS [stage_2], 
        CASE 
            WHEN [rating] = 0.0 THEN NULL 
            ELSE [rating]
        END
        AS [rating]
    FROM [drvavg].[race_result]
    WHERE 1=1 
        AND CAST([date] AS DATE) <> '1900-01-01'
)
SELECT *
FROM [CTE_race_result_clean] AS rr
LEFT JOIN [nascar].[v_track] AS t 
ON 1=1 
    AND t.[name] = rr.[track]
    AND rr.[date] BETWEEN t.[start_date] AND t.[end_date]

/*
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
	[rating],
	e.[start_elo],
	e.[end_elo],
	(e.[end_elo] - e.[start_elo]) AS [elo_change]
FROM [data].[v_result] AS r
LEFT JOIN [data].[elo] AS e 
ON 1=1 
	AND e.[drv_id] = r.[drv_id]
	AND e.[sked_id] = r.[sked_id]




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
	[rating]
FROM [data].[v_race_result] AS rr
LEFT JOIN [api].[car_number] AS cn ON cn.[car_number] = rr.[car_no]
LEFT JOIN [api].[team] AS t ON t.[name] = rr.[team]
LEFT JOIN [api].[driver] AS d ON d.[name] = rr.[driver_name]


    */