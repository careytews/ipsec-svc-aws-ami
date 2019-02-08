#!/bin/sh

echo '----- Config script starting --------------------------------------'

dnf -y update
dnf install -y lua-socket lua-json
dnf install -y tar
dnf install -y luarocks
dnf install -y cppzmq-devel
dnf install -y gcc
dnf install -y lua-devel
dnf install -y findutils
dnf install -y net-tools
dnf install -y iptables
dnf install -y boost-program-options boost-regex readline
luarocks install lzmq
luarocks install uuid
dnf install -y python python-zmq python-requests python-httplib2
pip install --upgrade google-api-python-client
pip install cassandra-driver
luarocks install redis-lua
luarocks install uuid

dnf install -y strongswan
dnf install -y python-pip
pip install vici

dnf install -y awscli
dnf install -y wget

cat <<EOF > /etc/yum.repos.d/trust-networks.repo
[trustnetworks]
name=Trust Networks
baseurl=http://download.trustnetworks.com/fedora/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=http://download.trustnetworks.com/trust-networks.asc
EOF

dnf install -y cyberprobe

cat <<EOF > /lib/systemd/system/tailoring.service

[Unit]
Description=Local tailor
Before=strongswan.service cyberprobe.service ipsec-addr-sync.service
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/tailor
Type=oneshot

[Install]
WantedBy=multi-user.target

EOF

cat <<EOF > /lib/systemd/system/ipsec-addr-sync.service

[Unit]
Description=StrongSwan to cyberprobe sync service
Wants=strongswan.service
After=strongswan.service

[Service]
PIDFile=/var/run/ipsec-addr-sync.pid
ExecStart=/usr/local/bin/ipsec-addr-sync

[Install]
WantedBy=multi-user.target

EOF

cat <<EOF > /lib/systemd/system/dhcp-service.service

[Unit]
Description=DHCP to address allocator service
Wants=tailoring.service
After=tailoring.service

[Service]
PIDFile=/var/run/cyberprobe.pid
ExecStart=/usr/local/bin/dhcp-server

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload

systemctl enable cyberprobe
systemctl enable ipsec-addr-sync
systemctl enable strongswan
systemctl enable tailoring
systemctl enable dhcp-service

cp /tmp/tailor /usr/local/bin/tailor
chmod 755 /usr/local/bin/tailor

cp /tmp/create /usr/local/bin/create
chmod 755 /usr/local/bin/create

cp /tmp/ipsec-addr-sync /usr/local/bin/ipsec-addr-sync
chmod 755 /usr/local/bin/ipsec-addr-sync

cp /tmp/ipsec.conf /etc/strongswan/ipsec.conf
chmod 644 /etc/strongswan/ipsec.conf

cp /tmp/ipsec.secrets /etc/strongswan/ipsec.secrets
chmod 644 /etc/strongswan/ipsec.secrets

cp /tmp/dhcp.conf /etc/strongswan/strongswan.d/charon/dhcp.conf
chmod 644 /etc/strongswan/strongswan.d/charon/dhcp.conf

cp /tmp/dhcp-server /usr/local/bin/dhcp-server
chmod 755 /usr/local/bin/dhcp-server

# Triggers action in tailor
rm -f /etc/cyberprobe.cfg

echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

echo '----- Config script done ------------------------------------------'

