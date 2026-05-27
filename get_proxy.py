import requests
from bs4 import BeautifulSoup
import random
from config import BASE_URL

# URL to fetch free proxies
proxy_list_url = "https://www.sslproxies.org/"

def get_proxies() -> list:
    # Get the proxy list from the free proxy website
    response = requests.get(proxy_list_url)
    response.raise_for_status()  # Ensure the request was successful
    soup = BeautifulSoup(response.content, 'html.parser')
    
    proxy_table = soup.find('table', {'class': 'table table-striped table-bordered'})
    if not proxy_table:
        raise ValueError("Could not find the proxy list table on the page.")

    proxies = []
    for row in proxy_table.find_all('tr')[1:]:
        cells = row.find_all('td')
        if cells:
            ip = cells[0].text.strip()
            port = cells[1].text.strip()
            proxies.append(f"{ip}:{port}")
    return proxies

def get_working_proxy(proxies:list, test_url):
    random.shuffle(proxies)
    for proxy in proxies:
        proxies_dict = {
            "http": f"http://{proxy}",
            "https": f"http://{proxy}"
        }
        try:
            # Test the proxy with the target URL
            response = requests.get(test_url, proxies=proxies_dict, timeout=5)
            if response.status_code == 200:
                return proxies_dict
        except:
            continue
    return None

proxies = get_proxies()
working_proxy = get_working_proxy(proxies, BASE_URL)