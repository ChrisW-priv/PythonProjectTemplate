FROM python:3.12-slim AS python-base

    # python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"


# prepend path with venv path
ENV PATH="$VENV_PATH/bin:$PATH"

# `builder-base-common` stage is used to build deps + create our virtual environment
FROM python-base AS builder-base

WORKDIR $PYSETUP_PATH

RUN python3 -m venv .venv

COPY projectPackage projectPackage
RUN pip install -e projectPackage

# developement will be build to serve final steps of installing venv and alike
FROM python-base AS development

# copy in our built venv
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

WORKDIR $PYSETUP_PATH

CMD ["tail", "/dev/null"]

# To run this interactively (assuming it was tagged "test_dev":
#docker run --entrypoint "/bin/bash" -it test_dev