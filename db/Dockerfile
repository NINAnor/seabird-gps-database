FROM ghcr.io/amacneil/dbmate as dbmate
COPY migrations/ db/migrations/
COPY entrypoint.sh .
ENTRYPOINT ["/entrypoint.sh"]
CMD ["dbmate", "--no-dump-schema", "up"]
