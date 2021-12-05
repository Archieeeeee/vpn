systemctl stop warp-svc

warp-cli --accept-tos delete
warp-cli --accept-tos register
warp-cli --accept-tos set-mode proxy
warp-cli --accept-tos set-proxy-port 10802
warp-cli --accept-tos connect
sleep 3;
warp-cli --accept-tos status
