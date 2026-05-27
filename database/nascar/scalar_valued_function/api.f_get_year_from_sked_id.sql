CREATE FUNCTION [api].[f_get_year_from_sked_id] (@sked_id INT) RETURNS INT
	AS
BEGIN
	RETURN SUBSTRING(CAST(@sked_id AS NVARCHAR(25)), 1,4);
END