CREATE TABLE [misc].[visualization_tracker] (
	page NVARCHAR(100),
	visual_name NVARCHAR(100),
	visual_type NVARCHAR(100),
	visual_subtype NVARCHAR(100),
	description NVARCHAR(MAX),
	required_search_fields NVARCHAR(100),
	potential_search_fields NVARCHAR(100),
	general_info_headers NVARCHAR(MAX),
	computed_general_info_headers NVARCHAR(MAX),
	data_columns NVARCHAR(MAX),
	computed_data_columns NVARCHAR(MAX),
	x_axis NVARCHAR(100),
	y_axis NVARCHAR(100),
	row_pk NVARCHAR(100),
	status NVARCHAR(100),
	notes NVARCHAR(MAX)
)


