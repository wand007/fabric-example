
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