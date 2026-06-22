CREATE PROCEDURE [elo].[p_calculate]
AS
SET NOCOUNT ON

TRUNCATE TABLE [elo].[race_calc]
TRUNCATE TABLE [elo].[race_results_calc]

-- Entry level data

-- Entries are defined as the number of cars in the race
-- This correosponds to the number of positions that are in the race, and therefore the elos that can be calculated.

-- Race level data
;WITH [CTE] AS (
	SELECT 
		[sked_id],
		COUNT(*) AS [entries],
		SUM(CASE WHEN ISNULL([start], 0) > 0 THEN 1 ELSE 0 END) AS [starting_entries],
		SUM(CASE WHEN ISNULL([start], 0) = 0 THEN 1 ELSE 0 END) AS [nonstarting_entries]
	FROM [nascar].[v_race_result]
	GROUP BY [sked_id]
)
INSERT INTO [elo].[race_calc]
SELECT
	r.[sked_id],
	r.[year],
	r.[drvavg_series_id],
	r.[race_no],
	r.[date],
	NULL AS [strength_of_field],
	c.[entries] AS [entries],
	c.[starting_entries] AS [starting_entries],
	c.[nonstarting_entries] AS [nonstarting_entries]
FROM [drvavg].[race] AS r
JOIN [CTE] AS c ON r.[sked_id] = c.[sked_id]


;WITH CTE AS (
	SELECT
		r.[sked_id],
		rr.[drv_id],
		rr.[start],
		rr.[finish],
		LAG(r.[sked_id]) OVER (PARTITION BY r.[drvavg_series_id], rr.[drv_id] ORDER BY r.[sked_id]) AS [last_sked_id],
		LEAD(r.[sked_id]) OVER (PARTITION BY r.[drvavg_series_id], rr.[drv_id] ORDER BY r.[sked_id]) AS [next_sked_id]
	FROM [nascar].[v_race_result] AS rr
	JOIN [drvavg].[race] AS r ON r.[sked_id] = rr.[sked_id]
	WHERE r.[drvavg_series_id] IN (0,5,7)
)
INSERT INTO [elo].[race_results_calc]
SELECT 
	[sked_id],
	[drv_id],
	[start],
	[finish],
	[last_sked_id],
	[next_sked_id],
	CASE WHEN [last_sked_id] IS NULL THEN 1350 ELSE NULL END AS [start_elo],
	NULL AS [fudge_factor],
	NULL AS [expected_score],
	NULL AS [strength],
	NULL AS [elo_change],
	NULL AS [end_elo]
FROM [CTE]

/* 
===========================================================
Perform Computations
===========================================================
*/ 

DECLARE @sof AS FLOAT
DECLARE @alpha AS FLOAT = 1600/LOG(2)

DECLARE @entries INT
DECLARE @starting_entries INT
DECLARE @nonstarting_entries INT

DECLARE @current_series INT
DECLARE [series] CURSOR FOR 
SELECT DISTINCT [drvavg_series_id] FROM [drvavg].[series]  WHERE [drvavg_series_id] IN (0,5,7)
OPEN [series]
FETCH NEXT FROM [series] INTO @current_series
WHILE @@FETCH_STATUS = 0
BEGIN

DECLARE @current_sked_id INT
DECLARE [sked_ids] CURSOR FOR
SELECT [sked_id] FROM [elo].[race_calc] WHERE [drvavg_series_id] = @current_series ORDER BY [sked_id]
OPEN [sked_ids]
FETCH NEXT FROM [sked_ids] INTO @current_sked_id

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @entries = (SELECT [entries] FROM [elo].[race_calc] WHERE [sked_id] = @current_sked_id)
	SET @starting_entries = (SELECT [starting_entries] FROM [elo].[race_calc] WHERE [sked_id] = @current_sked_id)
	SET @nonstarting_entries = (SELECT [nonstarting_entries] FROM [elo].[race_calc] WHERE [sked_id] = @current_sked_id)


	DROP TABLE IF EXISTS #data_elo_calc
	SELECT 
		n.[sked_id], 
		n.[drv_id],
		n.[finish],
		n.[start_elo], 
		n.[start],
		((@entries-(@nonstarting_entries/2)/2.0)-n.[finish])/(100.0) AS [fudge_factor],
		(
			(1-EXP(-n.[start_elo]/@alpha)) * EXP(-f.[start_elo]/@alpha)
		)
			/
		( 
			(
				(1-EXP(-f.[start_elo]/@alpha)) * EXP(-n.[start_elo]/@alpha)
			) 
				+ 
			( 
				(1-EXP(-n.[start_elo]/@alpha)) * EXP(-f.[start_elo]/@alpha)
			)
		) AS [expected_score_nf]
	INTO #data_elo_calc
	FROM [elo].[race_results_calc] AS n
	JOIN [elo].[race_results_calc] AS f ON n.[sked_id] = f.[sked_id] 
	WHERE n.[sked_id] = @current_sked_id

	DROP TABLE IF EXISTS #elo_calc
	;WITH [CTE] AS (
		SELECT 
			[sked_id],
			[drv_id],
			[finish],
			[fudge_factor],
			[start_elo],
			SUM([expected_score_nf])-0.5 AS [expected_score],
			EXP(-[start_elo]/@alpha) AS [strength],
			CASE
				WHEN [start] = 0 THEN (SUM([expected_score_nf])-0.5)
				ELSE ((@entries - [finish] - (SUM([expected_score_nf])-0.5) - [fudge_factor])*200)/(@starting_entries + CASE WHEN @entries = @nonstarting_entries THEN 0.00000001 ELSE 0.0 END)
			END AS [elo_change]
		
		FROM #data_elo_calc
		GROUP BY [sked_id], [drv_id], [start], [finish], [fudge_factor], [start_elo]
	)
	SELECT
		[sked_id],
		[drv_id],
		[finish],
		[fudge_factor],
		[expected_score],
		[strength],
		CASE WHEN [elo_change] > 129 THEN 129 WHEN [elo_change] < -129 THEN -129 ELSE [elo_change] END AS [elo_change],
		-- Restrict elos to greater than 0.
		CASE 
			WHEN [start_elo] + CASE WHEN [elo_change] > 129 THEN 129 WHEN [elo_change] < -129 THEN -129 ELSE [elo_change] END <= 1 THEN 1 
			ELSE [start_elo] + CASE WHEN [elo_change] > 129 THEN 129 WHEN [elo_change] < -129 THEN -129 ELSE [elo_change] END 
		END 
		AS [end_elo]
	INTO #elo_calc
	FROM [CTE]

	/* Update elos */
	-- Current race end elo
	UPDATE e
	
	SET	
		e.[end_elo] = d.[end_elo],
		e.[expected_score] = d.[expected_score],
		e.[strength] = d.[strength],
		e.[elo_change] = d.[elo_change],
		e.[fudge_factor] = d.[fudge_factor]
	FROM [elo].[race_results_calc] AS e
	LEFT JOIN #elo_calc AS d
	ON 1=1 
		AND e.[sked_id] = d.[sked_id] 
		AND e.[drv_id] = d.[drv_id]
	WHERE e.[sked_id] = @current_sked_id

	-- Next race start elo
	UPDATE e
	SET e.[start_elo] = s.[end_elo]
	FROM [elo].[race_results_calc] AS e
	JOIN [elo].[race_results_calc] AS s
	ON 1=1 
		AND e.[last_sked_id] = s.[sked_id]
		AND e.[drv_id] = s.[drv_id]
	WHERE s.[sked_id] = @current_sked_id

	-- Race SOF
	SET @sof = (
		SELECT 
			@alpha * LOG(@entries/SUM([strength]))
		FROM [elo].[race_results_calc]
		WHERE [sked_id] = @current_sked_id
	)

	UPDATE [elo].[race_calc]
	SET [strength_of_field] = @sof
	WHERE [sked_id] = @current_sked_id

	FETCH NEXT FROM [sked_ids] INTO @current_sked_id
END
CLOSE [sked_ids]
DEALLOCATE [sked_ids]
FETCH NEXT FROM [series] INTO @current_series
END 
CLOSE [series]
DEALLOCATE [series]