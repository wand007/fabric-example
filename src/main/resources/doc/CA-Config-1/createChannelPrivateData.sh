
## 启动cli服务
docker-compose -f docker-compose-cli-peers.yaml up  -d 2>&1


docker exec -it cli-org1-peer0 bash
# 创建通道
peer channel create -o orderer1.org0.example.com:7050 -c $CHANNEL_NAME -f /usr/local/channel-artifacts/channel.tx --outputBlock /usr/local/channel-artifacts/$CHANNEL_NAME.block --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit

# 加入通道
docker exec -it cli-org1-peer0 bash

peer channel join -b /usr/local/channel-artifacts/$CHANNEL_NAME.block

exit

# 加入通道
docker exec -it cli-org1-peer1 bash

peer channel join -b /usr/local/channel-artifacts/$CHANNEL_NAME.block

exit

# 加入通道
docker exec -it cli-org2-peer0 bash

peer channel join -b /usr/local/channel-artifacts/$CHANNEL_NAME.block

exit

# 加入通道
docker exec -it cli-org2-peer1 bash

peer channel join -b /usr/local/channel-artifacts/$CHANNEL_NAME.block

exit

# 更新锚节点
docker exec -it cli-org1-peer0 bash

peer channel update -o orderer1.org0.example.com:7050 -c $CHANNEL_NAME -f /usr/local/channel-artifacts/Org1MSPanchors.tx --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit

# 更新锚节点
docker exec -it cli-org2-peer0 bash

peer channel update -o orderer1.org0.example.com:7050 -c $CHANNEL_NAME -f /usr/local/channel-artifacts/Org2MSPanchors.tx --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit


# pee0-org1安装链码
docker exec -it cli-org1-peer0 bash

# 设置golang的环境变量
pushd /opt/gopath/src/github.com/hyperledger/chaincode/marbles02_private/go/
GO111MODULE=on go mod vendor
popd

# 打包链码
peer lifecycle chaincode package /usr/local/chaincode-artifacts/marbles02_private.tar.gz --path /opt/gopath/src/github.com/hyperledger/chaincode/marbles02_private/go/ --lang golang --label marbles02_private_1

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/marbles02_private.tar.gz

# 将链码id设置变量,便于我们后面的使用
export CC_PACKAGE_ID=marbles02_private_1:a7fe3a7a4e0124b9a9b86960dac9a28464d1dbd598bbbfbe9ea868405f9ac411


# 查看peer0.org1.example.com链码安装结果
peer lifecycle chaincode queryinstalled

# 链码认证 根据设置的链码审批规则，只需要当前组织中的任意一个节点审批通过即可
peer lifecycle chaincode approveformyorg --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE --channelID $CHANNEL_NAME --name marbles02_private --version 1 --collections-config /opt/gopath/src/github.com/hyperledger/chaincode/marbles02_private/collections_config.json --init-required --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent

# 查看链码认证结果 此时只有Org1MSP审核通过了
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name marbles02_private --version 1 --sequence 1 --output json --init-required

exit


# pee0-org2安装链码
docker exec -it cli-org2-peer0 bash

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/marbles02_private.tar.gz

# 将链码id设置变量,便于我们后面的使用
export CC_PACKAGE_ID=marbles02_private_1:a7fe3a7a4e0124b9a9b86960dac9a28464d1dbd598bbbfbe9ea868405f9ac411


# 查看peer0.org2.example.com链码安装结果
peer lifecycle chaincode queryinstalled

# 链码认证 根据设置的链码审批规则，只需要当前组织中的任意一个节点审批通过即可
peer lifecycle chaincode approveformyorg --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE --channelID $CHANNEL_NAME --name marbles02_private --version 1 --collections-config /opt/gopath/src/github.com/hyperledger/chaincode/marbles02_private/collections_config.json  --signature-policy "OR('Org1MSP.member','Org2MSP.member')"  --init-required --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name marbles02_private --version 1.0 --collections-config /opt/gopath/src/github.com/hyperledger/chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $CORE_PEER_TLS_ROOTCERT_FILE

# 查看链码认证结果 此时Org1MSP和Org2MSP都审核通过了
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name marbles02_private --version 1 --sequence 1 --output json --init-required

exit

# pee1-org1安装链码
docker exec -it cli-org1-peer1 bash

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/marbles02_private.tar.gz

# 查看peer0.org2.example.com链码安装结果
peer lifecycle chaincode queryinstalled

exit

# pee1-org2安装链码
docker exec -it cli-org2-peer1 bash

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/marbles02_private.tar.gz

# 查看peer0.org2.example.com链码安装结果
peer lifecycle chaincode queryinstalled

exit

# 部署链码
docker exec -it cli-org1-peer0 bash

# 提交链码
peer lifecycle chaincode commit -o orderer1.org0.example.com:7050 --channelID $CHANNEL_NAME --name marbles02_private --version 1 --sequence 1 --collections-config /opt/gopath/src/github.com/hyperledger/chaincode/marbles02_private/collections_config.json  --init-required --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE  --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE

# 查询已经提交的链码
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name marbles02_private

# 链码实例化 2.0版本以后取消了这步操作
# peer chaincode instantiate -o orderer1.org0.example.com:7050 --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE -C mychannel -n marbles02_private -v 1.0 -c '{"Args":["Init","a","100","b","100"]}'

export MARBLE=$(echo -n "{\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
# 链码执行
peer chaincode invoke -o orderer1.org0.example.com:7050 --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE -C $CHANNEL_NAME -n marbles02_private --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --isInit -c '{"Args":["InitMarble"]}' --transient "{\"marble\":\"$MARBLE\"}" --waitForEvent



# Org1链码数据查询
docker exec -it cli-org1-peer0 bash

# Org1链码的私有数据
peer chaincode query -n marbles02_private -C mychannel -c '{"Args":["ReadMarble","marble1"]}'

# Org1链码的私有数据
peer chaincode query -n marbles02_private -C mychannel -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'



# Org2链码数据查询
docker exec -it cli-org2-peer0 bash

# Org2链码的私有数据
peer chaincode query -n marbles02_private -C mychannel -c '{"Args":["ReadMarble","marble1"]}'

# Org2链码的私有数据
peer chaincode query -n marbles02_private -C mychannel -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'





