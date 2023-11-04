#!/bin/sh

if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ] && [ ! -z "${CERT}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:11:22'}" --cert "$CERT" --token "$TOKEN" rtsp -s "$RTSP_URL"
fi

if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${UNIFI_EMAIL}" ] && [ ! -z "${UNIFI_PASSWORD}" ] && [ ! -z "${CERT}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:11:22'}" --cert "$CERT" --nvr-username "$UNIFI_EMAIL" --nvr-password "$UNIFI_PASSWORD" rtsp -s "$RTSP_URL" --model  "UVC G4 Pro"
fi

exec "$@"
