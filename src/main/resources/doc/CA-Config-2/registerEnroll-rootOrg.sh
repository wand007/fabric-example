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

export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./admin
fabric-ca-client enroll -d -u https://root-admin:root-adminpw@root.ca.example.com:7054
此时有新的问及那目录生成


注册TLS CA的管理员
fabric-ca-client register --id.name peer0.org1.example.com --id.type peer  --id.secret=peer0org1pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer1.org1.example.com --id.type peer  --id.secret=peer1org1pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer0.org2.example.com --id.type peer  --id.secret=peer0org2pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name peer1.org2.example.com --id.type peer  --id.secret=peer1org2pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer1.example.com --id.type orderer --id.secret=orderer1pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer3.example.com --id.type orderer --id.secret=orderer3pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer4.example.com --id.type orderer --id.secret=orderer4pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer2.example.com --id.type orderer --id.secret=orderer2pw -u https://root-admin:root-adminpw@root.ca.example.com:7054
fabric-ca-client register --id.name orderer5.example.com --id.type orderer --id.secret=orderer5pw -u https://root-admin:root-adminpw@root.ca.example.com:7054


退出容器 exit

使用在TLS CA上注册的身份，我们可以继续建立每个组织的网络。每当我们需要为组织中的节点获取TLS证书时，我们都将引用此CA。













