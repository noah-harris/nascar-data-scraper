CREATE OR ALTER PROCEDURE [data].[p_get_elo]
	AS

/* ===========================================================
	STEP 1: DECLARE variables
=========================================================== */ 

DECLARE @series TABLE (series NVARCHAR(50))
INSERT INTO @series (series) VALUES ('nascar'), ('nascar_xfinityseries'), ('nascar_truckseries')

DECLARE @current_sked_id INT
DECLARE @current_series NVARCHAR(50)

/* iRating Variables */

DECLARE @sof AS FLOAT
DECLARE @coef AS FLOAT = 1600/LOG(2)
DECLARE @field_size AS INT


/* ===========================================================
	STEP 2: Populate ELO table
=========================================================== */ 

TRUNCATE TABLE [data].[elo]

INSERT INTO [data].[elo] (series, sked_id, drv_id, finish, last_sked_id, next_sked_id, start_elo, end_elo)
SELECT 
	series,
	r.sked_id,
	drv_id,
	finish,
	NULL AS last_sked_id,
	NULL AS next_sked_id,
	NULL AS start_elo,
	NULL AS end_elo
FROM [data].[v_result] AS r
LEFT JOIN [data].[v_event] AS e
ON r.sked_id = e.sked_id
WHERE 1=1 
	AND e.date < GETDATE()
	AND drv_id IS NOT NULL
ORDER BY series, e.sked_id, finish

UPDATE [data].[elo] SET last_sked_id = (
	SELECT MAX(sked_id)  
	FROM [data].[elo] AS last_sked_id 
	WHERE 1=1  
		AND last_sked_id.sked_id < [data].[elo].sked_id 
		AND last_sked_id.drv_id = [data].[elo].drv_id 
		AND last_sked_id.series = [data].[elo].series)

UPDATE [data].[elo] SET next_sked_id = (
	SELECT MIN(sked_id)  
	FROM [data].[elo] AS next_sked_id 
	WHERE 1=1  
		AND next_sked_id.sked_id > [data].[elo].sked_id 
		AND next_sked_id.drv_id = [data].[elo].drv_id 
		AND next_sked_id.series = [data].[elo].series)

UPDATE [data].[elo] SET start_elo = CASE WHEN last_sked_id IS NULL THEN 1350 ELSE NULL END

/* ===========================================================
	STEP 3: Perform Computations
=========================================================== */ 

DECLARE series CURSOR FOR 
SELECT DISTINCT series FROM @series
OPEN series
FETCH NEXT FROM series INTO @current_series
WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE sked_ids CURSOR FOR
		SELECT DISTINCT sked_id FROM [data].[elo] WHERE series = @current_series ORDER BY sked_id
	OPEN sked_ids
	FETCH NEXT FROM sked_ids INTO @current_sked_id
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @field_size = (SELECT COUNT(*) FROM [data].[elo] AS elo WHERE elo.sked_id = @current_sked_id)

		DROP TABLE IF EXISTS #data_elo_calc
		SELECT 
			self.sked_id, 
			self.drv_id AS self_drv_id,
			comp.drv_id AS comp_drv_id,
			self.finish AS self_finish,
			comp.finish AS comp_finish, 
			self.start_elo AS self_start_elo, 
			comp.start_elo AS comp_start_elo, 
			EXP(-self.start_elo/@coef) AS sof_self,
			((@field_size/2.0)-self.finish)/100.0 AS fudge_factor_self,
			(
				(1-EXP(-self.start_elo/@coef)) * EXP(-comp.start_elo/@coef)
			)
				/
			( 
				(
					(1-EXP(-comp.start_elo/@coef)) * EXP(-self.start_elo/@coef)
				) 
					+ 
				( 
					(1-EXP(-self.start_elo/@coef)) * EXP(-comp.start_elo/@coef)
				)
			) AS mu_nm
		INTO #data_elo_calc
		FROM [data].[elo] AS self
		LEFT JOIN [data].[elo] AS comp
		ON self.sked_id = comp.sked_id 
		WHERE self.sked_id = @current_sked_id
		
		DROP TABLE IF EXISTS #elo_calc
		SELECT 
			sked_id,
			self_drv_id AS drv_id,
			self_finish AS finish,
			fudge_factor_self AS fudge_factor,
			SUM(mu_nm)-0.5 AS mu_n,
			((@field_size - self_finish - (SUM(mu_nm)-0.5) - fudge_factor_self)*200)/(@field_size) AS elo_delta
		INTO #elo_calc
		FROM #data_elo_calc
		GROUP BY 
			sked_id,
			self_drv_id,
			self_finish,
			fudge_factor_self

		/* Update elos */
		UPDATE elo 
		SET elo.end_elo = elo.start_elo + elo_delta.elo_delta
		FROM [data].[elo] AS elo
		LEFT JOIN #elo_calc AS elo_delta
		ON 1=1 
			AND elo.sked_id = elo_delta.sked_id 
			AND elo.drv_id = elo_delta.drv_id
		WHERE elo.sked_id = @current_sked_id

		UPDATE elo 
		SET elo.start_elo = set_start_elo.end_elo
		FROM [data].[elo] AS elo 
		LEFT JOIN [data].[elo] AS set_start_elo
		ON 1=1 
			AND elo.last_sked_id = set_start_elo.sked_id
			AND elo.drv_id = set_start_elo.drv_id
		WHERE set_start_elo.sked_id = @current_sked_id

		FETCH NEXT FROM sked_ids INTO @current_sked_id
	END
	CLOSE sked_ids
	DEALLOCATE sked_ids
	FETCH NEXT FROM series INTO @current_series
END 
CLOSE series
DEALLOCATE series