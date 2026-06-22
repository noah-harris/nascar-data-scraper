WITH CTE AS (
	SELECT DISTINCT
		drvavg_series_id,
		SUBSTRING(
		CASE 
			WHEN SUBSTRING(event_info, 7, 1) = ' ' THEN LEFT(event_info, 5)+'0'+SUBSTRING(event_info, 6, 99999)
			ELSE event_info 
		END, 21,999999) AS [series_name],
		SUBSTRING(
		CASE 
			WHEN SUBSTRING(event_info, 7, 1) = ' ' THEN LEFT(event_info, 5)+'0'+SUBSTRING(event_info, 6, 99999)
			ELSE event_info 
		END, 16,4) AS [year]
	from nascar.v_race as r
)
SELECT *, LEAD(year) OVER (PARTITION BY drvavg_series_id ORDER BY year) AS [next year], LEAD(series_name) OVER (PARTITION BY drvavg_series_id ORDER BY year) AS [next year]
FROM CTE
ORDER BY drvavg_series_id, year


