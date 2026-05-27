CREATE OR ALTER VIEW [data].[v_team] 
	AS 
SELECT * 
FROM [api].[team]
WHERE [name] <> ''