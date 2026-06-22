CREATE TABLE [req].[id_request_log](
    [table] NVARCHAR(50),
    [id] INT,
    [status] NVARCHAR(25),
    [error] NVARCHAR(MAX),
    [created_at] DATETIME DEFAULT GETDATE(),
    PRIMARY KEY ([table], [id])
)