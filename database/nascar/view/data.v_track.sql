CREATE OR ALTER VIEW [data].[v_track] 
	AS 
SELECT *
FROM [api].[track] AS t
WHERE t.[name] <> 'NASCAR Race Statistics at'