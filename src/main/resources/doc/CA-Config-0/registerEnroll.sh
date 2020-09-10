工作目录,除非特殊说明，一般命令的执行都是在工作目录进行。
cd $GOPATH/src/github.com/hyperledger/fabric-samples/first

首次运行清除docker影响

 docker-compose -f docker-compose-ca-root.yaml  down --volumes --remove-orphans


fabric 网络搭建
CA 安装

tls-ca
创建目录
(一)【docker】方式运行RootCA

 docker-compose -f docker-compose-ca-root.yaml up -d 2>&1

进入容器
docker exec -it root.ca.example.com bash

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/tls-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./admin

fabric-ca-client enroll -d -u https://root-admin:root-adminpw@root.ca.example.com:7054
此时有新的问及那目录生成


2） 添加联盟成员
fabric-ca-client affiliation list -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client affiliation remove --force org1 -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client affiliation remove --force org2 -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client affiliation add com -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client affiliation add com.example -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client affiliation add com.example.org1 -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client affiliation add com.example.org2 -u https://root-admin:root-adminpw@root.ca.example.com:7054

注册TLS CA的管理员
fabric-ca-client register --id.name peer0.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=peer0org1pw --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com'] -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer1.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=peer1org1pw --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com'] -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer0.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=peer0org2pw --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com'] -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer1.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=peer1org2pw --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com'] -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=ordererpw --csr.cn=orderer.example.com --csr.hosts=['orderer.example.com'] -u https://root-admin:root-adminpw@root.ca.example.com:7054


退出容器 exit

使用在TLS CA上注册的身份，我们可以继续建立每个组织的网络。每当我们需要为组织中的节点获取TLS证书时，我们都将引用此CA。









 (二)【docker】方式运行ordererCA

docker-compose -f docker-compose-ca-orderer.yaml up -d 2>&1

# 在下面的命令中，我们将CA的ROOT证书的受信任根证书已复制到 ./fabric-ca-server/intermediaca1/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
 cp ./organizations/rootOrganizations/root.example.com/ca/ca-cert.pem ./organizations/ordererOrganizations/example.com/ca/root-ca-cert.pem

1. 生成example.com的msp

进入容器
docker exec -it orderer.ca.example.com bash

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./admin
fabric-ca-client enroll -d -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055 --caname ca-orderer

2） 添加联盟成员
fabric-ca-client affiliation list -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation remove --force org1 -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation remove --force org2 -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation add com -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation add com.example -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055


2. 注册orderer
1） 注册Admin@example.com
fabric-ca-client register --id.name Admin@example.com --id.type admin --id.affiliation "com.example" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=ordereradminpw --csr.cn=example.com --csr.hosts=['example.com'] -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055  --caname ca-orderer

4） 注册orderer.example.com
fabric-ca-client register --id.name orderer.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=ordererpw --csr.cn=orderer.example.com --csr.hosts=['orderer.example.com'] -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055  --caname ca-orderer


2） 登记Admin@example.com的msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/Admin@example.com/msp
fabric-ca-client enroll -u https://Admin@example.com:ordereradminpw@orderer.ca.example.com:7055 --caname ca-orderer --csr.cn=example.com --csr.hosts=['example.com']


3. 生成orderer.example.com的msp和tls


2） 登记orderer.example.com的msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer.example.com/msp
fabric-ca-client enroll -u https://orderer.example.com:ordererpw@orderer.ca.example.com:7055  --caname ca-orderer --csr.cn=orderer.example.com --csr.hosts=['orderer.example.com']


1） 登记orderer.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/root-ca-cert.pem 
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./orderers/orderer.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer.example.com:ordererpw@root.ca.example.com:7054 --csr.cn=orderer.example.com --csr.hosts=['orderer.example.com'] 


1)  复制证书
cp ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/
cp ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/
cp ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/key.pem

mkdir  -p ./organizations/ordererOrganizations/example.com/msp/tlscacerts
cp ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ./organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

mkdir -p ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
cp ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

mkdir -p organizations/ordererOrganizations/example.com/users/Admin@example.com
cp ./organizations/ordererOrganizations/example.com/msp/config.yaml ./organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml

cp ./organizations/ordererOrganizations/example.com/msp/config.yaml ./organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml


(三)【docker】方式运行org1CA

docker-compose -f docker-compose-ca-org1.yaml up -d 2>&1

# 在下面的命令中，我们将CA的ROOT证书的受信任根证书已复制到 ./fabric-ca-server/intermediaca1/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./organizations/rootOrganizations/root.example.com/ca/ca-cert.pem ./organizations/peerOrganizations/org1.example.com/ca/root-ca-cert.pem

1. 生成org1.example.com的msp

进入容器
docker exec -it org1.ca.example.com bash


export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./admin
fabric-ca-client enroll -d -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056

2） 添加联盟成员
fabric-ca-client affiliation list -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation remove --force org1 -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation remove --force org2 -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com.example -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com.example.org1 -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056

1. 生成example.com的msp
3） 注册Admin@example.com
fabric-ca-client register --id.name Admin@org1.example.com --id.type admin  --id.affiliation "com.example.org1" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=org1adminpw --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056 --caname ca-org1

1） 注册User1@org1.example.com
fabric-ca-client register --id.name User1@org1.example.com --id.type client  --id.affiliation "com.example.org1" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=org1userpw --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056 --caname ca-org1

1） 注册peer0.org1.example.com
fabric-ca-client register --id.name peer0.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=peer0org1pw --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com'] -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056 --caname ca-org1

1） 注册peer1.org1.example.com
fabric-ca-client register --id.name peer1.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=peer1org1pw --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com'] -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056 --caname ca-org1


3） 登记Admin@example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem 
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/Admin@org1.example.com/msp
fabric-ca-client enroll -u https://Admin@org1.example.com:org1adminpw@org1.ca.example.com:7056 --caname ca-org1 --csr.cn=org1.example.com --csr.hosts=['org1.example.com']


1） 登记User1@org1.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem 
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/User1@org1.example.com/msp
fabric-ca-client enroll -u https://User1@org1.example.com:org1userpw@org1.ca.example.com:7056 --caname ca-org1 --csr.cn=org1.example.com --csr.hosts=['org1.example.com']

3. 生成peer0.org1.example.com的msp和tls


1） 登记peer0.org1.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem 
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer0.org1.example.com/msp
fabric-ca-client enroll -u https://peer0.org1.example.com:peer0org1pw@org1.ca.example.com:7056 --caname ca-org1 --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com']

1） 登记peer0.org1.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer0.org1.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer0.org1.example.com:peer0org1pw@root.ca.example.com:7054 --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com']


1） 复制证书
mkdir -p ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com

cp ./organizations/peerOrganizations/org1.example.com/msp/config.yaml ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/config.yaml

cp ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/
cp ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/signcerts/* ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/
cp ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/* ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/key.pem

mkdir -p ./organizations/peerOrganizations/org1.example.com/msp/tlscacerts
cp ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org1.example.com/msp/tlscacerts/

mkdir -p ./organizations/peerOrganizations/org1.example.com/tlsca
cp ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem

mkdir -p ./organizations/peerOrganizations/org1.example.com/ca
cp ./organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/cacerts/* ./organizations/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem

mkdir -p ./organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com

mkdir -p ./organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com

cp ./organizations/peerOrganizations/org1.example.com/msp/config.yaml /organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/config.yaml




3. 生成peer1.org1.example.com的msp和tls


1） 登记peer1.org1.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem 
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer1.org1.example.com/msp
fabric-ca-client enroll -u https://peer1.org1.example.com:peer1org1pw@org1.ca.example.com:7056 --caname ca-org1 --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com']

1） 登记peer1.org1.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer1.org1.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer1.org1.example.com:peer1org1pw@root.ca.example.com:7054 --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com']


1） 复制证书
mkdir -p organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com

cp ./organizations/peerOrganizations/org1.example.com/msp/config.yaml ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/config.yaml

cp ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/
cp ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/signcerts/* ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/
cp ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/keystore/* ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/key.pem

mkdir -p ./organizations/peerOrganizations/org1.example.com/msp/tlscacerts
cp ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org1.example.com/msp/tlscacerts/

mkdir -p ./organizations/peerOrganizations/org1.example.com/tlsca
cp ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem

mkdir -p ./organizations/peerOrganizations/org1.example.com/ca
cp ./organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/cacerts/* ./organizations/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem





(四)【docker】方式运行org2CA

docker-compose -f docker-compose-ca-org2.yaml up -d 2>&1

# 在下面的命令中，我们将CA的ROOT证书的受信任根证书已复制到 ./fabric-ca-server/intermediaca1/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./organizations/rootOrganizations/root.example.com/ca/ca-cert.pem ./organizations/peerOrganizations/org2.example.com/ca/root-ca-cert.pem

1. 生成org2.example.com的msp

进入容器
docker exec -it org2.ca.example.com bash


export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./admin
fabric-ca-client enroll -d -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057

2） 添加联盟成员
fabric-ca-client affiliation list -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation remove --force org2 -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation remove --force org2 -u https://org2-admin:org2-adminpw@org2.ca.example.com:7055
fabric-ca-client affiliation add com -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation add com.example -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation add com.example.org2 -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057

1. 生成example.com的msp
3） 注册Admin@example.com
fabric-ca-client register --id.name Admin@org2.example.com --id.type admin  --id.affiliation "com.example.org2" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=org2adminpw --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057 --caname ca-org2

1） 注册User1@org2.example.com
fabric-ca-client register --id.name User1@org2.example.com --id.type client  --id.affiliation "com.example.org2" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=org2userpw --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057 --caname ca-org2

1） 注册peer0.org2.example.com
fabric-ca-client register --id.name peer0.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=peer0org2pw --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com'] -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057 --caname ca-org2

1） 注册peer1.org2.example.com
fabric-ca-client register --id.name peer1.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=peer1org2pw --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com'] -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057 --caname ca-org2

3） 登记Admin@example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto-config/ordererOrganizations/orderer.example.com/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/Admin@org2.example.com/msp
fabric-ca-client enroll -u https://Admin@org2.example.com:org2adminpw@org2.ca.example.com:7057 --caname ca-org2 --csr.cn=org2.example.com --csr.hosts=['org2.example.com'


1） 登记User1@org2.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto-config/ordererOrganizations/orderer.example.com/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/User1@org2.example.com/msp
fabric-ca-client enroll -u https://User1@org2.example.com:org2userpw@org2.ca.example.com:7057 --caname ca-org2 --csr.cn=org2.example.com --csr.hosts=['org2.example.com'

3. 生成peer0.org2.example.com的msp和tls


1） 登记peer0.org2.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto-config/ordererOrganizations/orderer.example.com/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer0.org2.example.com/msp
fabric-ca-client enroll -u https://peer0.org2.example.com:peer0org2pw@org2.ca.example.com:7057 --caname ca-org2 --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com']

1） 登记peer0.org2.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer0.org2.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer0.org2.example.com:peer0org2pw@root.ca.example.com:7054 --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com'] --caname ca-org2


1） 复制证书
mkdir -p organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com

cp ./organizations/peerOrganizations/org2.example.com/msp/config.yaml ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/config.yaml

cp ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/
cp ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/signcerts/* ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/
cp ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/keystore/* ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/key.pem

mkdir -p ./organizations/peerOrganizations/org2.example.com/msp/tlscacerts
cp ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org2.example.com/msp/tlscacerts/

mkdir -p ./organizations/peerOrganizations/org2.example.com/tlsca
cp ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem

mkdir -p ./organizations/peerOrganizations/org2.example.com/ca
cp ./organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/cacerts/* ./organizations/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem

mkdir -p organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com

mkdir -p organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com

cp ./organizations/peerOrganizations/org2.example.com/msp/config.yaml ./organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/config.yaml



3. 生成peer1.org2.example.com的msp和tls


1） 登记peer1.org2.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto-config/ordererOrganizations/orderer.example.com/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer1.org2.example.com/msp
fabric-ca-client enroll -u https://peer1.org2.example.com:peer1org2pw@org2.ca.example.com:7057 --caname ca-org2 --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com']

1） 登记peer1.org2.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer1.org2.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer1.org2.example.com:peer1org2pw@root.ca.example.com:7054 --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com'] --caname ca-org2


1） 复制证书
mkdir -p organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com

cp ./organizations/peerOrganizations/org2.example.com/msp/config.yaml ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/config.yaml

cp ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/
cp ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/signcerts/* ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/
cp ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/keystore/* ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/key.pem

mkdir -p ./organizations/peerOrganizations/org2.example.com/msp/tlscacerts
cp ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org2.example.com/msp/tlscacerts/

mkdir -p ./organizations/peerOrganizations/org2.example.com/tlsca
cp ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/tlscacerts/* ./organizations/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem

mkdir -p ./organizations/peerOrganizations/org2.example.com/ca
cp ./organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/cacerts/* ./organizations/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem












