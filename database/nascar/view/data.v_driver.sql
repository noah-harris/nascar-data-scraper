CREATE OR ALTER VIEW [data].[v_driver] 
	AS 
SELECT * 
FROM [api].[driver] 
WHERE [name] <> 'NASCAR Statistics'
