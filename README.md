# Configuration

## Secrets

Generate passwords and tokens randomly:

```bash
docker compose --file setup/docker-compose.yml build
docker compose --file setup/docker-compose.yml run --rm setup
```

# Run

```bash
docker compose --env-file secrets/docker up --build
```

# Use the API

## Import CSV data

```bash
source secrets/tokens
curl http://localhost:3000/import \
    -H "Authorization: Bearer $WRITER_TOKEN" \
    -H "Content-Type: text/csv" \
    --data-binary @- < file.csv
```
