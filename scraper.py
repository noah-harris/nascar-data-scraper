import requests
from bs4 import BeautifulSoup
from datetime import datetime
from config import *
from db import get_connection
import pandas as pd



def get_sked_ids() -> list:
    sked_ids = []
    for series in nascar_series.values():
        series_index = series.get('series_index')
        current_year = int(datetime.now().year)
        first_year = int(series.get('first_year'))
        for year in range(current_year-first_year+1):
            year = year + first_year
            for race_no in range(MAX_RACE_NO):
                sked_id = str(year)+str(series_index)+str(race_no+1).zfill(2)
                sked_ids.append(int(sked_id))
    return sked_ids


def get_race_results(sked_id:int) -> pd.DataFrame:
    logger.info(f"Processing sked_id: {sked_id}")
    try:
        # if sked_id not in existing_sked_ids:
            series_number = int(str(sked_id)[4])
            match series_number:
                case 0:
                    series = 'nascar'
                case 5:
                    series = 'nascar_xfinityseries'
                case 7:
                    series = 'nascar_truckseries'
                case _:
                    series = None
            current_year = int(str(sked_id)[0:4])
            race_number = int(str(sked_id)[5:6])
            url = BASE_URL + '/'+series+'/race.php?sked_id='+str(sked_id)
            response = requests.get(url, working_proxy)
            soup = BeautifulSoup(response.content, 'html.parser')
            tables = soup.find_all('table', {'class': 'sortable tabledata-nascar table-large'}, limit=1)
            if not tables:
                logger.debug(f"No race found for sked_id: {sked_id} @ url: {url}")
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
                'year': current_year,
                'series': series,
                'race_no': race_number,
                'event_name': event_name,
                'track': track,
                'date': date,
                'event_info': event_info,
                'finish': row.get('Finish'),
                'start': row.get('Start'),
                'car_no': row.get('#'),
                'driver_name': row.get('Driver'),
                'make': row.get('Make'),
                'pts': row.get('Pts'),
                'laps': row.get('Laps'),
                'laps_led': row.get('Led'),
                'status': row.get('Status'),
                'team': row.get('Team'),
                'stage_1': row.get('S1'),
                'stage_2': row.get('S2'),
                'stage_3': row.get('S3'),
                'rating': row.get('Rating')
            } for row in table_data]
            df = pd.DataFrame(result_data)
            with get_connection() as conn:
                df.to_sql('race_result', conn, schema='api', if_exists='append', index=False)
            return df
    except Exception as e:
        url = BASE_URL + '/'+series+'/race.php?sked_id='+str(sked_id)
        logger.debug(url, e)


def get_driver_name(drv_id:int) -> dict:
    logger.info(f"Processing drv_id: {drv_id}")
    try:
        if drv_id not in existing_drv_ids:
            url = BASE_URL + '/nascar/driver.php?drv_id=' + str(drv_id)
            response = requests.get(url, working_proxy)
            soup = BeautifulSoup(response.content, 'html.parser')
            page_header = soup.find('div', {'id': 'Div3Head'})
            if page_header is None:
                logger.debug((f"Driver does not exist for drv_id: {drv_id}"))
                return None
            header_text = page_header.get_text(strip=True)
            header_text = header_text.replace(' NASCAR Cup Series Series Hub', '')
            driver_data =  {'drv_id': drv_id, 'name': header_text}
            df = pd.DataFrame([driver_data])
            with get_connection() as conn:
                df.to_sql('driver', conn, schema='api', if_exists='append', index=False)
            return driver_data
    except Exception as e:
        logger.debug(url, e)
    

def get_track_name(trk_id:int) -> dict:
    logger.info(f"Processing trk_id: {trk_id}")
    try:
        if trk_id not in existing_trk_ids:
            url = BASE_URL + '/nascar/track.php?trk_id=' + str(trk_id)
            response = requests.get(url, working_proxy)
            soup = BeautifulSoup(response.content, 'html.parser')
            page_header = soup.find('div', {'id': 'Div3Head'})
            if page_header is None:
                logger.debug((f"Track does not exist for trk_id: {trk_id}"))
                return None
            header_text = page_header.get_text(strip=True)
            header_text = header_text.replace('Cup Series Series Driver Ranking & Averages at ', '')
            trk_data = {'trk_id': trk_id, 'name': header_text}
            df = pd.DataFrame([trk_data])
            with get_connection() as conn:
                df.to_sql('track', conn, schema='api', if_exists='append', index=False)
            return trk_data
    except Exception as e:
        logger.debug(url, e)


def get_car_number(carno_id:int) -> dict:
    logger.info(f"Processing carno_id: {carno_id}")
    try:
        if carno_id not in existing_carno_ids:
            url = BASE_URL + '/nascar/number.php?carno_id=' + str(carno_id)
            response = requests.get(url, working_proxy)
            soup = BeautifulSoup(response.content, 'html.parser')
            page_header = soup.find('div', {'id': 'Div3Head'})
            if page_header is None:
                logger.debug((f"Car number does not exist for carno_id: {carno_id}"))
                return None
            header_text = page_header.get_text(strip=True)
            car_number = header_text.replace('NASCAR Cup Series Car Number: #', '')
            car_number = car_number.replace(' ', '')
            carno_data = {'carno_id': carno_id, 'car_number': '#'+car_number}
            df = pd.DataFrame([carno_data])
            with get_connection() as conn:
                df.to_sql('car_number', conn, schema='api', if_exists='append', index=False)
            return carno_data
    except Exception as e:
        logger.debug(url, e)


def get_team_names(team_now:int) -> list:
    logger.info(f"Processing team_now: {team_now}")
    try:
        if team_now not in existing_team_nows:
            url = BASE_URL + '/nascar/team.php?team_now=' + str(team_now)
            response = requests.get(url, working_proxy)
            soup = BeautifulSoup(response.content, 'html.parser')
            page_header = soup.find('div', {'id': 'Div2Nav'})
            header_text:str = page_header.find('h3').text
            if header_text is None:
                logger.debug((f"Team does not exist for team_now: {team_now}"))
            team_text = header_text.strip().split('\n')
            team_names = team_text
            team_names_data  = [{'team_now':team_now, 'name':team_name.strip()} for team_name in team_names]
            df = pd.DataFrame(team_names_data)
            with get_connection() as conn:
                df.to_sql('team', conn, schema='api', if_exists='append', index=False)
            return team_names_data
    except Exception as e:
        logger.debug(url, e)

sked_ids = get_sked_ids()

with get_connection() as conn:
    existing_team_nows = pd.read_sql_query('SELECT DISTINCT [team_now] FROM [api].[team]', conn)['team_now'].tolist()
    existing_drv_ids = pd.read_sql_query('SELECT DISTINCT [drv_id] FROM [api].[driver]', conn)['drv_id'].tolist()
    existing_trk_ids = pd.read_sql_query('SELECT DISTINCT [trk_id] FROM [api].[track]', conn)['trk_id'].tolist()
    existing_carno_ids = pd.read_sql_query('SELECT DISTINCT [carno_id] FROM [api].[car_number]', conn)['carno_id'].tolist() 
    existing_sked_ids = pd.read_sql_query('SELECT DISTINCT [sked_id] FROM [api].[race_result]', conn)['sked_id'].tolist()


# [get_track_name(trk_id) for trk_id in range(MAX_TRK_ID)]
    
# [get_car_number(carno_id) for carno_id in range(MAX_CARNO_ID)]

# [get_driver_name(drv_id) for drv_id in range(MAX_DRV_ID)]

[get_team_names(team_now) for team_now in range(MAX_TEAM_NOW)]

[get_race_results(sked_id) for sked_id in sked_ids]
