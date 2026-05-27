CREATE OR ALTER VIEW [data].[v_car_number] 
	AS 
SELECT * 
FROM [api].[car_number]
WHERE [car_number] IS NOT NULL