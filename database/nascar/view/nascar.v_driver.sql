CREATE VIEW [nascar].[v_driver] 
    AS
SELECT 
	d.[drv_id], 
	d.[name],
	di.[birthday],
	di.[deathday]
FROM [drvavg].[driver] AS d
LEFT JOIN [data].[driver_info] AS di ON di.[drv_id] = d.[drv_id]
WHERE d.[name] <> 'NASCAR Statistics'