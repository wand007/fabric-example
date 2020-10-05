
## 启动cli服务
docker-compose -f docker-compose-cli-peers.yaml up  -d 2>&1


docker exec -it cli.org1.peer1 bash
# 创建通道
peer channel create -o orderer1.example.com:7050 -c $CHANNEL_NAME -f /usr/local/channel-artifacts/channel.tx --outputBlock /usr/local/channel-artifacts/$CHANNEL_NAME.block --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit

# 加入通道
docker exec -it cli.org1.peer1 bash

peer channel join -b /usr/local/channel-artifacts/$CHANNEL_NAME.block

exit

# 加入通道
docker exec -it cli.org1.peer2 bash

peer channel join -b /usr/local/channel-artifacts/$CHANNEL_NAME.block

exit

# 加入通道
docker exec -it cli.org2.peer1 bash

peer channel join -b /usr/local/channel-artifacts/$CHANNEL_NAME.block

exit

# 加入通道
docker exec -it cli.org2.peer2 bash

peer channel join -b /usr/local/channel-artifacts/$CHANNEL_NAME.block

exit

# 更新锚节点
docker exec -it cli.org1.peer1 bash

peer channel update -o orderer1.example.com:7050 -c $CHANNEL_NAME -f /usr/local/channel-artifacts/Org1MSPanchors.tx --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit

# 更新锚节点
docker exec -it cli.org2.peer1 bash

peer channel update -o orderer1.example.com:7050 -c $CHANNEL_NAME -f /usr/local/channel-artifacts/Org2MSPanchors.tx --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE

exit


# peer1.org1.example.com安装链码
docker exec -it cli.org1.peer1 bash

# 打包链码
peer lifecycle chaincode package /usr/local/chaincode-artifacts/mycc.tar.gz --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ --lang golang --label mycc_1

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/mycc.tar.gz

# 将链码id设置变量,便于我们后面的使用
export CC_PACKAGE_ID=mycc_1:40aec53f0ee0193b0bd6b63862425298d90e9c3496a840bb54366b2fd66bd18f


# 查看peer1.org1.example.com链码安装结果
peer lifecycle chaincode queryinstalled

# 链码认证 根据设置的链码审批规则，只需要当前组织中的任意一个节点审批通过即可
peer lifecycle chaincode approveformyorg --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE --channelID $CHANNEL_NAME --name mycc --version 1 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent

# 查看链码认证结果 此时只有Org1MSP审核通过了
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name mycc --version 1 --sequence 1 --output json --init-required

exit


# peer1.org2.example.com安装链码
docker exec -it cli.org2.peer1 bash

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/mycc.tar.gz

# 将链码id设置变量,便于我们后面的使用
export CC_PACKAGE_ID=mycc_1:40aec53f0ee0193b0bd6b63862425298d90e9c3496a840bb54366b2fd66bd18f


# 查看peer1.org2.example.com链码安装结果
peer lifecycle chaincode queryinstalled

# 链码认证 根据设置的链码审批规则，只需要当前组织中的任意一个节点审批通过即可
peer lifecycle chaincode approveformyorg --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE --channelID $CHANNEL_NAME --name mycc --version 1 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --waitForEvent

# 查看链码认证结果 此时Org1MSP和Org2MSP都审核通过了
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name mycc --version 1 --sequence 1 --output json --init-required

exit

# pee2.org1安装链码
docker exec -it cli.org1.peer2 bash

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/mycc.tar.gz

# 查看peer1.org2example.com链码安装结果
peer lifecycle chaincode queryinstalled

exit

# peer2.org2.example.com安装链码
docker exec -it cli.org2.peer2 bash

# 安装链码
peer lifecycle chaincode install /usr/local/chaincode-artifacts/mycc.tar.gz

# 查看peer2.org2.example.com链码安装结果
peer lifecycle chaincode queryinstalled

exit

# 部署链码
docker exec -it cli.org1.peer1 bash

# 提交链码
peer lifecycle chaincode commit -o orderer1.example.com:7050 --channelID $CHANNEL_NAME --name mycc --version 1 --sequence 1 --init-required --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer1.org1.example.com:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE  --peerAddresses peer1.org2example.com:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE

# 查询已经提交的链码
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name mycc


# 链码实例化 2.0版本以后取消了这步操作
# peer chaincode instantiate -o orderer1.example.com:7050 --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE -C mychannel -n mycc -v 1.0 -c '{"Args":["Init","a","100","b","100"]}'

# 链码执行
peer chaincode invoke -o orderer1.example.com:7050 --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE -C $CHANNEL_NAME -n mycc --peerAddresses peer1.org1.example.com:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer1.org2example.com:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --isInit -c '{"Args":["Init","a","100","b","100"]}' --waitForEvent

# 链码数据查询
peer chaincode query -n mycc -C mychannel -c '{"Args":["query","a"]}'

# 链码数据更新
peer chaincode invoke -o orderer1.example.com:7050 --tls true --cafile $CORE_PEER_TLS_ROOTCERT_FILE -C $CHANNEL_NAME -n mycc --peerAddresses peer1.org1.example.com:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses peer1.org2example.com:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE -c '{"Args":["invoke","a","b","10"]}'  --waitForEvent




