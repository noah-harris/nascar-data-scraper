CREATE TABLE [elo].[race_results_calc] (
	[sked_id] INT,
	[drv_id] INT,
	[start] INT NOT NULL,
	[finish] INT NOT NULL,
	[last_sked_id] INT NULL,
	[next_sked_id] INT NULL,
	[start_elo] FLOAT NULL,
	[fudge_factor] FLOAT NULL,
    [expected_score] FLOAT NULL,
	[strength] FLOAT NULL,
    [elo_change] FLOAT NULL,
	[end_elo] FLOAT NULL,
	PRIMARY KEY([sked_id], [drv_id])
);