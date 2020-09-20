工作目录,除非特殊说明，一般命令的执行都是在工作目录进行。
cd $GOPATH/src/github.com/hyperledger/fabric-samples/first

首次运行清除docker影响

 docker-compose -f docker-compose-ca-root.yaml  down --volumes --remove-orphans


启动CA服务
 docker-compose -f docker-compose-cli-ca.yaml up -d 2>&1

 进入容器
docker exec -it root.ca.example.com bash

登陆
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/tls-ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/tls-ca/admin
fabric-ca-client enroll -d -u https://root-admin:root-adminpw@root.ca.example.com:7054


注册
# 为各个组件(组件指的是 peer,order和管理员)注册TLS证书,仅仅是注册了身份,并没有获取到证书;

# 注册org1的admin管理员 
fabric-ca-client register -d --id.name admin.org1.example.com --id.type admin --id.secret org1AdminPW -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register -d --id.name admin.org2.example.com --id.type admin --id.secret org2AdminPW -u https://root-admin:root-adminpw@root.ca.example.com:7054

fabric-ca-client register --id.name peer0.org1.example.com --id.type peer  --id.secret=peer0org1pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer1.org1.example.com --id.type peer  --id.secret=peer1org1pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer0.org2.example.com --id.type peer  --id.secret=peer0org2pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer1.org2.example.com --id.type peer  --id.secret=peer1org2pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer1.example.com --id.type orderer --id.secret=orderer1pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer3.example.com --id.type orderer --id.secret=orderer3pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer4.example.com --id.type orderer --id.secret=orderer4pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer2.example.com --id.type orderer --id.secret=orderer2pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer5.example.com --id.type orderer --id.secret=orderer5pw -u https://root-admin:root-adminpw@root.ca.example.com:7054




 进入容器
 docker exec -it orderer.ca.example.com bash

登录
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/admin
fabric-ca-client enroll -d -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055


注册
fabric-ca-client register --id.name Admin@example.com --id.type admin --id.secret=ordereradminpw -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client register --id.name orderer1.example.com --id.type orderer --id.secret=orderer1pw -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client register --id.name orderer2.example.com --id.type orderer --id.secret=orderer2pw -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client register --id.name orderer3.example.com --id.type orderer --id.secret=orderer3pw -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client register --id.name orderer4.example.com --id.type orderer --id.secret=orderer4pw -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055
fabric-ca-client register --id.name orderer5.example.com --id.type orderer --id.secret=orderer5pw -u https://orderer-admin:orderer-adminpw@orderer.ca.example.com:7055



 进入容器
 docker exec -it org1.ca.example.com bash

登录
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org1/ca/admin
fabric-ca-client enroll -d -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056


fabric-ca-client register --id.name Admin@org1.example.com --id.type admin --id.secret=org1adminpw -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client register --id.name User1@org1.example.com --id.type client --id.secret=org1userpw  -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client register --id.name peer0.org1.example.com --id.type peer --id.secret=peer0org1pw -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client register --id.name peer1.org1.example.com --id.type peer --id.secret=peer1org1pw -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056




进入容器
docker exec -it org2.ca.example.com bash

登录
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org2/ca/admin
fabric-ca-client enroll -d -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057


注册
fabric-ca-client register --id.name Admin@org2.example.com --id.type admin --id.secret=org2adminpw -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057
fabric-ca-client register --id.name User1@org2.example.com --id.type client --id.secret=org2userpw -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057
fabric-ca-client register --id.name peer0.org2.example.com --id.type peer --id.secret=peer0org2pw -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057
fabric-ca-client register --id.name peer1.org2.example.com --id.type peer --id.secret=peer1org2pw -u https://org2-admin:org2-adminpw@org2.ca.example.com:7057



cp ./crypto-config/tls-ca/crypto/ca-cert.pem ./crypto-config/org0/ca/crypto/root-ca-cert.pem
 进入容器
 docker exec -it orderer.ca.example.com bash

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer1
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer1.example.com:orderer1pw@orderer.ca.example.com:7055

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer1
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer1.example.com:orderer1pw@root.ca.example.com:7054 --csr.hosts=['orderer1.example.com']


export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer2
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer2.example.com:orderer2pw@orderer.ca.example.com:7055

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer2
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer2.example.com:orderer2pw@root.ca.example.com:7054 --csr.hosts=['orderer2.example.com']



export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer3
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -u https://orderer3.example.com:orderer3pw@orderer.ca.example.com:7055

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer3
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer3.example.com:orderer3pw@root.ca.example.com:7054 --csr.hosts=['orderer3.example.com']



export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer4
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer4.example.com:orderer4pw@orderer.ca.example.com:7055

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer4
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer4.example.com:orderer4pw@root.ca.example.com:7054 --csr.hosts=['orderer4.example.com']



export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer5
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://orderer5.example.com:orderer5pw@orderer.ca.example.com:7055

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/orderers/orderer5
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer5.example.com:orderer5pw@root.ca.example.com:7054 --csr.hosts=['orderer5.example.com']




export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org0/ca/users/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://Admin@example.com:ordereradminpw@orderer.ca.example.com:7055


mv ./crypto-config/org0/ca/orderers/orderer1/tls-msp/keystore/*_sk ./crypto-config/org0/ca/orderers/orderer1/tls-msp/keystore/key.pem
mv ./crypto-config/org0/ca/orderers/orderer2/tls-msp/keystore/*_sk ./crypto-config/org0/ca/orderers/orderer2/tls-msp/keystore/key.pem
mv ./crypto-config/org0/ca/orderers/orderer3/tls-msp/keystore/*_sk ./crypto-config/org0/ca/orderers/orderer3/tls-msp/keystore/key.pem
mv ./crypto-config/org0/ca/orderers/orderer4/tls-msp/keystore/*_sk ./crypto-config/org0/ca/orderers/orderer4/tls-msp/keystore/key.pem
mv ./crypto-config/org0/ca/orderers/orderer5/tls-msp/keystore/*_sk ./crypto-config/org0/ca/orderers/orderer5/tls-msp/keystore/key.pem


mkdir -p ./crypto-config/org0/ca/orderers/orderer1/msp/admincerts 
cp ./crypto-config/org0/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org0/ca/orderers/orderer1/msp/admincerts/ 

mkdir -p ./crypto-config/org0/ca/orderers/orderer2/msp/admincerts 
cp ./crypto-config/org0/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org0/ca/orderers/orderer2/msp/admincerts/ 

mkdir -p ./crypto-config/org0/ca/orderers/orderer3/msp/admincerts 
cp ./crypto-config/org0/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org0/ca/orderers/orderer3/msp/admincerts/ 

mkdir -p ./crypto-config/org0/ca/orderers/orderer4/msp/admincerts 
cp ./crypto-config/org0/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org0/ca/orderers/orderer4/msp/admincerts/ 

mkdir -p ./crypto-config/org0/ca/orderers/orderer5/msp/admincerts 
cp ./crypto-config/org0/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org0/ca/orderers/orderer5/msp/admincerts/ 



cp ./orderer-config/config.yaml ./crypto-config/org0/ca/users/admin/msp/

mkdir -p ./crypto-config/org0/ca/users/admin/msp/tlscacerts
cp -r ./crypto-config/org0/ca/orderers/orderer1/tls-msp/tlscacerts/tls-root-ca-example-com-7054.pem ./crypto-config/org0/ca/users/admin/msp/tlscacerts

mkdir -p ./crypto-config/org0/ca/msp
cp -r ./crypto-config/org0/ca/users/admin/msp ./crypto-config/org0/ca/




 进入容器
cp ./crypto-config/tls-ca/crypto/ca-cert.pem ./crypto-config/org1/ca/crypto/root-ca-cert.pem
docker exec -it org1.ca.example.com bash

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org1/ca/peer0
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer0.org1.example.com:peer0org1pw@org1.ca.example.com:7056

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org1/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org1/ca/peer0
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer0.org1.example.com:peer0org1pw@root.ca.example.com:7054 --csr.hosts=['peer0.org1.example.com']



export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org1/ca/peer1
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer1.org1.example.com:peer1org1pw@org1.ca.example.com:7056

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org1/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org1/ca/peer1
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer1.org1.example.com:peer1org1pw@root.ca.example.com:7054 --csr.hosts=['peer1.org1.example.com']



export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org1/ca/users/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://Admin@org1.example.com:org1adminpw@org1.ca.example.com:7056


export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org1/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org1/ca/users/admin
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://admin.org1.example.com:org1AdminPW@root.ca.example.com:7054 --csr.hosts=['admin.org1.example.com']




mv ./crypto-config/org1/ca/peer0/tls-msp/keystore/*_sk ./crypto-config/org1/ca/peer0/tls-msp/keystore/key.pem
mv ./crypto-config/org1/ca/peer1/tls-msp/keystore/*_sk ./crypto-config/org1/ca/peer1/tls-msp/keystore/key.pem
mv ./crypto-config/org1/ca/users/admin/tls-msp/keystore/*_sk ./crypto-config/org1/ca/users/admin/tls-msp/keystore/key.pem

mkdir -p ./crypto-config/org1/ca/peer0/msp/admincerts 
cp ./crypto-config/org1/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org1/ca/peer0/msp/admincerts/ 

mkdir -p ./crypto-config/org1/ca/peer1/msp/admincerts 
cp ./crypto-config/org1/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org1/ca/peer1/msp/admincerts/ 

cp ./org1-config/config.yaml ./crypto-config/org1/ca/users/admin/msp/

mkdir -p ./crypto-config/org1/ca/msp
cp -r ./crypto-config/org1/ca/users/admin/msp ./crypto-config/org1/ca/
cp -r ./crypto-config/org1/ca/users/admin/tls-msp/tlscacerts/tls-root-ca-example-com-7054.pem ./crypto-config/org1/ca/msp/tlscacerts/



 进入容器
cp ./crypto-config/tls-ca/crypto/ca-cert.pem ./crypto-config/org2/ca/crypto/root-ca-cert.pem

docker exec -it org2.ca.example.com bash

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org2/ca/peer0
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer0.org2.example.com:peer0org2pw@org2.ca.example.com:7057

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org2/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org2/ca/peer0
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer0.org2.example.com:peer0org2pw@root.ca.example.com:7054 --csr.hosts=['peer0.org2.example.com']



export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org2/ca/peer1
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://peer1.org2.example.com:peer1org2pw@org2.ca.example.com:7057

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org2/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org2/ca/peer1
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer1.org2.example.com:peer1org2pw@root.ca.example.com:7054 --csr.hosts=['peer1.org2.example.com']



export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org2/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org2/ca/users/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://Admin@org2.example.com:org2adminpw@org2.ca.example.com:7057

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/org2/ca/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server/org2/ca/users/admin
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d --enrollment.profile tls -u https://admin.org2.example.com:org2AdminPW@root.ca.example.com:7054 --csr.hosts=['admin.org2.example.com']



mv ./crypto-config/org2/ca/peer0/tls-msp/keystore/*_sk ./crypto-config/org2/ca/peer0/tls-msp/keystore/key.pem
mv ./crypto-config/org2/ca/peer1/tls-msp/keystore/*_sk ./crypto-config/org2/ca/peer1/tls-msp/keystore/key.pem
mv ./crypto-config/org2/ca/users/admin/tls-msp/keystore/*_sk ./crypto-config/org2/ca/users/admin/tls-msp/keystore/key.pem

mkdir -p ./crypto-config/org2/ca/peer0/msp/admincerts 
cp ./crypto-config/org2/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org2/ca/peer0/msp/admincerts/ 

mkdir -p ./crypto-config/org2/ca/peer1/msp/admincerts 
cp ./crypto-config/org2/ca/users/admin/msp/signcerts/cert.pem ./crypto-config/org2/ca/peer1/msp/admincerts/ 


cp ./org2-config/config.yaml ./crypto-config/org2/ca/users/admin/msp/

mkdir -p ./crypto-config/org2/ca/msp
cp -r ./crypto-config/org2/ca/users/admin/msp ./crypto-config/org2/ca/
cp -r ./crypto-config/org2/ca/users/admin/tls-msp/tlscacerts/tls-root-ca-example-com-7054.pem ./crypto-config/org2/ca/msp/tlscacerts/






