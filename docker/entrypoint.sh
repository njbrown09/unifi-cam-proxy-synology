#!/bin/sh

# Define the path for the certificate
CERT_PATH="/unifi/certs/client.pem"

# Check if client.pem exists at the designated path, if not, create it
if [ ! -f "${CERT_PATH}" ]; then
  echo "client.pem not found at ${CERT_PATH}, creating it..."
  openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
  openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
  openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
  cat /tmp/private.key /tmp/public.key > "${CERT_PATH}"
  rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
else
  echo "client.pem already exists at ${CERT_PATH}, using existing certificate."
fi

# Check that CAMERA_MODEL is not blank
if [ -z "${CAMERA_MODEL}" ]; then
  echo "CAMERA_MODEL environment variable is not set. Exiting..."
  exit 1
fi

# Check if the required variables are set for token authentication
if [ ! -z "${RTSP_URL}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ] && [ -z "${UNIFI_EMAIL}" ] && [ -z "${UNIFI_PASSWORD}" ]; then
  echo "Using RTSP stream from $RTSP_URL with token authentication"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-AA:BB:CC:00:11:22}" --cert "${CERT_PATH}" --token "$TOKEN" --model "$CAMERA_MODEL" rtsp -s "$RTSP_URL"
elif [ ! -z "${RTSP_URL}" ] && [ ! -z "${HOST}" ] && [ ! -z "${UNIFI_EMAIL}" ] && [ ! -z "${UNIFI_PASSWORD}" ] && [ -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL with NVR credentials"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-AA:BB:CC:00:11:22}" --cert "${CERT_PATH}" --nvr-username "$UNIFI_EMAIL" --nvr-password "$UNIFI_PASSWORD" --model "$CAMERA_MODEL" rtsp -s "$RTSP_URL"
else
  echo "Error: RTSP_URL, HOST, and either TOKEN or UNIFI_EMAIL and UNIFI_PASSWORD must be set. Exiting..."
  exit 1
fi

exec "$@"
