
# CYBERPROBE_VERSION=1.9.12
# CYBERPROBE_PKG=fedora-cyberprobe-${CYBERPROBE_VERSION}-1.fc25.x86_64.rpm 

all: ${CYBERPROBE_PKG} crypto.tgz

# fedora-cyberprobe-${CYBERPROBE_VERSION}-1.fc27.x86_64.rpm:
# 	wget -O$@ https://github.com/cybermaggedon/cyberprobe/releases/download/v${CYBERPROBE_VERSION}/$@

CRYPTO_FILES=\
	create config.ca config.server client.conf cyberprobe.cfg \
	probe-key.vpn probe-cert.vpn probe-cert.ca Makefile.certs

crypto.tgz: ${CRYPTO_FILES}
	tar cfz $@ ${CRYPTO_FILES}

