FROM python:3.12-trixie
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app
COPY pyproject.toml uv.lock .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen

COPY src entrypoint.sh .
COPY templates/ templates/

EXPOSE 8000/TCP
ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["uv", "run", "seapop-wizard"]
