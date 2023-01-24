#!/bin/bash

set -eu

# CA Key 와 CA CRT 생성
# X.509는 PKI 기술 중에서 가장 널리 알려진 표준 포맷
openssl req -nodes -new -x509 -keyout ca.key -out ca.crt -subj "/CN=Admission Controller Webhook Demo CA" -sha256

# 서버 Key 생성
openssl genrsa -out server.key 2048

# server.conf 생성
cat >server.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
prompt = no
[req_distinguished_name]
CN = admission-controller-server.default.svc
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = admission-controller-server.default.svc
EOF

# CSR 생성
openssl req -new -key server.key -out server.csr -config server.conf

# Server CRT 생성
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -extensions v3_req -extfile server.conf -sha256