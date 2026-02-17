FROM python:3.12-trixie
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app
COPY pyproject.toml uv.lock .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project

COPY src entrypoint.sh .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen

ENV AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED
ENV AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED

EXPOSE 8000/TCP
ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["uv", "run", "wizard"]
