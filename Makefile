
VERSION=$(shell git describe | sed 's/^v//')

all: dhcp-server

dhcp-server: dhcp-server.go godeps
	GOPATH=$$(pwd)/go go build dhcp-server.go

godeps: go go/.dhcp

go:
	mkdir go

go/.dhcp:
	GOPATH=$$(pwd)/go go get github.com/krolaw/dhcp4
	touch $@

