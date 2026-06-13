CREATE FUNCTION [data].[tvf_expected_score]
(	
	@drvavg_series_id INT,
	@sked_id INT,
	@alpha FLOAT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		n.[drvavg_series_id],
		n.[sked_id],
		n.[drv_id],
		SUM([data].[expected_score](n.[start_elo], f.[start_elo], @alpha))-0.5 AS [expected_score]
	FROM [data].[elo] AS n 
	JOIN [data].[elo] AS f 
	ON 1=1 
		AND n.[drvavg_series_id] = f.[drvavg_series_id] 
		AND n.[sked_id] = f.[sked_id] 
	WHERE 1=1 
		AND n.[drvavg_series_id] = @drvavg_series_id
		AND n.[sked_id] = @sked_id
	GROUP BY n.[drvavg_series_id], n.[sked_id], n.[drv_id]
)
