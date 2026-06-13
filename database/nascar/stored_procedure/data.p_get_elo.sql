CREATE PROCEDURE [data].[p_get_elo]
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
		self.[sked_id], 
		self.[drv_id] AS [self_drv_id],
		self.[finish] AS [self_finish],
		self.[start_elo] AS [self_start_elo], 
		self.[start],
		((@field_size-(@nonstarting/2)/2.0)-[self].[finish])/(100.0) AS [fudge_factor_self],
		(
			(1-EXP(-[self].[start_elo]/@coef)) * EXP(-[comp].[start_elo]/@coef)
		)
			/
		( 
			(
				(1-EXP(-[comp].[start_elo]/@coef)) * EXP(-[self].[start_elo]/@coef)
			) 
				+ 
			( 
				(1-EXP(-[self].[start_elo]/@coef)) * EXP(-[comp].[start_elo]/@coef)
			)
		) AS [mu_nm]
	INTO #data_elo_calc
	FROM [data].[elo] AS [self]
	LEFT JOIN [data].[elo] AS [comp] ON [self].[sked_id] = [comp].[sked_id] 
	WHERE [self].[sked_id] = @current_sked_id



	DROP TABLE IF EXISTS #elo_calc
	SELECT 
		[sked_id],
		[self_drv_id] AS [drv_id],
		[self_finish] AS [finish],
		[fudge_factor_self] AS [fudge_factor],
		SUM([mu_nm])-0.5 AS [expected_score],
		CASE
			WHEN [start] = 0 THEN (SUM([mu_nm])-0.5)
			ELSE ((@field_size - [self_finish] - (SUM([mu_nm])-0.5) - [fudge_factor_self])*200)/((@field_size-@nonstarting) + CASE WHEN @field_size = @nonstarting THEN 0.00000001 ELSE 0.0 END)
		END AS [elo_delta]
	INTO #elo_calc
	FROM #data_elo_calc
	GROUP BY [sked_id], [self_drv_id], [self_finish], [fudge_factor_self], [start]

	/* Update elos */
	-- Current race end elo

	UPDATE [elo] 
	-- Restrict elos to greater than 0.
	SET [elo].[end_elo] = CASE WHEN [elo].[start_elo] + [elo_delta].[elo_delta] <= 1 THEN 1 ELSE [elo].[start_elo] + [elo_delta].[elo_delta] END
	FROM [data].[elo] AS [elo]
	LEFT JOIN #elo_calc AS [elo_delta]
	ON 1=1 
		AND [elo].[sked_id] = [elo_delta].[sked_id] 
		AND [elo].[drv_id] = [elo_delta].[drv_id]
	WHERE [elo].[sked_id] = @current_sked_id

	-- Next race start elo
	UPDATE [elo] 
	SET [elo].[start_elo] = [set_start_elo].[end_elo]
	FROM [data].[elo] AS [elo] 
	LEFT JOIN [data].[elo] AS [set_start_elo]
	ON 1=1 
		AND [elo].[last_sked_id] = [set_start_elo].[sked_id]
		AND [elo].[drv_id] = [set_start_elo].[drv_id]
	WHERE [set_start_elo].[sked_id] = @current_sked_id

	FETCH NEXT FROM [sked_ids] INTO @current_sked_id
END
CLOSE [sked_ids]
DEALLOCATE [sked_ids]
FETCH NEXT FROM [series] INTO @current_series
END 
CLOSE [series]
DEALLOCATE [series]