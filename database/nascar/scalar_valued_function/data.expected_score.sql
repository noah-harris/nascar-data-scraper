CREATE FUNCTION [data].[expected_score]
(
	@self_elo FLOAT,
	@competitor_elo FLOAT,
	@alpha FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @expected_score FLOAT = 

	(
	(1-[data].[strength](@self_elo, @alpha))*[data].[strength](@competitor_elo, @alpha)
	)
	/
	(
	(1-[data].[strength](@competitor_elo, @alpha))*[data].[strength](@self_elo, @alpha)
	+
	(1-[data].[strength](@self_elo, @alpha))*[data].[strength](@competitor_elo, @alpha)
	)

	
	RETURN @expected_score
END