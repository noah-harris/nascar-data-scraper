CREATE VIEW [nascar].[v_series]
    AS
SELECT
    sn.[drvavg_series_id],
    sn.[series_name],
    cg.[generation_name],
    CASE
        WHEN sn.[start_date] >= cg.[start_date] THEN sn.[start_date]
        ELSE cg.[start_date]
    END AS [start_date],
    CASE
        WHEN sn.[end_date] <= cg.[end_date] THEN sn.[end_date]
        ELSE cg.[end_date]
    END AS [end_date]
FROM [drvavg].[series_name] AS sn
LEFT JOIN [drvavg].[car_generation] AS cg
ON 1=1
    AND sn.[drvavg_series_id] = cg.[drvavg_series_id]
    AND sn.[start_date] < cg.[end_date]
    AND cg.[start_date] < sn.[end_date]
