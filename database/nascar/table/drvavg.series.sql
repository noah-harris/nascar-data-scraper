CREATE TABLE [drvavg].[series] (
    [drvavg_series_id] INT,
    [drvavg_series_text_id] NVARCHAR(100),
    [start_date] DATETIME2(0),
    [end_date] DATETIME2(0),
    PRIMARY KEY([drvavg_series_id])
);