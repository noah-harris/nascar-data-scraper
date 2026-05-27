CREATE OR ALTER VIEW [data].[v_driver_info]
	AS
SELECT
	d.[drv_id], 
	d.[name],
	di.[birthday],
	di.[deathday]
FROM [data].[v_driver] AS d
LEFT JOIN [map].[driver_info] AS di ON di.[drv_id] = d.[drv_id]

