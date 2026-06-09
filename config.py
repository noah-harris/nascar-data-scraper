BASE_URL = 'https://www.driveraverages.com'

MAX_TRK_ID = 300
MAX_CARNO_ID = 1000
MAX_DRV_ID = 5000
MAX_TEAM_NOW = 4000
MAX_RACE_NO = 99

from get_proxy import working_proxy

import logging
import colorlog

def make_logger(name: str) -> logging.Logger:
    root = logging.getLogger()
    if not root.handlers:
        handler = colorlog.StreamHandler()
        handler.setFormatter(colorlog.ColoredFormatter(
            fmt='%(log_color)s[%(asctime)s] [%(levelname)s] %(message)s',
            datefmt="%H:%M:%S"
        ))
        root.addHandler(handler)
        root.setLevel(logging.DEBUG)
    return logging.getLogger(name)

logger = make_logger('nascar-data-scraper')