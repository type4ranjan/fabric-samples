#!/bin/bash
##########################################################################
# This script generates certificates and keys to work with the cryptogen util
# to be used with the hyperledger fabric BYFN example.
# This allows the keys for the certificate to be generated with the
# PKCS11 BCCSP which in turn allows keys to be generated in an HSM.
##########################################################################

CA_CLIENT=./bin/fabric-ca-client
CRYPTO_CONFIG=$PWD/crypto-config
ROOT=$PWD
BCCSP_DEFAULT=PKCS11
PIN=userpin
check_error() {
  if [ $? -ne 0 ]; then
    echo "ERROR: Something went wrong!"
    exit 1
  fi
}

signcsr() {
  MSP=$1
  CN=$2
  CA_DIR=$3
  CA_NAME=$4
  CA_CERT=$(find $CA_DIR -name "*.pem")
  CA_KEY=$(find $CA_DIR -name "*_sk")
  CSR=$MSP/signcerts/$CN.csr
  CERT=$MSP/signcerts/$CN-cert.pem
  openssl x509 -req -sha256 -days 3650 -in $CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $CERT
  check_error
}

genmsp() {
  ORG_DIR=$1
  ORG_NAME=$2
  NODE_DIR=$3
  NODE_NAME=$4
  NODE_OU=$6
  CN=${NODE_NAME}${ORG_NAME}
  CA_PATH=$CRYPTO_CONFIG/$ORG_DIR/$ORG_NAME
  NODE_PATH=$CA_PATH/$NODE_DIR/$CN
  MSP=$NODE_PATH/msp
  TLS=$NODE_PATH/tls
  LABEL=$5
  rm -rf $MSP/keystore/*
  rm -rf $MSP/signcerts/*
  echo $LABEL
  export FABRIC_CA_CLIENT_BCCSP_DEFAULT=$BCCSP_DEFAULT
  export FABRIC_CA_CLIENT_BCCSP_PKCS11_LABEL=$LABEL
  export FABRIC_CA_CLIENT_BCCSP_PKCS11_PIN=$PIN
  $CA_CLIENT gencsr --csr.cn $CN --mspdir $MSP --csr.names "C=US,ST=California,L=San Francisco,OU=$NODE_OU"
  check_error
  signcsr $MSP $CN $CA_PATH/ca $ORG_NAME
 }

copy_admin_cert_node() {
  ORG_DIR=$1
  ORG_NAME=$2
  NODE_DIR=$3
  NODE_NAME=$4
  CN=$NODE_NAME.$ORG_NAME
  CA_PATH=$CRYPTO_CONFIG/$ORG_DIR/$ORG_NAME
  NODE_PATH=$CA_PATH/$NODE_DIR/$CN
  MSP=$NODE_PATH/msp
  ADMIN_CN=Admin@$ORG_NAME
  ADMIN_CERT=$CA_PATH/users/$ADMIN_CN/msp/signcerts/$ADMIN_CN-cert.pem
  cp $ADMIN_CERT $NODE_PATH/msp/admincerts
  check_error
 }

copy_admin_cert_ca() {
  ORG_DIR=$1
  ORG_NAME=$2
  CA_PATH=$CRYPTO_CONFIG/$ORG_DIR/$ORG_NAME
  ADMIN_CN=Admin@$ORG_NAME
  ADMIN_CERT=$CA_PATH/users/$ADMIN_CN/msp/signcerts/$ADMIN_CN-cert.pem
  cp $ADMIN_CERT $CA_PATH/msp/admincerts
  check_error
  cp $ADMIN_CERT $CA_PATH/users/$ADMIN_CN/msp/admincerts
  check_error
}

for org in 1 2; do
  for peer in 0 1; do
    genmsp peerOrganizations org${org}.example.com peers peer${peer}. org${org}.example.com peer
  done
  genmsp peerOrganizations org${org}.example.com users Admin@ org${org}.example.com client
  for peer in 0 1; do
    copy_admin_cert_node peerOrganizations org${org}.example.com peers peer${peer}
  done
  copy_admin_cert_ca peerOrganizations org${org}.example.com
done
genmsp ordererOrganizations example.com orderers orderer. orderer.example.com orderer
genmsp ordererOrganizations example.com users Admin@ orderer.example.com client
copy_admin_cert_node ordererOrganizations example.com orderers orderer orderer.example.com
copy_admin_cert_ca ordererOrganizations example.com
