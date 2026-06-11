CREATE TABLE [data].[track_info] (
	[source] NVARCHAR(50),
	[name] NVARCHAR(100),
	[trk_id] INT,
	[trk_type_id] INT,
	[length] DECIMAL(10,2),
	[length_units] NVARCHAR(25),
	[turns] INT,
	[start_date] DATE,
	[end_date] DATE,
	[longitude] DECIMAL(10,6),
	[latitude] DECIMAL(10,6),
	CONSTRAINT [PK_track_info] PRIMARY KEY NONCLUSTERED ([trk_id], [start_date]),
	CONSTRAINT [CK_track_info_dates] CHECK ([start_date] <= [end_date])
);