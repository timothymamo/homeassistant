#!/usr/bin/env bash

HA_TOKEN="$1"
IP_CHECK="$2"

VPN_URL="http://icanhazip.com/"
SENSOR_API="http://localhost:8123/api/states/sensor.vpn_status"

VPN_RESULT=$(/usr/bin/curl "${VPN_URL}" 2>/dev/null)

if [[ "${VPN_RESULT}" = "${IP_CHECK}"* ]]; then
  SENSOR_STATE=$(/usr/bin/curl -X GET -H "Authorization: Bearer ${HA_TOKEN}" "${SENSOR_API}" 2>/dev/null | jq '.state')
  if [[ "${SENSOR_STATE}" != "off" ]]; then 
      /usr/bin/curl -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"state": "off","attributes": {"friendly_name":"VPN Status Check","message":"VPN is connected"}}' "${SENSOR_API}"
  fi
else
  sleep 60
  VPN_RESULT=$(/usr/bin/curl "${VPN_URL}" 2>/dev/null)
  SENSOR_STATE=$(/usr/bin/curl -X GET -H "Authorization: Bearer ${HA_TOKEN}" "${SENSOR_API}" 2>/dev/null | jq '.state')
  if [[ "${SENSOR_STATE}" != "off" ]]; then 
      /usr/bin/curl -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"state": "off","attributes": {"friendly_name":"VPN Status Check","message":"VPN is connected"}}' "${SENSOR_API}"
  else
    /usr/bin/curl -X POST -H "Authorization: Bearer ${HA_TOKEN}" \
      -H "Content-Type: application/json" \
      -d '{"state": "on","attributes": {"friendly_name":"VPN Status Check","message":"VPN is NOT connected!!"}}' "${SENSOR_API}"
  fi
fi