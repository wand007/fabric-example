

文中命令均在该目录下执行
cd /workspace/go/src/github.com/hyperledger/fabric-samples/first

首次运行清除docker影响

 docker-compose -f docker-compose-ca-root.yaml  down --volumes --remove-orphans

(一)【docker】方式运行RootCA

 docker-compose -f docker-compose-ca-root.yaml up -d 2>&1

(二)【docker】方式运行IntermediaCA1

 docker-compose -f docker-compose-ca-orderer.yaml up -d 2>&1 

IntermediaCA1生成证书

# 在下面的命令中，我们将CA的ROOT证书的受信任根证书已复制到 ./fabric-ca-server/intermediaca1/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./fabric-ca-server/root-ca/ca-cert.pem ./fabric-ca-server/intermediaca1/root-ca-cert.pem

1. 生成example.com的msp
docker exec -it orderer.ca.example.com bash
1） 登记example.com

fabric-ca-client enroll -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
             
2） 添加联盟成员
fabric-ca-client affiliation list -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation remove --force org1 -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation remove --force org2 -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation add com -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
fabric-ca-client affiliation add com.example -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055


2. 生成Admin@example.com的msp
1） 注册Admin@example.com

fabric-ca-client register --id.name Admin@example.com --id.type client --id.affiliation "com.example" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=123456 --csr.cn=example.com --csr.hosts=['example.com'] -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055

2） 登记Admin@example.com

fabric-ca-client enroll -u https://Admin@example.com:123456@orderer.ca.example.com:7055 --csr.cn=example.com --csr.hosts=['example.com'] -M ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

3） 生成msp

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/admincerts
mkdir -p ./crypto-config/ordererOrganizations/example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/msp/admincerts
mkdir -p ./crypto-config/ordererOrganizations/example.com/msp/cacerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/msp/cacerts/orderer-ca-example-com-7055.pem ./crypto-config/ordererOrganizations/example.com/msp/cacerts
mkdir -p ./crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ./crypto-config/ordererOrganizations/example.com/msp/tlscacerts/



生成节点OU材料
4） cd ./crypto-config/ordererOrganizations/example.com/msp/
新建config.yaml
vi config.yaml

NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/orderer-ca-example-com-7055.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/orderer-ca-example-com-7055.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/orderer-ca-example-com-7055.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/orderer-ca-example-com-7055.pem
    OrganizationalUnitIdentifier: orderer


3. 生成orderer.example.com的msp
docker exec -it orderer.ca.example.com bash
1） 注册orderer.example.com

fabric-ca-client register --id.name orderer.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer.example.com --csr.hosts=['orderer.example.com'] -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
2） 登记orderer.example.com

fabric-ca-client enroll -u https://orderer.example.com:123456@orderer.ca.example.com:7055 --csr.cn=orderer.example.com --csr.hosts=['orderer.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp
3） 生成msp

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/admincerts/
mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/signcerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/signcerts/
mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/cacerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/cacerts/orderer-ca-example-com-7055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/cacerts/


4. 生成orderer2.example.com的msp
docker exec -it orderer.ca.example.com bash
1） 注册orderer2.example.com

fabric-ca-client register --id.name orderer2.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer2.example.com --csr.hosts=['orderer2.example.com'] -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
2） 登记orderer2.example.com

fabric-ca-client enroll -u https://orderer2.example.com:123456@orderer.ca.example.com:7055 --csr.cn=orderer2.example.com --csr.hosts=['orderer2.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp
3） 生成msp

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/admincerts


5. 生成orderer3.example.com的msp
docker exec -it orderer.ca.example.com bash
1） 注册orderer3.example.com

fabric-ca-client register --id.name orderer3.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer3.example.com --csr.hosts=['orderer3.example.com'] -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
2） 登记orderer3.example.com

fabric-ca-client enroll -u https://orderer3.example.com:123456@orderer.ca.example.com:7055 --csr.cn=orderer3.example.com --csr.hosts=['orderer3.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp
3） 生成msp

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/admincerts


6. 生成orderer4.example.com的msp
docker exec -it orderer.ca.example.com bash
1） 注册orderer4.example.com

fabric-ca-client register --id.name orderer4.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer4.example.com --csr.hosts=['orderer4.example.com'] -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
2） 登记orderer4.example.com

fabric-ca-client enroll -u https://orderer4.example.com:123456@orderer.ca.example.com:7055 --csr.cn=orderer4.example.com --csr.hosts=['orderer4.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/msp
3） 生成msp

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/admincerts


7. 生成orderer5.example.com的msp
docker exec -it orderer.ca.example.com bash
1） 注册orderer5.example.com

fabric-ca-client register --id.name orderer5.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer5.example.com --csr.hosts=['orderer5.example.com'] -M ./crypto-config/ordererOrganizations/example.com/msp -u https://orderer-ca-admin:orderer-ca-adminpw@orderer.ca.example.com:7055
2） 登记orderer5.example.com

fabric-ca-client enroll -u https://orderer5.example.com:123456@orderer.ca.example.com:7055 --csr.cn=orderer5.example.com --csr.hosts=['orderer5.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/msp
3） 生成msp

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/msp/admincerts



(三)【docker】方式运行IntermediaCAtls1

 docker-compose -f docker-compose-ca-orderer-tls.yaml up -d 2>&1

IntermediaCAtls1生成证书
# 在下面的命令中，我们将ROOT CA的受信任根证书已复制到 ./fabric-ca-server/intermediacatls1/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./fabric-ca-server/root-ca/ca-cert.pem ./fabric-ca-server/intermediacatls1/root-ca-cert.pem
1. 生成example.com的msp
docker exec -it orderer-tls.ca.example.com bash
1） 登记example.com

fabric-ca-client enroll -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
2） 添加联盟成员

fabric-ca-client affiliation list -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
fabric-ca-client affiliation remove --force org1 -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
fabric-ca-client affiliation remove --force org2 -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
fabric-ca-client affiliation add com -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
fabric-ca-client affiliation add com.example -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055

2. 生成Admin@example.com的tls
1） 注册Admin@example.com

fabric-ca-client register --id.name Admin@example.com --id.type client --id.affiliation "com.example" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=123456 --csr.cn=example.com --csr.hosts=['example.com'] -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
2） 登记Admin@example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://Admin@example.com:123456@orderer-tls.ca.example.com:8055 --csr.cn=example.com --csr.hosts=['example.com'] -M ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls
3） 生成msp

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/tlsintermediatecerts/tls-orderer-tls-ca-example-com-8055.pem crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/tls-orderer-tls-ca-example-com-8055.pem
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/server.key
4. 生成orderer.example.com的msp
docker exec -it orderer-tls.ca.example.com bash
1） 注册orderer.example.com

fabric-ca-client register --id.name orderer.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer.example.com --csr.hosts=['orderer.example.com'] -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
2） 登记orderer.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer.example.com:123456@orderer-tls.ca.example.com:8055 --csr.cn=orderer.example.com --csr.hosts=['orderer.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls
3） 生成tls

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlsintermediatecerts/tls-orderer-tls-ca-example-com-8055.pem crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls-orderer-tls-ca-example-com-8055.pem
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt



5. 生成orderer2.example.com的msp
docker exec -it orderer-tls.ca.example.com bash
1） 注册orderer2.example.com

fabric-ca-client register --id.name orderer2.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer2.example.com --csr.hosts=['orderer2.example.com'] -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
2） 登记orderer2.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer2.example.com:123456@orderer-tls.ca.example.com:8055 --csr.cn=orderer2.example.com --csr.hosts=['orderer2.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls
3） 生成tls

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlsintermediatecerts/tls-orderer-tls-ca-example-com-8055.pem crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls-orderer-tls-ca-example-com-8055.pem
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

6. 生成orderer3.example.com的msp
docker exec -it orderer-tls.ca.example.com bash
1） 注册orderer3.example.com

fabric-ca-client register --id.name orderer3.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer3.example.com --csr.hosts=['orderer3.example.com'] -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
2） 登记orderer3.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer3.example.com:123456@orderer-tls.ca.example.com:8055 --csr.cn=orderer3.example.com --csr.hosts=['orderer3.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls
3） 生成tls

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlsintermediatecerts/tls-orderer-tls-ca-example-com-8055.pem crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls-orderer-tls-ca-example-com-8055.pem
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt


7. 生成orderer4.example.com的msp
docker exec -it orderer-tls.ca.example.com bash
1） 注册orderer4.example.com

fabric-ca-client register --id.name orderer4.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer4.example.com --csr.hosts=['orderer4.example.com'] -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
2） 登记orderer4.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer4.example.com:123456@orderer-tls.ca.example.com:8055 --csr.cn=orderer4.example.com --csr.hosts=['orderer4.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls
3） 生成tls

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/tlsintermediatecerts/tls-orderer-tls-ca-example-com-8055.pem crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls-orderer-tls-ca-example-com-8055.pem
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt


8. 生成orderer5.example.com的msp
docker exec -it orderer-tls.ca.example.com bash
1） 注册orderer5.example.com

fabric-ca-client register --id.name orderer5.example.com --id.type orderer --id.affiliation "com.example" --id.attrs '"role=orderer",ecert=true' --id.secret=123456 --csr.cn=orderer5.example.com --csr.hosts=['orderer5.example.com'] -M ./crypto-config/ordererOrganizations/example.com/tls -u https://orderer-tls-ca-admin:orderer-tls-ca-adminpw@orderer-tls.ca.example.com:8055
2） 登记orderer5.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://orderer5.example.com:123456@orderer-tls.ca.example.com:8055 --csr.cn=orderer5.example.com --csr.hosts=['orderer5.example.com'] -M ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls
3） 生成tls

退出 exit

mkdir -p ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/tlsintermediatecerts/tls-orderer-tls-ca-example-com-8055.pem crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls-orderer-tls-ca-example-com-8055.pem
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/signcerts/cert.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/keystore/*_sk ./crypto-config/ordererOrganizations/example.com/orderers/orderer5.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

(四)【docker】方式运行IntermediaCA2

docker-compose -f docker-compose-ca-org1.yaml up -d 2>&1

IntermediaCA2生成证书
# 在下面的命令中，我们将ROOT CA的受信任根证书已复制到 ./fabric-ca-server/intermediaca2/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./fabric-ca-server/root-ca/ca-cert.pem ./fabric-ca-server/intermediaca2/root-ca-cert.pem

1. 生成org1.example.com的msp
docker exec -it org1.ca.example.com bash
1） 登记org1.example.com

fabric-ca-client enroll --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
2） 添加联盟成员

fabric-ca-client affiliation list -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation remove --force org1 -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation remove --force org2 -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com.example -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com.example.org1 -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056

2. 生成Admin@example.com的msp

1） 注册Admin@example.com

fabric-ca-client register --id.name Admin@org1.example.com --id.type client --id.affiliation "com.example.org1" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=123456 --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
2） 添加联盟成员
2） 登记Admin@example.com

fabric-ca-client enroll -u https://Admin@org1.example.com:123456@org1.ca.example.com:7056 --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

退出 exit
3） 生成msp

mkdir -p ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca2/crypto-config/peerOrganizations/org1.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/admincerts
mkdir -p ./crypto-config/peerOrganizations/org1.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca2/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/msp/admincerts
mkdir -p ./crypto-config/peerOrganizations/org1.example.com/msp/cacerts
cp ./fabric-ca-client/intermediaca2/crypto-config/peerOrganizations/org1.example.com/msp/cacerts/org1-ca-example-com-7056.pem ./crypto-config/peerOrganizations/org1.example.com/msp/cacerts/


4）生成节点OU材料
cd ./crypto-config/peerOrganizations/org1.example.com/msp/
新建config.yaml
vi config.yaml

NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/org1-ca-example-com-7056.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/org1-ca-example-com-7056.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/org1-ca-example-com-7056.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/org1-ca-example-com-7056.pem
    OrganizationalUnitIdentifier: orderer


3. 生成peer0.org1.example.com的msp
docker exec -it org1.ca.example.com bash

1） 注册peer0.org1.example.com

fabric-ca-client register --id.name peer0.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=123456 --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
2） 登记peer0.org1.example.com

fabric-ca-client enroll -u https://peer0.org1.example.com:123456@org1.ca.example.com:7056 --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp
退出 exit

3） 生成msp

mkdir -p ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca2/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/admincerts 

4. 生成peer1.org1.example.com的msp
docker exec -it org1.ca.example.com bash

1） 注册peer1.org1.example.com

fabric-ca-client register --id.name peer1.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=123456 --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/msp -u https://org1-ca-admin:org1-ca-adminpw@org1.ca.example.com:7056
2） 登记peer1.org1.example.com

fabric-ca-client enroll -u https://peer1.org1.example.com:123456@org1.ca.example.com:7056 --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp
退出 exit

3） 生成msp

mkdir -p ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca2/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/admincerts 


(五)【docker】方式运行IntermediaCAtls2

docker-compose -f docker-compose-ca-org1-tls.yaml up -d 2>&1

IntermediaCAtls2生成证书
# 在下面的命令中，我们将ROOT CA的受信任根证书已复制到 ./fabric-ca-server/intermediacatls2/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./fabric-ca-server/root-ca/ca-cert.pem ./fabric-ca-server/intermediacatls2/root-ca-cert.pem

1. 生成org1.example.com的msp
docker exec -it org1-tls.ca.example.com bash 

1） 登记org1.example.com

fabric-ca-client enroll --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
2） 添加联盟成员

fabric-ca-client affiliation list -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
fabric-ca-client affiliation remove --force org1 -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
fabric-ca-client affiliation remove --force org2 -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
fabric-ca-client affiliation add com -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
fabric-ca-client affiliation add com.example -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
fabric-ca-client affiliation add com.example.org1 -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056

2. 生成Admin@example.com的msp
1） 注册Admin@example.com

fabric-ca-client register --id.name Admin@org1.example.com --id.type client --id.affiliation "com.example.org1" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=123456 --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
2） 登记Admin@example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://Admin@org1.example.com:123456@org1-tls.ca.example.com:8056 --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls

退出 exit
3） 生成tls

mkdir -p ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/tlsintermediatecerts/tls-org1-tls-ca-example-com-8056.pem ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/ca.crt
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/signcerts/cert.pem  ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/keystore/*_sk ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/server.key
3. 生成peer0.org1.example.com的msp
docker exec -it org1-tls.ca.example.com bash 
1） 注册peer0.org1.example.com

fabric-ca-client register --id.name peer0.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=123456 --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
2） 登记peer0.org1.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://peer0.org1.example.com:123456@org1-tls.ca.example.com:8056 --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls
3） 生成tls

mkdir -p ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlsintermediatecerts/tls-org1-tls-ca-example-com-8056.pem ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/*_sk ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

4. 生成peer1.org1.example.com的tls	
docker exec -it org1-tls.ca.example.com bash 
1） 注册peer1.org1.example.com

fabric-ca-client register --id.name peer1.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=123456 --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/tls -u https://org1-tls-ca-admin:org1-tls-ca-adminpw@org1-tls.ca.example.com:8056
2） 登记peer1.org1.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://peer1.org1.example.com:123456@org1-tls.ca.example.com:8056 --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com'] -M ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls

退出 exit
3） 生成tls

mkdir -p ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/tlsintermediatecerts/tls-org1-tls-ca-example-com-8056.pem ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls2/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/keystore/*_sk ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt


(六)【docker】方式运行IntermediaCA3

docker-compose -f docker-compose-ca-org2.yaml up -d 2>&1  

IntermediaCA3生成证书

# 在下面的命令中，我们将ROOT CA的受信任根证书已复制到 ./fabric-ca-server/intermediaca3/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./fabric-ca-server/root-ca/ca-cert.pem ./fabric-ca-server/intermediaca3/root-ca-cert.pem

1. 生成org2.example.com的msp
docker exec -it org2.ca.example.com bash
1） 登记org2.example.com

fabric-ca-client enroll --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
2） 添加联盟成员

fabric-ca-client affiliation list -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation remove --force org1 -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation remove --force org2 -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation add com -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation add com.example -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
fabric-ca-client affiliation add com.example.org2 -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057

2. 生成Admin@example.com的msp

1） 注册Admin@example.com

fabric-ca-client register --id.name Admin@org2.example.com --id.type client --id.affiliation "com.example.org2" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=123456 --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
2） 添加联盟成员
2） 登记Admin@example.com

fabric-ca-client enroll -u https://Admin@org2.example.com:123456@org2.ca.example.com:7057 --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

退出 exit
3） 生成msp

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca3/crypto-config/peerOrganizations/org2.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/admincerts
mkdir -p ./crypto-config/peerOrganizations/org2.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca3/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org2.example.com/msp/admincerts
mkdir -p ./crypto-config/peerOrganizations/org2.example.com/msp/cacerts
cp ./fabric-ca-client/intermediaca3/crypto-config/peerOrganizations/org2.example.com/msp/cacerts/org2-ca-example-com-7057.pem ./crypto-config/peerOrganizations/org2.example.com/msp/cacerts/


4）生成节点OU材料
cd ./crypto-config/peerOrganizations/org2.example.com/
新建config.yaml
vi config.yaml

NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/org2-ca-example-com-7057.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/org2-ca-example-com-7057.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/org2-ca-example-com-7057.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/org2-ca-example-com-7057.pem
    OrganizationalUnitIdentifier: orderer



3. 生成peer0.org2.example.com的msp
docker exec -it org2.ca.example.com bash

1） 注册peer0.org2.example.com

fabric-ca-client register --id.name peer0.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=123456 --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
2） 登记peer0.org2.example.com

fabric-ca-client enroll -u https://peer0.org2.example.com:123456@org2.ca.example.com:7057 --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp
退出 exit

3） 生成msp

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca3/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/admincerts 

4. 生成peer1.org2.example.com的msp
docker exec -it org2.ca.example.com bash

1） 注册peer1.org2.example.com

fabric-ca-client register --id.name peer1.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=123456 --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/msp -u https://org2-ca-admin:org2-ca-adminpw@org2.ca.example.com:7057
2） 登记peer1.org2.example.com

fabric-ca-client enroll -u https://peer1.org2.example.com:123456@org2.ca.example.com:7057 --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp
退出 exit

3） 生成msp

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/admincerts
cp ./fabric-ca-client/intermediaca3/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/admincerts 

(七)【docker】方式运行IntermediaCAtls3

docker-compose -f docker-compose-ca-org2-tls.yaml up -d 2>&1

IntermediaCAtls3生成证书
# 在下面的命令中，我们将ROOT CA的受信任根证书已复制到 ./fabric-ca-server/intermediacatls3/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./fabric-ca-server/root-ca/ca-cert.pem ./fabric-ca-server/intermediacatls3/root-ca-cert.pem

1. 生成org2.example.com的msp
docker exec -it org2-tls.ca.example.com bash 

1） 登记org2.example.com

fabric-ca-client enroll --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
2） 添加联盟成员

fabric-ca-client affiliation list -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
fabric-ca-client affiliation remove --force org1 -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
fabric-ca-client affiliation remove --force org2 -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
fabric-ca-client affiliation add com -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
fabric-ca-client affiliation add com.example -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
fabric-ca-client affiliation add com.example.org2 -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057

2. 生成Admin@example.com的msp
1） 注册Admin@example.com

fabric-ca-client register --id.name Admin@org2.example.com --id.type client --id.affiliation "com.example.org2" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=123456 --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
2） 登记Admin@example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://Admin@org2.example.com:123456@org2-tls.ca.example.com:8057 --csr.cn=org2.example.com --csr.hosts=['org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls

退出 exit
3） 生成tls

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/tlsintermediatecerts/tls-org2-tls-ca-example-com-8057.pem ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/ca.crt
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/signcerts/cert.pem  ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/keystore/*_sk ./crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/server.key

3. 生成peer0.org2.example.com的msp
docker exec -it org2-tls.ca.example.com bash 
1） 注册peer0.org2.example.com

fabric-ca-client register --id.name peer0.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=123456 --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
2） 登记peer0.org2.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://peer0.org2.example.com:123456@org2-tls.ca.example.com:8057 --csr.cn=peer0.org2.example.com --csr.hosts=['peer0.org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls
3） 生成tls

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlsintermediatecerts/tls-org2-tls-ca-example-com-8057.pem ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/signcerts/cert.pem ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/keystore/*_sk ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt




4. 生成peer1.org2.example.com的tls
docker exec -it org2-tls.ca.example.com bash 
1） 注册peer1.org2.example.com

fabric-ca-client register --id.name peer1.org2.example.com --id.type peer --id.affiliation "com.example.org2" --id.attrs '"role=peer",ecert=true' --id.secret=123456 --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/tls -u https://org2-tls-ca-admin:org2-tls-ca-adminpw@org2-tls.ca.example.com:8057
2） 登记peer1.org2.example.com

fabric-ca-client enroll -d --enrollment.profile tls -u https://peer1.org2.example.com:123456@org2-tls.ca.example.com:8057 --csr.cn=peer1.org2.example.com --csr.hosts=['peer1.org2.example.com'] -M ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls

退出 exit
3） 生成tls

mkdir -p ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/tlsintermediatecerts/tls-org2-tls-ca-example-com-8057.pem ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/signcerts/cert.pem ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/server.crt
cp ./fabric-ca-client/intermediacatls3/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/keystore/*_sk ./crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/server.key
cp ./fabric-ca-client/intermediacatls1/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-orderer-tls-ca-example-com-8055.pem ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt