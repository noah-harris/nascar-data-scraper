CREATE TABLE [map].[track_info] (
	[source] NVARCHAR(50),
	[name] NVARCHAR(100),
	[trk_id] INT,
	[trk_type_id] INT,
	[length] FLOAT,
	[length_units] NVARCHAR(25),
	[turns] INT,
	[effective_start_date] DATE,
	[effective_end_date] DATE,
	[longitude] FLOAT,
	[latitude] FLOAT 
	);