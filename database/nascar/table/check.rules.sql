CREATE TABLE [check].[rules] (
	[rule_id] INT,
	[object] NVARCHAR(MAX),
	[rule] NVARCHAR(MAX),
	[description] NVARCHAR(MAX),
	PRIMARY KEY([rule_id])
);