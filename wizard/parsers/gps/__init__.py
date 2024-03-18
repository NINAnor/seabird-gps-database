from .gpx import GPXParser
from .igotu import PARSERS as IGOUT
from .catlog import PARSERS as CATLOG
from .base import PARSERS as BASE
from .jm import PARSERS as JM 
from .unknown import PARSERS as UNKNOWN
from .pathtrack import PARSERS as PATHTRACK
from .ho11 import PARSERS as HO11
from .axytrek import PARSERS as AXYTREK

PARSERS = [
    GPXParser,
] + IGOUT + CATLOG + BASE + JM + UNKNOWN + PATHTRACK + HO11 + AXYTREK
