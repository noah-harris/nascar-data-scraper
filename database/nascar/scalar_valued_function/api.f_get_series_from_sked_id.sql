CREATE FUNCTION [api].[f_get_series_from_sked_id] (@sked_id INT) RETURNS NVARCHAR(25)
	AS
BEGIN
	RETURN SUBSTRING(CAST(@sked_id AS NVARCHAR(25)),5,1);
END