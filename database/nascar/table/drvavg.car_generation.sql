CREATE TABLE [drvavg].[car_generation] (
    [car_generation_id] UNIQUEIDENTIFIER DEFAULT NEWID(),
    [drvavg_series_id] INT,
    [generation_name] NVARCHAR(500),
    [start_date] DATETIME2(0),
    [end_date] DATETIME2(0),
    CONSTRAINT [PK_car_generation] PRIMARY KEY NONCLUSTERED ([car_generation_id]),
    CONSTRAINT [FK_car_generation_series] FOREIGN KEY ([drvavg_series_id]) REFERENCES [drvavg].[series]([drvavg_series_id]),
    CONSTRAINT [UQ_car_generation_name] UNIQUE ([generation_name]),
    CONSTRAINT [CK_car_generation_dates] CHECK ([start_date] < [end_date])
);