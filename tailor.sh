#!/bin/bash

s3=$(wget -q -O- http://169.254.169.254/latest/user-data)

if [ "$s3" != "" ]
then

  if [ ! -d /key ]
  then
    mkdir /key
  fi

fi

aws s3 cp ${s3}/ipsec-creds/cert.ca /etc/strongswan/ipsec.d/cacerts/cert.ca
aws s3 cp ${s3}/ipsec-creds/cert.ca /key/cert.ca
aws s3 cp ${s3}/ipsec-creds/key.server /key/key.server
aws s3 cp ${s3}/ipsec-creds/cert.server /key/cert.server
aws s3 cp ${s3}/vpn-creds/cert.allocator /key/cert.allocator
aws s3 cp ${s3}/vpn-creds/key.allocator /key/key.allocator

aws s3 cp ${s3}/probe-creds/cert.vpn /probe-creds/cert.vpn
aws s3 cp ${s3}/probe-creds/key.vpn /probe-creds/key.vpn
aws s3 cp ${s3}/probe-creds/cert.ca /probe-creds/cert.ca

aws s3 cp ${s3}/cyberprobe.cfg /etc/cyberprobe.cfg

# The cyberprobe.cfg was written for OpenVPN using TUN interface, IPsec
# uses Virtual IP in eth0.
sed -i 's/tun0/eth0/' /etc/cyberprobe.cfg

# Fix SELinux attributes
chcon -R system_u:object_r:ipsec_key_file_t:s0 /key/
chcon -R system_u:object_r:ipsec_key_file_t:s0 /probe-creds/
restorecon -R /etc/strongswan

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

