CREATE FUNCTION [data].[starter_elo_delta]
(
	@entries_total INT,
	@entries_nonstarter INT,
	@finishing_position INT,
	@expected_score FLOAT,
	@fudge_factor FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @starter_elo_delta FLOAT


	SET 
	@starter_elo_delta = 
	
	((@entries_total - @finishing_position - @expected_score - @fudge_factor)*200)
	/
	(@entries_total - @entries_nonstarter)


	
	RETURN @starter_elo_delta
END


