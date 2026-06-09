CREATE TABLE [drvavg].[series_name] (
    [drvavg_series_id] INT,
    [series_name] NVARCHAR(500),
    [start_date] DATETIME2(0),
    [end_date] DATETIME2(0),
    CONSTRAINT [PK_series_name] PRIMARY KEY CLUSTERED ([drvavg_series_id], [start_date]),
    CONSTRAINT [FK_series_name_series] FOREIGN KEY([drvavg_series_id]) REFERENCES [drvavg].[series]([drvavg_series_id]),
    CONSTRAINT [UQ_series_name] UNIQUE ([series_name], [start_date], [end_date]),
    CHECK ([start_date] < [end_date])
);
    