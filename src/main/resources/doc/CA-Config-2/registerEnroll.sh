#!/bin/bash
## 工作目录,除非特殊说明，一般命令的执行都是在工作目录进行。
## cd $GOPATH/src/github.com/hyperledger/fabric-samples/first

## 首次运行清除docker影响

docker-compose -f docker-compose-ca.yaml  down --volumes --remove-orphans

## docker ps -a|awk '{print $1}'|xargs -i docker stop {}
## docker ps -a|awk '{print $1}'|xargs -i docker rm {}

## docker rm -f $(docker ps -a | awk '($2 ~ /dev-peer.*/) {print $1}')

## export PWD=$GOPATH/src/github.com/hyperledger/fabric-samples/first-ca

## 启动CA服务
docker-compose -f docker-compose-ca.yaml up -d 2>&1


## 登陆
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/tls-ca/admin
fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-adminpw@0.0.0.0:7052

## 注册
# 为各个组件(组件指的是 peer,order和管理员)注册TLS证书,仅仅是注册了身份,并没有获取到证书;
fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type admin -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name admin-org2 --id.secret org2AdminPW --id.type admin -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer2-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer3-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer4-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer5-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052




## 登录
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/ca/admin
fabric-ca-client enroll -d -u https://org0-admin:org0-adminpw@0.0.0.0:7053

## 注册
fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererpw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' -u https://0.0.0.0:7053
fabric-ca-client register -d --id.name orderer2-org0 --id.secret ordererpw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' -u https://0.0.0.0:7053
fabric-ca-client register -d --id.name orderer3-org0 --id.secret ordererpw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' -u https://0.0.0.0:7053
fabric-ca-client register -d --id.name orderer4-org0 --id.secret ordererpw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' -u https://0.0.0.0:7053
fabric-ca-client register -d --id.name orderer5-org0 --id.secret ordererpw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' -u https://0.0.0.0:7053
fabric-ca-client register -d --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://0.0.0.0:7053




## 登录
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org1/ca/admin
fabric-ca-client enroll -d -u https://org1-admin:org1-adminpw@0.0.0.0:7054

## 注册
fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7054
fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7054
fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type admin -u https://0.0.0.0:7054





## 登录
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org2/ca/admin
fabric-ca-client enroll -d -u https://org2-admin:org2-adminpw@0.0.0.0:7055


## 注册
fabric-ca-client register -d --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7055
fabric-ca-client register -d --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7055
fabric-ca-client register -d --id.name admin-org2 --id.secret org2AdminPW --id.type admin -u https://0.0.0.0:7055



## 通过客户端为所有节点生成msp证书和tls证书


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7054


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org1/peer1
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org1


mv $PWD/crypto-config/org1/peer1/tls-msp/keystore/*_sk $PWD/crypto-config/org1/peer1/tls-msp/keystore/key.pem


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org1/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer2-org1:peer2PW@0.0.0.0:7054


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org1/peer2
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://peer2-org1:peer2PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org1

mv $PWD/crypto-config/org1/peer2/tls-msp/keystore/*_sk  $PWD/crypto-config/org1/peer2/tls-msp/keystore/key.pem


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org1/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-org1:org1AdminPW@0.0.0.0:7054


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org1/admin
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://admin-org1:org1AdminPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts admin-org1


mv $PWD/crypto-config/org1/admin/tls-msp/keystore/*_sk $PWD/crypto-config/org1/admin/tls-msp/keystore/key.pem

mkdir -p $PWD/crypto-config/org1/peer1/msp/admincerts
cp $PWD/crypto-config/org1/admin/msp/signcerts/cert.pem $PWD/crypto-config/org1/peer1/msp/admincerts/org1-admin-cert.pem
mkdir -p $PWD/crypto-config/org1/peer2/msp/admincerts
cp $PWD/crypto-config/org1/admin/msp/signcerts/cert.pem $PWD/crypto-config/org1/peer2/msp/admincerts/org1-admin-cert.pem




export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org2/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7055


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org2/peer1
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://peer1-org2:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org2


mv $PWD/crypto-config/org2/peer1/tls-msp/keystore/*_sk $PWD/crypto-config/org2/peer1/tls-msp/keystore/key.pem


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org2/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer2-org2:peer2PW@0.0.0.0:7055



export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org2/peer2
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://peer2-org2:peer2PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org2

mv $PWD/crypto-config/org2/peer2/tls-msp/keystore/*_sk $PWD/crypto-config/org2/peer2/tls-msp/keystore/key.pem




export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org2/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-org2:org2AdminPW@0.0.0.0:7055



export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org2/admin
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://admin-org2:org2AdminPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org2

mv $PWD/crypto-config/org2/admin/tls-msp/keystore/*_sk $PWD/crypto-config/org2/admin/tls-msp/keystore/key.pem
mkdir -p $PWD/crypto-config/org2/peer1/msp/admincerts
cp $PWD/crypto-config/org2/admin/msp/signcerts/cert.pem $PWD/crypto-config/org2/peer1/msp/admincerts/org2-admin-cert.pem
mkdir -p $PWD/crypto-config/org2/peer2/msp/admincerts
cp $PWD/crypto-config/org2/admin/msp/signcerts/cert.pem $PWD/crypto-config/org2/peer2/msp/admincerts/org2-admin-cert.pem


## org0内的orderer节点制作证书

mkdir -p $PWD/crypto-config/org0/orderers


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer1-org0
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer1-org0:ordererpw@0.0.0.0:7053



export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer1-org0
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://orderer1-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org0



mv $PWD/crypto-config/org0/orderers/orderer1-org0/tls-msp/keystore/*_sk $PWD/crypto-config/org0/orderers/orderer1-org0/tls-msp/keystore/key.pem

export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-org0:org0adminpw@0.0.0.0:7053


mkdir $PWD/crypto-config/org0/orderers/orderer1-org0/msp/admincerts
cp $PWD/crypto-config/org0/admin/msp/signcerts/cert.pem $PWD/crypto-config/org0/orderers/orderer1-org0/msp/admincerts/orderer-admin-cert.pem




export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer2-org0
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer2-org0:ordererpw@0.0.0.0:7053



export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer2-org0
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://orderer2-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer2-org0


mv $PWD/crypto-config/org0/orderers/orderer2-org0/tls-msp/keystore/*_sk $PWD/crypto-config/org0/orderers/orderer2-org0/tls-msp/keystore/key.pem

mkdir $PWD/crypto-config/org0/orderers/orderer2-org0/msp/admincerts
cp $PWD/crypto-config/org0/admin/msp/signcerts/cert.pem $PWD/crypto-config/org0/orderers/orderer2-org0/msp/admincerts/orderer-admin-cert.pem


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer3-org0
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer3-org0:ordererpw@0.0.0.0:7053


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer3-org0
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://orderer3-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer3-org0


mv $PWD/crypto-config/org0/orderers/orderer3-org0/tls-msp/keystore/*_sk $PWD/crypto-config/org0/orderers/orderer3-org0/tls-msp/keystore/key.pem

mkdir $PWD/crypto-config/org0/orderers/orderer3-org0/msp/admincerts
cp $PWD/crypto-config/org0/admin/msp/signcerts/cert.pem $PWD/crypto-config/org0/orderers/orderer3-org0/msp/admincerts/orderer-admin-cert.pem



export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer4-org0
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer4-org0:ordererpw@0.0.0.0:7053


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer4-org0
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://orderer4-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer4-org0


mv $PWD/crypto-config/org0/orderers/orderer4-org0/tls-msp/keystore/*_sk $PWD/crypto-config/org0/orderers/orderer4-org0/tls-msp/keystore/key.pem

mkdir $PWD/crypto-config/org0/orderers/orderer4-org0/msp/admincerts
cp $PWD/crypto-config/org0/admin/msp/signcerts/cert.pem $PWD/crypto-config/org0/orderers/orderer4-org0/msp/admincerts/orderer-admin-cert.pem




export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer5-org0
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer5-org0:ordererpw@0.0.0.0:7053


export FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/org0/orderers/orderer5-org0
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/crypto-config/tls-ca/crypto/ca-cert.pem
fabric-ca-client enroll -d -u https://orderer5-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer5-org0


mv $PWD/crypto-config/org0/orderers/orderer5-org0/tls-msp/keystore/*_sk $PWD/crypto-config/org0/orderers/orderer5-org0/tls-msp/keystore/key.pem

mkdir $PWD/crypto-config/org0/orderers/orderer5-org0/msp/admincerts
cp $PWD/crypto-config/org0/admin/msp/signcerts/cert.pem $PWD/crypto-config/org0/orderers/orderer5-org0/msp/admincerts/orderer-admin-cert.pem



cp ./orderer-config/config.yaml ./crypto-config/org0/admin/msp/
cp ./orderer-config/config.yaml ./crypto-config/org0/orderers/orderer1-org0/msp/
cp ./orderer-config/config.yaml ./crypto-config/org0/orderers/orderer2-org0/msp/
cp ./orderer-config/config.yaml ./crypto-config/org0/orderers/orderer3-org0/msp/
cp ./orderer-config/config.yaml ./crypto-config/org0/orderers/orderer4-org0/msp/
cp ./orderer-config/config.yaml ./crypto-config/org0/orderers/orderer5-org0/msp/

cp ./org1-config/config.yaml ./crypto-config/org1/admin/msp/
cp ./org1-config/config.yaml ./crypto-config/org1/peer1/msp/
cp ./org1-config/config.yaml ./crypto-config/org1/peer2/msp/

cp ./org2-config/config.yaml ./crypto-config/org2/admin/msp/
cp ./org2-config/config.yaml ./crypto-config/org2/peer1/msp/
cp ./org2-config/config.yaml ./crypto-config/org2/peer2/msp/


## org0的admin证书

mkdir -p $PWD/crypto-config/configtx/org0
cp -r $PWD/crypto-config/org0/admin/msp $PWD/crypto-config/configtx/org0

mkdir $PWD/crypto-config/configtx/org0/msp/tlscacerts
cp  $PWD/crypto-config/org0/orderers/orderer1-org0/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem  $PWD/crypto-config/configtx/org0/msp/tlscacerts

## org1的admin证书
mkdir -p $PWD/crypto-config/configtx/org1
cp -r $PWD/crypto-config/org1/admin/msp $PWD/crypto-config/configtx/org1/

mkdir -p $PWD/crypto-config/configtx/org1/msp/tlscacerts
cp $PWD/crypto-config/org1/admin/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem $PWD/crypto-config/configtx/org1/tlscacerts

## org2的admin证书
mkdir -p $PWD/crypto-config/configtx/org2
cp -r $PWD/crypto-config/org2/admin/msp $PWD/crypto-config/configtx/org2/

mkdir -p $PWD/crypto-config/configtx/org2/msp/tlscacerts
cp $PWD/crypto-config/org2/admin/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem $PWD/crypto-config/configtx/org2/tlscacerts



configtxgen -profile SampleMultiNodeEtcdRaft -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

##  docker-compose -f docker-compose-etcdraft2.yaml up -d 2>&1




