FROM python:3.8-slim-buster

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y --no-install-recommends tini procps net-tools && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/*

COPY requirements/main.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

RUN useradd --create-home appuser
USER appuser
WORKDIR /home/appuser

COPY --chown=appuser . .

ENV PYTHONFAULTHANDLER=1

ARG MG_SETTINGS_FILE=example_settings.py
COPY $MG_SETTINGS_FILE mg_settings.py
ENV MONGOGRANT_SETTINGS=mg_settings.py

ENTRYPOINT ["tini", "--", "./entrypoint.sh"]