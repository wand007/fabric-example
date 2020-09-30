
## 启动cli服务
docker-compose -f docker-compose-cli-peers.yaml up  -d 2>&1


docker exec -it cli-org1-peer1 bash
# 创建通道
peer channel create -o orderer1-org0:7050 -c mychannel -f /usr/local/channel-artifacts/channel.tx --outputBlock /usr/local/channel-artifacts/mychannel.block --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit

# 加入通道
docker exec -it cli-org1-peer1 bash

peer channel join -b /usr/local/channel-artifacts/mychannel.block

exit

# 加入通道
docker exec -it cli-org1-peer2 bash

peer channel join -b /usr/local/channel-artifacts/mychannel.block

exit

# 加入通道
docker exec -it cli-org2-peer1 bash

peer channel join -b /usr/local/channel-artifacts/mychannel.block

exit

# 加入通道
docker exec -it cli-org2-peer2 bash

peer channel join -b /usr/local/channel-artifacts/mychannel.block

exit

# 更新锚节点
docker exec -it cli-org1-peer1 bash

peer channel update -o orderer1-org0:7050 -c mychannel -f /usr/local/channel-artifacts/Org1MSPanchors.tx --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit

# 更新锚节点
docker exec -it cli-org2-peer1 bash

peer channel update -o orderer1-org0:7050 -c mychannel -f /usr/local/channel-artifacts/Org2MSPanchors.tx --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit


# pee1-org1安装链码
docker exec -it cli-org1-peer1 bash

# 打包链码
peer lifecycle chaincode package /usr/local/chaincode-artifacts/mycc.tar.gz --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ --lang golang --label mycc_1

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/mycc.tar.gz

# 将链码id设置变量,便于我们后面的使用
export CC_PACKAGE_ID=mycc_1:40aec53f0ee0193b0bd6b63862425298d90e9c3496a840bb54366b2fd66bd18f


# 查看peer1-org1链码安装结果
peer lifecycle chaincode queryinstalled

# 链码认证 根据设置的链码审批规则，只需要当前组织中的任意一个节点审批通过即可
peer lifecycle chaincode approveformyorg --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE --channelID mychannel --name mycc --version 1 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent

# 查看链码认证结果 此时只有org1MSP审核通过了
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name mycc --version 1 --sequence 1 --output json --init-required

exit


# pee1-org2安装链码
docker exec -it cli-org2-peer1 bash

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/mycc.tar.gz

# 将链码id设置变量,便于我们后面的使用
export CC_PACKAGE_ID=mycc_1:40aec53f0ee0193b0bd6b63862425298d90e9c3496a840bb54366b2fd66bd18f


# 查看peer1-org2链码安装结果
peer lifecycle chaincode queryinstalled

# 链码认证 根据设置的链码审批规则，只需要当前组织中的任意一个节点审批通过即可
peer lifecycle chaincode approveformyorg --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE --channelID mychannel --name mycc --version 1 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent

# 查看链码认证结果 此时org1MSP和org2MSP都审核通过了
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name mycc --version 1 --sequence 1 --output json --init-required

exit

# pee1-org2安装链码
docker exec -it cli-org2-peer2 bash


