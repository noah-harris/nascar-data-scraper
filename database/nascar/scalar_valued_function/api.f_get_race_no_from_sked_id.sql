CREATE FUNCTION [api].[f_get_race_no_from_sked_id] (@sked_id INT) RETURNS INT
	AS
BEGIN
	RETURN SUBSTRING(CAST(@sked_id AS NVARCHAR(25)), 6,2);
END