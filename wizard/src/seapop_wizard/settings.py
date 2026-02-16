from environ import Env
from jinja2 import Environment, PackageLoader, select_autoescape
from upath import UPath

from seapop_wizard.logger import configure_logger

env = Env()

SENTRY_DSN = env("SENTRY_DSN", default=None)
if SENTRY_DSN:
    import sentry_sdk

    sentry_sdk.init(dsn=SENTRY_DSN)

template_engine = Environment(
    loader=PackageLoader("seapop_wizard", "templates"), autoescape=select_autoescape()
)


log = configure_logger(env("LOGGING", default="INFO"))

POSTGREST_URL = env("POSTGREST_URL", default="http://localhost:3000")
POSTGREST_TOKEN = env("POSTGREST_TOKEN")
TO_PARQUET = env("TO_PARQUET", default="False").lower() in ("true", "1", "t")
ACCEPTED_EXTENSIONS = env(
    "ACCEPTED_EXTENSIONS", default=".csv,.pos,.gpx,.txt,.log"
).split(",")
ACCEPTED_EXTENSIONS += [ext.upper() for ext in ACCEPTED_EXTENSIONS]

# S3 Configuration
S3_BUCKET = env("S3_BUCKET")
S3_PREFIX = env("S3_PREFIX", default="")

# S3 paths using UPath
LOGGERS_PATH = UPath(f"s3://{S3_BUCKET}/{S3_PREFIX}loggers")
METADATA_PATH = UPath(f"s3://{S3_BUCKET}/{S3_PREFIX}metadata")
PARQUET_PATH = UPath(f"s3://{S3_BUCKET}/{S3_PREFIX}parquet")

# Ensure S3 directories exist
PATHS = [LOGGERS_PATH, METADATA_PATH, PARQUET_PATH]
for path in PATHS:
    path.mkdir(exist_ok=True)
