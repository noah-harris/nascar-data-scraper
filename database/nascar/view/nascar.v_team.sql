CREATE VIEW [nascar].[v_team] 
	AS 
SELECT 
* 
FROM [drvavg].[team]
WHERE [name] <> ''