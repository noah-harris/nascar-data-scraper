CREATE VIEW [nascar].[v_car_number] 
	AS 
SELECT 
    * 
FROM [drvavg].[car_number]
WHERE [car_number] IS NOT NULL