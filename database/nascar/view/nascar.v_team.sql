CREATE VIEW [nascar].[v_team] 
	AS 
SELECT 
	[team_now],
	STRING_AGG([name], '; ') AS [name]
FROM [drvavg].[team]
WHERE [name] <> '' 
GROUP BY [team_now]
