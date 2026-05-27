CREATE PROCEDURE [p_SelectAllTables]
AS
BEGIN

	DECLARE @table_name NVARCHAR(128)
	DECLARE @schema NVARCHAR(128)
	DECLARE @sql NVARCHAR(MAX)

	DECLARE [db_cursor] CURSOR FOR
	SELECT s.[name], t.[name]
	FROM [sys].[tables] AS t 
	LEFT JOIN [sys].[schemas] AS s 
	ON s.[schema_id] = t.[schema_id] 
	WHERE t.[type] = 'U'
	ORDER BY s.[name], t.[name]

	OPEN [db_cursor] FETCH NEXT FROM [db_cursor] INTO @schema, @table_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql = 'SELECT * FROM ' + QUOTENAME(@schema)+'.'+QUOTENAME(@table_name)
		EXEC sp_executesql @sql
		FETCH NEXT FROM [db_cursor] INTO @schema, @table_name
	END
	CLOSE [db_cursor]
	DEALLOCATE [db_cursor]

END