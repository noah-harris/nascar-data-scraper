CREATE TABLE [api].[race_result](
	[sked_id] INT,
	[year] INT,
	[series] NVARCHAR(25),
	[race_no] NVARCHAR(25),
	[event_name] NVARCHAR(max),
	[track] NVARCHAR(50),
	[date] NVARCHAR(50),
	[event_info] NVARCHAR(max),
	[finish] INT,
	[start] INT,
	[car_no] NVARCHAR(5),
	[driver_name] NVARCHAR(50),
	[make] NVARCHAR(25),
	[pts] INT,
	[laps] INT,
	[laps_led] INT,
	[status] NVARCHAR(25),
	[team] NVARCHAR(50),
	[stage_1] INT,
	[stage_2] INT,
	[stage_3] INT,
	[rating] FLOAT
	);



