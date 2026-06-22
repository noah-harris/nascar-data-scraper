from db import get_connection
import pandas as pd

def get_sked_info(sked_id:int | str) -> dict:
    if type(sked_id) == int:
        sked_id = str(sked_id)
    
    if len(sked_id) != 7:
        raise ValueError("Invalid sked_id format. Expected a 7-digit integer.")

    return {
        "year": int(str(sked_id)[:4]),
        "series_id": int(str(sked_id)[4]),
        "race_no": int(str(sked_id)[5:7])
    }

def get_series_info(drvavg_series_id:int) -> str:
    with get_connection() as conn:
        series_info = pd.read_sql_query(f"""
            SELECT 
                [drvavg_series_id],
                [drvavg_series_text_id],      
                [start_date],
                [end_date]
            FROM [drvavg].[series] 
            WHERE [drvavg_series_id] = {drvavg_series_id}""", conn).to_dict(orient='records')
        if not series_info:
            raise ValueError(f"No series found for drvavg_series_id: {drvavg_series_id}")
        return series_info[0]


def record_id_request_state(table:str, id:int, status:str, error:str=None):
    with get_connection() as conn:
        data = {'table': table, 'id': id, 'status': status}
        if error:
            data['error'] = error
        pd.DataFrame([data]).to_sql('id_request_log', conn, schema='req', if_exists='append', index=False)

if __name__ == '__main__':
    print(get_sked_info(2006410))



    for i in range(1949, 2026+1):
        print(i)


