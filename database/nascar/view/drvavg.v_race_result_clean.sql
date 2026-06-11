CREATE VIEW [drvavg].[v_race_result_clean]
    AS
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
WHERE CAST([date] AS DATE) <> '1900-01-01'

