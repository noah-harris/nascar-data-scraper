CREATE TABLE [drvavg].[series_name] (
    [drvavg_series_id] INT,
    [series_name] NVARCHAR(500),
    [start_date] DATETIME2(0),
    [end_date] DATETIME2(0),
    PRIMARY KEY([drvavg_series_id])
    );