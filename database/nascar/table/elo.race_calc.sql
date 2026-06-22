CREATE TABLE [elo].[race_calc](
    [sked_id] INT,
    [year] INT NOT NULL,
    [drvavg_series_id] INT NOT NULL,
    [race_no] INT NOT NULL,
    [date] DATE NOT NULL,
    [strength_of_field] FLOAT NULL,
    [entries] INT NULL,
    [starting_entries] INT NULL,
    [nonstarting_entries] INT NULL,
    PRIMARY KEY CLUSTERED ([sked_id]),
    CONSTRAINT [FK_elo_drvavg_series_id] FOREIGN KEY ([drvavg_series_id]) REFERENCES [drvavg].[series]([drvavg_series_id])
);