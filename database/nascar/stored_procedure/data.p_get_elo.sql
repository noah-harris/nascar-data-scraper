CREATE PROCEDURE [elo].[p_calculate]
AS
SET NOCOUNT ON

TRUNCATE TABLE [data].[elo]

;WITH CTE AS (
SELECT 
	r.[drvavg_series_id], 
	r.[sked_id],
	r.[date], 
	rr.[drv_id], 
	rr.[start],
	rr.[finish],
	LAG(r.[sked_id]) OVER (PARTITION BY r.[drvavg_series_id], rr.[drv_id] ORDER BY r.[sked_id]) AS [last_sked_id],
	LEAD(r.[sked_id]) OVER (PARTITION BY r.[drvavg_series_id], rr.[drv_id] ORDER BY r.[sked_id]) AS [next_sked_id],
	r.[entries],
	r.[nonstarting_entries]
FROM [nascar].[v_race_result] AS rr
JOIN [nascar].[v_race] AS r ON r.[sked_id]= rr.[sked_id]
WHERE r.[drvavg_series_id] IN (0,5,7)
)
INSERT INTO [data].[elo] ([drvavg_series_id], [sked_id], [date], [drv_id], [start], [finish], [last_sked_id], [next_sked_id], [start_elo], [end_elo])
SELECT 
	[drvavg_series_id],
	[sked_id],
	[date], 
	[drv_id],
	[start],
	[finish],
	[last_sked_id],
	[next_sked_id],
	CASE WHEN [last_sked_id] IS NULL THEN 1350 ELSE NULL END AS [start_elo],
	NULL AS [end_elo],
	[entries],
	[nonstarting_entries]
FROM [CTE]
ORDER BY [drvavg_series_id], [drv_id], [date] ASC

/* 
===========================================================
Perform Computations
===========================================================
*/ 

DECLARE @sof AS FLOAT
DECLARE @coef AS FLOAT = 1600/LOG(2)
DECLARE @field_size AS INT
DECLARE @nonstarting AS INT


DECLARE @current_series INT
DECLARE [series] CURSOR FOR 
SELECT DISTINCT [drvavg_series_id] FROM [drvavg].[series]  WHERE [drvavg_series_id] IN (0,5,7)
OPEN [series]
FETCH NEXT FROM [series] INTO @current_series
WHILE @@FETCH_STATUS = 0
BEGIN

DECLARE @current_sked_id INT
DECLARE [sked_ids] CURSOR FOR
SELECT DISTINCT [sked_id] FROM [data].[elo] WHERE [drvavg_series_id] = @current_series ORDER BY [sked_id]
OPEN [sked_ids]
FETCH NEXT FROM [sked_ids] INTO @current_sked_id

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @field_size = ISNULL((SELECT COUNT(*) FROM [data].[elo] AS elo WHERE elo.[sked_id] = @current_sked_id),0)
	SET @nonstarting = ISNULL((SELECT COUNT(*) FROM [data].[elo] AS elo WHERE elo.[sked_id] = @current_sked_id AND ISNULL([start], 0) = 0),0)


	DROP TABLE IF EXISTS #data_elo_calc
	SELECT 
		n.[sked_id], 
		n.[drv_id],
		n.[finish],
		n.[start_elo], 
		n.[start],
		((@field_size-(@nonstarting/2)/2.0)-n.[finish])/(100.0) AS [fudge_factor],
		(
			(1-EXP(-n.[start_elo]/@coef)) * EXP(-f.[start_elo]/@coef)
		)
			/
		( 
			(
				(1-EXP(-f.[start_elo]/@coef)) * EXP(-n.[start_elo]/@coef)
			) 
				+ 
			( 
				(1-EXP(-n.[start_elo]/@coef)) * EXP(-f.[start_elo]/@coef)
			)
		) AS [expected_score_nf]
	INTO #data_elo_calc
	FROM [data].[elo] AS n
	LEFT JOIN [data].[elo] AS f ON n.[sked_id] = f.[sked_id] 
	WHERE n.[sked_id] = @current_sked_id

	DROP TABLE IF EXISTS #elo_calc
	SELECT 
		[sked_id],
		[drv_id],
		[finish],
		[fudge_factor],
		SUM([expected_score_nf])-0.5 AS [expected_score_n],
		CASE
			WHEN [start] = 0 THEN (SUM([expected_score_nf])-0.5)
			ELSE ((@field_size - [finish] - (SUM([expected_score_nf])-0.5) - [fudge_factor])*200)/((@field_size-@nonstarting) + CASE WHEN @field_size = @nonstarting THEN 0.00000001 ELSE 0.0 END)
		END AS [elo_delta],
		EXP(-[start_elo]/@alpha) AS [strength]
	INTO #elo_calc
	FROM #data_elo_calc
	GROUP BY [sked_id], [drv_id], [start], [finish], [fudge_factor], [start_elo]

	/* Update elos */
	-- Current race end elo

	UPDATE e
	-- Restrict elos to greater than 0.
	SET e.[end_elo] = CASE WHEN e.[start_elo] + d.[elo_delta] <= 1 THEN 1 ELSE e.[start_elo] + d.[elo_delta] END
	FROM [data].[elo] AS e
	LEFT JOIN #elo_calc AS d
	ON 1=1 
		AND e.[sked_id] = d.[sked_id] 
		AND e.[drv_id] = d.[drv_id]
	WHERE e.[sked_id] = @current_sked_id

	-- Next race start elo
	UPDATE e
	SET e.[start_elo] = s.[end_elo]
	FROM [data].[elo] AS e
	LEFT JOIN [data].[elo] AS s
	ON 1=1 
		AND e.[last_sked_id] = s.[sked_id]
		AND e.[drv_id] = s.[drv_id]
	WHERE s.[sked_id] = @current_sked_id


	FETCH NEXT FROM [sked_ids] INTO @current_sked_id
END
CLOSE [sked_ids]
DEALLOCATE [sked_ids]
FETCH NEXT FROM [series] INTO @current_series
END 
CLOSE [series]
DEALLOCATE [series]