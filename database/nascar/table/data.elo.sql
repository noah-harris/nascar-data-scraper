CREATE TABLE [data].[elo] (
	[series] NVARCHAR(50),
	[sked_id] INT,
	[drv_id] INT,
	[finish] INT,
	[last_sked_id] INT,
	[next_sked_id] INT,
	[start_elo] FLOAT,
	[end_elo] INT,
	PRIMARY KEY(sked_id, drv_id)
	);