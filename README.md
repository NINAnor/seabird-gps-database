# Configuration

## Secrets

Generate passwords and tokens randomly:

```bash
docker compose --file setup/docker-compose.yml build
docker compose --file setup/docker-compose.yml run --rm setup
```

## S3 Storage

The application now uses S3 for file storage using universal-pathlib. You need to configure the following environment variables:

- `S3_BUCKET`: The S3 bucket name
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

For non-AWS S3-compatible storage (e.g., MinIO, DigitalOcean Spaces), also set:
- `AWS_S3_ENDPOINT`: The S3 endpoint URL (e.g., `https://nyc3.digitaloceanspaces.com`)

Add these to your environment variables.

# Run

```bash
docker compose --env-file secrets/docker --env-file secrets/tokens up --build
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
