工作目录,除非特殊说明，一般命令的执行都是在工作目录进行。
cd $GOPATH/src/github.com/hyperledger/fabric-samples/first



 (一)【docker】方式运行ordererCA

docker-compose -f docker-compose-ca-orderer.yaml up -d 2>&1

# 在下面的命令中，我们将CA的ROOT证书的受信任根证书已复制到 ./fabric-ca-server/intermediaca1/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
 cp ./crypto-config/rootOrganizations/root.example.com/crypto/ca-cert.pem ./crypto-config/ordererOrganizations/example.com/crypto/root-ca-cert.pem

1. 生成example.com的msp

进入容器
docker exec -it orderer.ca.example.com bash

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./admin
fabric-ca-client enroll -d -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055

2） 添加联盟成员
fabric-ca-client affiliation list -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation remove --force org1 -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation remove --force org2 -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation add com -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation add com.example -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055


2. 注册orderer
1） 注册Admin@example.com
fabric-ca-client register --id.name Admin@example.com --id.type admin --id.affiliation "com.example" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=ordereradminpw --csr.cn=example.com --csr.hosts=['example.com'] -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055

4） 注册orderer1.example.com
fabric-ca-client register --id.name orderer1.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=orderer1pw --csr.cn=orderer1.example.com --csr.hosts=['orderer1.example.com'] -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
4） 注册orderer2.example.com
fabric-ca-client register --id.name orderer2.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=orderer2pw --csr.cn=orderer2.example.com --csr.hosts=['orderer2.example.com'] -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
4） 注册orderer3.example.com
fabric-ca-client register --id.name orderer3.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=orderer3pw --csr.cn=orderer3.example.com --csr.hosts=['orderer3.example.com'] -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
4） 注册orderer4.example.com
fabric-ca-client register --id.name orderer4.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=orderer4pw --csr.cn=orderer4.example.com --csr.hosts=['orderer4.example.com'] -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
4） 注册orderer5.example.com
fabric-ca-client register --id.name orderer5.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=orderer5pw --csr.cn=orderer5.example.com --csr.hosts=['orderer5.example.com'] -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055


2） 登记Admin@example.com的msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/Admin@example.com/msp
fabric-ca-client enroll -u https://Admin@example.com:ordereradminpw@orderer.ca.example.com:7055 --csr.cn=example.com --csr.hosts=['example.com']


mkdir -p ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/admincerts
cp ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/admincerts
cp ./orderer-config/config.yaml ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/

mkdir -p ./crypto-config/ordererOrganizations/example.com/msp
cp -r ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/  ./crypto-config/ordererOrganizations/example.com/


 (二) 生成orderer1.example.com的msp和tls

2） 登记orderer1.example.com的msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer1.example.com/msp
fabric-ca-client enroll -u https://orderer1.example.com:orderer1pw@orderer.ca.example.com:7055 --csr.cn=orderer1.example.com --csr.hosts=['orderer1.example.com']


1） 登记orderer1.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer1.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer1.example.com:orderer1pw@root.ca.example.com:7054 --csr.cn=orderer1.example.com --csr.hosts=['orderer1.example.com']


1)  复制证书
cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/keystore/key.pem
mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/admincerts
cp ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/admincerts/
cp ./orderer-config/config.yaml ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/msp




4. 生成orderer2.example.com的msp和tls

2） 登记orderer2.example.com的msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer2.example.com/msp
fabric-ca-client enroll -u https://orderer2.example.com:orderer2pw@orderer.ca.example.com:7055 --csr.cn=orderer2.example.com --csr.hosts=['orderer2.example.com']


1） 登记orderer2.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer2.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer2.example.com:orderer2pw@root.ca.example.com:7054 --csr.cn=orderer2.example.com --csr.hosts=['orderer2.example.com']


1)  复制证书
cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/key.pem
mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/admincerts
cp ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/admincerts/
cp ./orderer-config/config.yaml ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp




 (三) 生成orderer3.example.com的msp和tls

2） 登记orderer3.example.com的msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer3.example.com/msp
fabric-ca-client enroll -u https://orderer3.example.com:orderer3pw@orderer.ca.example.com:7055 --csr.cn=orderer3.example.com --csr.hosts=['orderer3.example.com']


1） 登记orderer3.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer3.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer3.example.com:orderer3pw@root.ca.example.com:7054 --csr.cn=orderer3.example.com --csr.hosts=['orderer3.example.com']


1)  复制证书
cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/key.pem
mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/admincerts
cp ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/admincerts/
cp ./orderer-config/config.yaml ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp





 (四) 生成orderer4.example.com的msp和tls

2） 登记orderer4.example.com的msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer4.example.com/msp
fabric-ca-client enroll -u https://orderer4.example.com:orderer4pw@orderer.ca.example.com:7055 --csr.cn=orderer4.example.com --csr.hosts=['orderer4.example.com']


1） 登记orderer4.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer4.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer4.example.com:orderer4pw@root.ca.example.com:7054 --csr.cn=orderer4.example.com --csr.hosts=['orderer4.example.com']


1)  复制证书
cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/keystore/key.pem
mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/admincerts
cp ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/admincerts/
cp ./orderer-config/config.yaml ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/msp




 (五) 生成orderer5.example.com的msp和tls

2） 登记orderer5.example.com的msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer5.example.com/msp
fabric-ca-client enroll -u https://orderer5.example.com:orderer5pw@orderer.ca.example.com:7055 --csr.cn=orderer5.example.com --csr.hosts=['orderer5.example.com']


1） 登记orderer5.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer5.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer5.example.com:orderer5pw@root.ca.example.com:7054 --csr.cn=orderer5.example.com --csr.hosts=['orderer5.example.com']


1)  复制证书
cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/keystore/key.pem
mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/msp/admincerts
cp ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/msp/admincerts/
cp ./orderer-config/config.yaml ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/msp











