CREATE TABLE [drvavg].[race](
	[sked_id] INT NOT NULL,
	[year] INT NOT NULL,
	[drvavg_series_id] INT NOT NULL,
	[race_no] INT NOT NULL,
    [date] NVARCHAR(50),
    [track] NVARCHAR(50),
	[event_name] NVARCHAR(MAX),
    [event_info] NVARCHAR(MAX),
    PRIMARY KEY CLUSTERED ([sked_id]),
    CONSTRAINT [UQ_race_year_drvavg_series_id_race_no] UNIQUE([year], [drvavg_series_id], [race_no]),
    CONSTRAINT [FK_race_drvavg_series] FOREIGN KEY ([drvavg_series_id]) REFERENCES [drvavg].[series]([drvavg_series_id])
);