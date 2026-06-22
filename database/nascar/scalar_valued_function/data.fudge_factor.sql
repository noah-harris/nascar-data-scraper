CREATE FUNCTION [data].[fudge_factor]
(
	@entries_total FLOAT,
	@entries_nonstarter FLOAT,
	@finishing_position FLOAT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @fudge_factor FLOAT


	SET @fudge_factor = 
	(
	(
		(@entries_total - (@entries_nonstarter/2))
		/
		(2)
	)-@finishing_position
	)
	/
	(100)


	
	RETURN @fudge_factor
END