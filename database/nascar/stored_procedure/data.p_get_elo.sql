CREATE OR ALTER PROCEDURE [data].[p_calculate_elo]
	AS
SET NOCOUNT ON

TRUNCATE TABLE [data].[elo]

;WITH CTE AS (
	SELECT 
		r.[drvavg_series_id],
		r.[sked_id],
		rr.[drv_id],
		rr.[finish],
		LAG(r.[sked_id]) OVER (PARTITION BY r.[drvavg_series_id], rr.[drv_id] ORDER BY r.[year], rr.[race_no]) AS [last_sked_id],
		LEAD(r.[sked_id]) OVER (PARTITION BY r.[drvavg_series_id], rr.[drv_id] ORDER BY r.[year], rr.[race_no]) AS [next_sked_id],
		NULL AS [start_elo],
		NULL AS [end_elo]
	FROM [nascar].[v_race_result_info] AS rr
	JOIN [nascar].[v_race] AS r ON rr.[sked_id] = r.[sked_id]
)
INSERT INTO [data].[elo] ([drvavg_series_id], [sked_id], [drv_id], [finish], [last_sked_id], [next_sked_id], [start_elo], [end_elo])
SELECT 
		[drvavg_series_id],
		[sked_id],
		[drv_id],
		[finish],
		[last_sked_id],
		[next_sked_id],
		CASE WHEN [last_sked_id] IS NULL THEN 1350 ELSE NULL END AS [start_elo],
		NULL AS [end_elo]
	FROM [CTE]
ORDER BY [drvavg_series_id], [sked_id], [finish]

/* 
===========================================================
Perform Computations
===========================================================
*/ 

DECLARE @sof AS FLOAT
DECLARE @coef AS FLOAT = 1600/LOG(2)
DECLARE @field_size AS INT


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

		SET @field_size = (SELECT COUNT(*) FROM [data].[elo] AS elo WHERE elo.[sked_id] = @current_sked_id)

		DROP TABLE IF EXISTS #data_elo_calc
		SELECT 
			self.[sked_id], 
			self.[drv_id] AS [self_drv_id],
			comp.[drv_id] AS [comp_drv_id],
			self.[finish] AS [self_finish],
			comp.[finish] AS [comp_finish], 
			self.[start_elo] AS [self_start_elo], 
			comp.[start_elo] AS [comp_start_elo], 
			EXP(-[self].[start_elo]/@coef) AS [sof_self],
			((@field_size/2.0)-[self].[finish])/100.0 AS [fudge_factor_self],
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
		LEFT JOIN [data].[elo] AS [comp]
		ON [self].[sked_id] = [comp].[sked_id] 
		WHERE [self].[sked_id] = @current_sked_id
		
		DROP TABLE IF EXISTS #elo_calc
		SELECT 
			[sked_id],
			[self_drv_id] AS [drv_id],
			[self_finish] AS [finish],
			[fudge_factor_self] AS [fudge_factor],
			SUM([mu_nm])-0.5 AS [mu_n],
			((@field_size - [self_finish] - (SUM([mu_nm])-0.5) - [fudge_factor_self])*200)/(@field_size) AS [elo_delta]
		INTO #elo_calc
		FROM #data_elo_calc
		GROUP BY 
			[sked_id],
			[self_drv_id],
			[self_finish],
			[fudge_factor_self]

		/* Update elos */
		UPDATE [elo] 
		SET [elo].[end_elo] = [elo].[start_elo] + [elo_delta].[elo_delta]
		FROM [data].[elo] AS [elo]
		LEFT JOIN #elo_calc AS [elo_delta]
		ON 1=1 
			AND [elo].[sked_id] = [elo_delta].[sked_id] 
			AND [elo].[drv_id] = [elo_delta].[drv_id]
		WHERE [elo].[sked_id] = @current_sked_id

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