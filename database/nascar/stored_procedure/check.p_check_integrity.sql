CREATE OR ALTER PROCEDURE [check].[p_check_integrity]
	AS
DECLARE @rule_id AS INT
DECLARE @rule AS NVARCHAR(MAX)
DECLARE [rules] CURSOR FOR 
SELECT [rule_id] FROM [check].[rules] ORDER BY [rule_id]
OPEN [rules]
FETCH NEXT FROM [rules] INTO @rule_id

WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT * FROM [check].[rules] WHERE [rule_id] = @rule_id 
		SET @rule = (SELECT [rule] FROM [check].[rules] WHERE [rule_id] = @rule_id)
		EXEC(@rule)
		FETCH NEXT FROM [rules] INTO @rule_id
	END
CLOSE [rules]
DEALLOCATE [rules]