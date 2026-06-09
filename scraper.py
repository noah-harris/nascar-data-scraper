import requests
from bs4 import BeautifulSoup
from datetime import datetime
from config import *
from db import get_connection
import pandas as pd
from util import get_sked_info, get_series_info, record_id_request_state

HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"}

def get_sked_ids() -> list:
    """
        SkedId Format: YYYYSRR \n
        YYYY - Year - :4 \n
        S - Series Index - 4 \n
        RR - Race Number - 5:7 \n
    """
    current_year = int(datetime.now().year)
    sked_ids = []
    with get_connection() as conn:
        nascar_series = pd.read_sql_query('SELECT [drvavg_series_id], YEAR([start_date]) AS [first_year] FROM [drvavg].[series]', conn).to_dict(orient='records')
    for series in nascar_series:
        drvavg_series_id = series.get('drvavg_series_id')
        series_first_year = int(series.get('first_year'))
        for year in range(series_first_year, current_year+1):
            for race_no in range(1, 100):
                sked_id:int = int(f"{year}{drvavg_series_id}{str(race_no).zfill(2)}")
                sked_ids.append(sked_id)
    return sked_ids


def get_race_results(sked_id:int) -> pd.DataFrame:
    logger.info(f"Processing sked_id: {sked_id}")
    try:
        sked_info = get_sked_info(sked_id)
        series_info = get_series_info(sked_info['series_id'])

        drvavg_series_text_id = series_info.get("drvavg_series_text_id")
        year = sked_info['year']
        race_no = sked_info['race_no']
        series_id = sked_info['series_id']

        url = BASE_URL + '/'+drvavg_series_text_id+'/race.php?sked_id='+str(sked_id)
        response = requests.get(url, proxies=working_proxy, headers=HEADERS)
        soup = BeautifulSoup(response.content, 'html.parser')
        tables = soup.find_all('table', {'class': 'sortable tabledata-nascar table-large'}, limit=1)
        if not tables:
            logger.debug(f"No race found for sked_id: {sked_id} @ url: {url}")
            record_id_request_state('race_result', sked_id, 'DOES NOT EXIST', 'SKED ID does not correspond to a valid race')
            return None
        table = tables[0]

        headers = [th.text.strip() for th in table.find('tr').find_all('th')]
        rows = []
        for row in table.find_all('tr')[1:]:
            cells = [td.text.strip() for td in row.find_all('td')]
            rows.append(cells)
        table_data = [dict(zip(headers, row)) for row in rows]
        event_info_html = soup.find("div", {"class": "sub-banner-box"})
        event_name = event_info_html.find("h3").text
        event_info_details = event_info_html.find("p").text.split("\n")
        track = event_info_details[0].replace("Race Track: ", "")
        date = datetime.strptime(event_info_details[1].replace("Date: ", ""), "%A, %B %d, %Y")
        event_info = event_info_details[2].strip()
        result_data = [{
            'sked_id': sked_id,
            'year': year,
            'drvavg_series_id': series_id,
            'race_no': race_no,
            'event_name': event_name,
            'track': track,
            'date': date,
            'event_info': event_info,
            'finish': row.get('Finish') or row.get('Fin'),
            'start': row.get('Start') or row.get('St'),
            'car_no': row.get('#'),
            'driver_name': row.get('Driver') ,
            'make': row.get('Make'),
            'pts': row.get('Pts'),
            'laps': row.get('Laps'),
            'laps_led': row.get('Led'),
            'status': row.get('Status'),
            'team': row.get('Team'),
            'stage_1': 0 if not row.get('S1') else row.get('S1'),
            'stage_2': 0 if not row.get('S2') else row.get('S2'),
            'rating': 0 if not row.get('Rating') else row.get('Rating')
        } for row in table_data]
        df = pd.DataFrame(result_data)
        with get_connection() as conn:
            df.to_sql('race_result', conn, schema='drvavg', if_exists='append', index=False)
        record_id_request_state('race_result', sked_id, 'COMPLETE')
        return df
    except Exception as e:
        record_id_request_state('race_result', sked_id, 'FAILED', str(e))
        url = BASE_URL + '/'+drvavg_series_text_id+'/race.php?sked_id='+str(sked_id)
        logger.debug(url, e)


def get_driver_name(drv_id:int) -> dict:
    logger.info(f"Processing drv_id: {drv_id}")
    try:
        url = BASE_URL + '/nascar/driver.php?drv_id=' + str(drv_id)
        response = requests.get(url, proxies=working_proxy, headers=HEADERS)
        soup = BeautifulSoup(response.content, 'html.parser')
        page_header = soup.find('div', {'id': 'Div3Head'})
        if page_header is None:
            logger.debug((f"Driver does not exist for drv_id: {drv_id}"))
            record_id_request_state('driver', drv_id, 'DOES NOT EXIST', "drv_id does not correspond to a valid driver")
            return None
        header_text = page_header.get_text(strip=True)
        header_text = header_text.replace(' NASCAR Cup Series Series Hub', '')
        driver_data =  {'drv_id': drv_id, 'name': header_text}
        df = pd.DataFrame([driver_data])
        with get_connection() as conn:
            df.to_sql('driver', conn, schema='drvavg', if_exists='append', index=False)
        record_id_request_state('driver', drv_id, 'COMPLETE')
        return driver_data
    except Exception as e:
        record_id_request_state('driver', drv_id, 'FAILED', str(e))
        logger.debug(url, e)
    

def get_track_name(trk_id:int) -> dict:
    logger.info(f"Processing trk_id: {trk_id}")
    try:
        url = BASE_URL + '/nascar/track.php?trk_id=' + str(trk_id)
        response = requests.get(url, proxies=working_proxy, headers=HEADERS)
        soup = BeautifulSoup(response.content, 'html.parser')
        page_header = soup.find('div', {'id': 'Div3Head'})
        if page_header is None:
            logger.debug((f"Track does not exist for trk_id: {trk_id}"))
            record_id_request_state('track', trk_id, 'DOES NOT EXIST', "trk_id does not correspond to a valid track")
            return None
        header_text = page_header.get_text(strip=True)
        header_text = header_text.replace('Cup Series Series Driver Ranking & Averages at ', '')
        trk_data = {'trk_id': trk_id, 'name': header_text}
        df = pd.DataFrame([trk_data])
        with get_connection() as conn:
            df.to_sql('track', conn, schema='drvavg', if_exists='append', index=False)
        record_id_request_state('track', trk_id, 'COMPLETE')
        return trk_data
    except Exception as e:
        record_id_request_state('track', trk_id, 'FAILED', str(e))
        logger.debug(url, e)


def get_car_number(carno_id:int) -> dict:
    logger.info(f"Processing carno_id: {carno_id}")
    try:
        url = BASE_URL + '/nascar/number.php?carno_id=' + str(carno_id)
        response = requests.get(url, proxies=working_proxy, headers=HEADERS)
        soup = BeautifulSoup(response.content, 'html.parser')
        page_header = soup.find('div', {'id': 'Div3Head'})
        if page_header is None:
            logger.debug((f"Car number does not exist for carno_id: {carno_id}"))
            record_id_request_state('car_number', carno_id, 'DOES NOT EXIST', "carno_id does not correspond to a valid car number")
            return None
        header_text = page_header.get_text(strip=True)
        car_number = header_text.replace('NASCAR Cup Series Car Number: #', '')
        car_number = car_number.replace(' ', '')
        carno_data = {'carno_id': carno_id, 'car_number': '#'+car_number}
        df = pd.DataFrame([carno_data])
        with get_connection() as conn:
            df.to_sql('car_number', conn, schema='drvavg', if_exists='append', index=False)
        record_id_request_state('car_number', carno_id, 'COMPLETE')
        return carno_data
    except Exception as e:
        record_id_request_state('car_number', carno_id, 'FAILED', str(e))
        logger.debug(url, e)


def get_team_names(team_now:int) -> list:
    logger.info(f"Processing team_now: {team_now}")

    try:
        url = BASE_URL + '/nascar/team.php?team_now=' + str(team_now)
        response = requests.get(url, proxies=working_proxy, headers=HEADERS)
        soup = BeautifulSoup(response.content, 'html.parser')
        page_header = soup.find('div', {'id': 'Div2Nav'})
        if page_header is None:
            logger.debug((f"Team does not exist for team_now: {team_now}"))
            record_id_request_state('team', team_now, 'DOES NOT EXIST', "team_now does not correspond to a valid team")
            return None
        header_text:str = page_header.find('h3').text
        team_text = header_text.strip().split('\n')
        team_names = team_text
        team_names_data  = [{'team_now':team_now, 'name':team_name.strip()} for team_name in team_names]
        df = pd.DataFrame(team_names_data)
        with get_connection() as conn:
            df.to_sql('team', conn, schema='drvavg', if_exists='append', index=False)
        record_id_request_state('team', team_now, 'COMPLETE')
        return team_names_data
    except Exception as e:
        record_id_request_state('team', team_now, 'FAILED', str(e))
        logger.debug(url, e)

with get_connection() as conn:
    existing_team_nows = pd.read_sql_query("SELECT [id] FROM [req].[id_request_log] WHERE [table] = 'team'", conn)['id'].tolist()
    existing_carno_ids = pd.read_sql_query("SELECT [id] FROM [req].[id_request_log] WHERE [table] = 'car_number'", conn)['id'].tolist() 
    existing_trk_ids = pd.read_sql_query("SELECT [id] FROM [req].[id_request_log] WHERE [table] = 'track'", conn)['id'].tolist()
    existing_drv_ids = pd.read_sql_query("SELECT [id] FROM [req].[id_request_log] WHERE [table] = 'driver'", conn)['id'].tolist()
    existing_sked_ids = pd.read_sql_query("SELECT [id] FROM [req].[id_request_log] WHERE [table] = 'race_result'", conn)['id'].tolist()


track_ids = [trk_id for trk_id in range(MAX_TRK_ID) if trk_id not in existing_trk_ids]
car_number_ids = [carno_id for carno_id in range(MAX_CARNO_ID) if carno_id not in existing_carno_ids]
driver_ids = [drv_id for drv_id in range(MAX_DRV_ID) if drv_id not in existing_drv_ids]
team_nows = [team_now for team_now in range(MAX_TEAM_NOW) if team_now not in existing_team_nows]
sked_ids = [sked_id for sked_id in get_sked_ids() if sked_id not in existing_sked_ids]

[get_track_name(trk_id) for trk_id in track_ids]
[get_car_number(carno_id) for carno_id in car_number_ids]
[get_driver_name(drv_id) for drv_id in driver_ids]
[get_team_names(team_now) for team_now in team_nows]
[get_race_results(sked_id) for sked_id in sked_ids]