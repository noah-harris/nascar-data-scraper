CREATE TABLE [drvavg].[race_result](
	[sked_id] INT,
	[finish] INT,
	[start] INT,
	[car_no] NVARCHAR(50),
	[driver_name] NVARCHAR(50),
	[make] NVARCHAR(25),
	[pts] INT,
	[laps] INT,
	[laps_led] INT,
	[status] NVARCHAR(25),
	[team] NVARCHAR(50),
	[stage_1] INT,
	[stage_2] INT,
	[rating] DECIMAL(20,4),
	PRIMARY KEY CLUSTERED ([sked_id], [finish]),
	CONSTRAINT [FK_race_result_race] FOREIGN KEY ([sked_id]) REFERENCES [drvavg].[race]([sked_id])
);