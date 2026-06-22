CREATE FUNCTION [data].[strength]
(
	@elo FLOAT,
	@alpha FLOAT
)
RETURNS FLOAT
AS
BEGIN
	RETURN EXP(-@elo/@alpha)
END

