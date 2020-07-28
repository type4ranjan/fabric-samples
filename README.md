[//]: # (SPDX-License-Identifier: CC-BY-4.0)

# Hyperledger Fabric Samples

This repo contains Hyperledger Fabric Samples where the first-network example
has been adapted for Thales Luna Network and DPoD HSMs.

## Build Binaries with PKCS11 support

```bash
# This script will clone the Hyperledger fabric repo and fabric-ca repo, checkout
# a specific tag and build the fabric binaries with PKCS11 support.
./build-hsm.sh
```

## Setup Luna HSM Partitions for BYFN

Configure the Luna client so that it has 3 partitions labeled org1.example.com, org2.examples.com and orderer.example.com with partition password "userpin".

## Setup DPoD HSM Partitions for BYFN

Create three DPoD services, download the clients and install them at:

```bash
/etc/hyperledger/fabric/dpod/org1.example.com
/etc/hyperledger/fabric/dpod/org2.example.com
/etc/hyperledger/fabric/dpod/orderer.example.com
```
Configure all three partitions with the corresponding label and with partition password "userpin".

## Configure the fabric-ca-client

Run the fabric-ca-client gencsr command to create the fabric-ca-client-config.yaml file (if it doesn't already exist).

```bash
./bin/fabric-ca-client gencsr
```

Modify the bccsp section of ~/.fabric-ca-client/fabric-ca-client-config.yaml to:

```
bccsp:
    default: PKCS11
    sw:
        hash: SHA2
        security: 256
        filekeystore:
            # The directory used for the software file-based keystore
            keystore: msp/keystore
    pkcs11:
        hash: SHA2
        security: 384
        library: /usr/safenet/lunaclient/lib/libCryptoki2_64.so
        label:
        pin:
```

Specify the keyrequest settings for the csr section of ~/.fabric-ca-client/fabric-ca-client-config.yaml as follows:

```
csr:
  cn:
  keyrequest:
    algo: ecdsa
    size: 384
```
## Run the first-network-luna example for Luna Network HSMs

```bash
# Change directory to the first-network-luna directory
cd first-network-luna
# Generate the crypto material in the HSM partitions, create CSRs and issue certficates
./byfn.sh generate
# Run the first-network-luna example
./byfn.sh up -i 1.4.8
```

## Run the first-network-dpod example for DPoD HSMs

```bash
# Change directory to the first-network-dpod directory
cd first-network-dpod
# Generate the crypto material in the HSM partitions, create CSRs and issue certficates
./byfn.sh generate
# Run the first-network-luna example
./byfn.sh up -i 1.4.8
```

## Bring Down the Network
After the first-network example has been run, the docker containers can be stopped using the following command:
```bash
./byfn.sh down -i 1.4.8
```

## License <a name="license"></a>

Hyperledger Project source code files are made available under the Apache
License, Version 2.0 (Apache-2.0), located in the [LICENSE](LICENSE) file.
Hyperledger Project documentation files are made available under the Creative
Commons Attribution 4.0 International License (CC-BY-4.0), available at http://creativecommons.org/licenses/by/4.0/.
