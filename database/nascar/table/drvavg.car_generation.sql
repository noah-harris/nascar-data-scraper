CREATE TABLE [drvavg].[car_generation] (
    [car_generation_id] INT IDENTITY(1,1) PRIMARY KEY,
    [drvavg_series_id] UNIQUEIDENTIFIER,
    [generation_name] NVARCHAR(500),
    [start_date] DATETIME2(0),
    [end_date] DATETIME2(0),
    CONSTRAINT [FK_car_generation_series] FOREIGN KEY ([drvavg_series_id]) REFERENCES [drvavg].[series]([drvavg_series_id]),
    CONSTRAINT [UQ_car_generation_name] UNIQUE ([generation_name])
    );