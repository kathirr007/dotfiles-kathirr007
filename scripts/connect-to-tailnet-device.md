Working end-state summary for Codespaces -> k007vault (100.89.182.70) via Tailscale SSH, no nc needed:
One-time (home/admin, already done):
1. Target: tailscale set --ssh -> SSH badge on Machines page.
2. Policies > Tailscale SSH > Add rule: src: autogroup:member (or your email / codespace tag if key is tagged) -> dst: tag:server as root, check-mode off (accept). General rules must allow :22.
Per-Codespace (you run):
1. Get ephemeral auth-key: Admin > Settings > Keys > Generate (ephemeral, reusable if retrying).
2. Install + start daemon in userspace mode:
curl -fsSL https://tailscale.com/install.sh | sh
sudo mkdir -p /var/run/tailscale /var/lib/tailscale
sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock > /tmp/tailscaled.log 2>&1 &
sleep 3; cat /tmp/tailscaled.log # expect NeedsLogin, not fatal
ls -l /var/run/tailscale/ # tailscaled.sock srw-rw-rw-
3. Join (same socket, same sudo every time):
sudo tailscale up --auth-key=tskey-auth-... --hostname=codespace-office --accept-dns=false
sudo tailscale status | grep k007vault
sudo tailscale whois 100.89.182.70
sudo tailscale ping 100.89.182.70
4. SSH (keep sudo consistent to avoid /root vs /home/codespace known_hosts split):
sudo tailscale ssh --force-reauth root@100.89.182.70
# next times:
sudo tailscale ssh root@100.89.182.70
# or by name: sudo tailscale ssh root@k007vault
If stuck:
- dial ... connection refused = stale pid/socket mismatch. sudo pkill -9 tailscaled; sudo rm -f ...sock, restart step 2 with one socket path.
- No host key... = ran without sudo or without --force-reauth on first connect, or ACL tag:server rule missing.
- idle, tx/rx in status is fine (DERP relay in Codespaces).