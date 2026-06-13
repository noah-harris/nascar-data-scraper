CREATE TABLE [data].[elo] (
	[drvavg_series_id] INT NOT NULL,
	[sked_id] INT NOT NULL,
	[entries] INT,
	[nonstarting_entries] INT,
	[date] DATE NOT NULL,
	[drv_id] INT NOT NULL,
	[start] INT,
	[finish] INT,
	[fudge_factor] FLOAT,
	[strength] FLOAT,
	[last_sked_id] INT,
	[next_sked_id] INT,
	[start_elo] FLOAT,
	[end_elo] FLOAT,
	[strength_of_field] FLOAT,
	PRIMARY KEY([drvavg_series_id], [sked_id], [drv_id]),
	CONSTRAINT [FK_elo_drvavg_series_id] FOREIGN KEY ([drvavg_series_id]) REFERENCES [drvavg].[series]([drvavg_series_id])
);