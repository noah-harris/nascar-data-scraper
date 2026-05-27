CREATE OR ALTER VIEW [data].[v_season_statistics]
	AS
WITH CTE_Driver_Stats AS (
    SELECT 
        vrr.[drv_id],
        d.[name],
        di.[birthday],
        e.[series],
        e.[year],
        vrr.[finish],
        vrr.[start],
		vrr.[pts]
    FROM [data].[v_result] AS vrr
    LEFT JOIN [data].[v_event] AS e ON vrr.[sked_id] = e.[sked_id]
    LEFT JOIN[data].[v_driver] AS d ON vrr.[drv_id] = d.[drv_id]
    LEFT JOIN [data].[v_driver_info] AS di ON d.[drv_id] = di.[drv_id]
)
SELECT 
    ds.[drv_id], 
    ds.[name],
    ds.[series],
	ds.[year], 

    -- Total starts
    COUNT(ds.[start]) AS [total_starts],

    -- Average starts and finishes rounded to 2 decimal places
    CAST(AVG(ds.[start]+0.0) AS DECIMAL(20,1)) AS [avg_start],
    CAST(AVG(ds.[finish]+0.0) AS DECIMAL(20,1)) AS [avg_finish],

    -- Total wins, top 5s, top 10s
    SUM(CASE WHEN ds.[finish] = 1 THEN 1 ELSE 0 END) AS [total_wins],
    SUM(CASE WHEN ds.[finish] <= 5 THEN 1 ELSE 0 END) AS [total_top5s],
    SUM(CASE WHEN ds.[finish] <= 10 THEN 1 ELSE 0 END) AS [total_top10s],
    
    -- Win percentage, Top 5 percentage, Top 10 percentage
    CAST(
        CASE WHEN COUNT(ds.[start]) > 0 THEN 
            (SUM(CASE WHEN ds.[finish] = 1 THEN 1.0 ELSE 0 END) / COUNT(ds.[start])) 
        ELSE 0 END 
    AS DECIMAL(20,4)) AS [win_percentage],
    CAST(
        CASE WHEN COUNT(ds.[start]) > 0 THEN 
            (SUM(CASE WHEN ds.[finish] <= 5 THEN 1.0 ELSE 0 END) / COUNT(ds.[start])) 
        ELSE 0 END 
    AS DECIMAL(20,4)) AS [top5_percentage],
    CAST(
        CASE WHEN COUNT(ds.[start]) > 0 THEN 
            (SUM(CASE WHEN ds.[finish] <= 10 THEN 1.0 ELSE 0 END) / COUNT(ds.[start])) 
        ELSE 0 END 
    AS DECIMAL(20,4)) AS [top10_percentage],
	SUM(ds.[pts]) AS [points],
	DENSE_RANK() OVER (PARTITION BY ds.[series], ds.[year] ORDER BY SUM(ds.[pts]) DESC) AS [standing]
FROM CTE_Driver_Stats AS ds
GROUP BY ds.[drv_id], ds.[name], ds.[series], ds.[year]


