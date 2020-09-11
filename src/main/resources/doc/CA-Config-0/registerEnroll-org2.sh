工作目录,除非特殊说明，一般命令的执行都是在工作目录进行。
cd $GOPATH/src/github.com/hyperledger/fabric-samples/first




(四)【docker】方式运行org2CA

docker-compose -f docker-compose-ca-org2.yaml up -d 2>&1

# 在下面的命令中，我们将CA的ROOT证书的受信任根证书已复制到 ./fabric-ca-server/intermediaca1/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./crypto-config/rootOrganizations/root.example.com/ca/ca-cert.pem ./crypto-config/peerOrganizations/org2.example.com/ca/root-ca-cert.pem

1. 生成org2.example.com的msp

进入容器
docker exec -it org2.ca.example.com bash


export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
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
fabric-ca-client register --id.name Admin@org2.example.com --id.type admin  --id.affiliation "com.example.org2" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=org2adminpw --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057

1） 注册User1@org2.example.com
fabric-ca-client register --id.name User1@org2.example.com --id.type client  --id.affiliation "com.example.org2" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=org2userpw --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057

1） 注册peer0.org2.example.com
fabric-ca-client register --id.name peer0.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=peer0org2pw --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com'] -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057

1） 注册peer1.org2.example.com
fabric-ca-client register --id.name peer1.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=peer1org2pw --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com'] -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057

3） 登记Admin@example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/Admin@org2.example.com/msp
fabric-ca-client enroll -u https://Admin@org2.example.com:org2adminpw@org2.ca.example.com:7057 --csr.cn=org2.example.com --csr.hosts=['org2.example.com'


1） 登记User1@org2.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/User1@org2.example.com/msp
fabric-ca-client enroll -u https://User1@org2.example.com:org2userpw@org2.ca.example.com:7057 --csr.cn=org2.example.com --csr.hosts=['org2.example.com'

3. 生成peer0.org2.example.com的msp和tls


1） 登记peer0.org2.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer0.org2.example.com/msp
fabric-ca-client enroll -u https://peer0.org2.example.com:peer0org2pw@org2.ca.example.com:7057 --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com']

1） 登记peer0.org2.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer0.org2.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer0.org2.example.com:peer0org2pw@root.ca.example.com:7054 --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com']


1） 复制证书
mkdir -p crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com

cp ./org2-config/config.yaml ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/config.yaml

cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/signcerts/* ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/keystore/* ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/key.pem

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ./crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/tlsca
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ./crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/ca
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/cacerts/* ./crypto-config/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem

mkdir -p crypto-config/peerOrganizations/org2.example.com/users/User1@org2.example.com

mkdir -p crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com

cp ./crypto-config/peerOrganizations/org2.example.com/msp/config.yaml ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/config.yaml



3. 生成peer1.org2.example.com的msp和tls


1） 登记peer1.org2.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer1.org2.example.com/msp
fabric-ca-client enroll -u https://peer1.org2.example.com:peer1org2pw@org2.ca.example.com:7057 --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com']

1） 登记peer1.org2.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer1.org2.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer1.org2.example.com:peer1org2pw@root.ca.example.com:7054 --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com']


1） 复制证书
mkdir -p crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com

cp ./crypto-config/peerOrganizations/org2.example.com/msp/config.yaml ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/config.yaml

cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/tlscacerts/* ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/signcerts/* ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/keystore/* ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/key.pem

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/tlscacerts/* ./crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/tlsca
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/tlscacerts/* ./crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/ca
cp ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/cacerts/* ./crypto-config/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem












