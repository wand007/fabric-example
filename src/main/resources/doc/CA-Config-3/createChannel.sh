
## 启动cli服务
docker-compose -f docker-compose-cli-peers.yaml up  -d 2>&1


docker exec -it cli.peer1.org1 bash
# 创建通道
peer channel create -o orderer1-org0:7050 -c mychannel -f /usr/local/channel-artifacts/channel.tx --tls true --cafile $ORDERER_CA

mv mychannel.block /usr/local/channel-artifacts/

# 加入通道
peer channel join -b /usr/local/channel-artifacts/mychannel.block



docker exec -it cli.peer1.org2 bash

peer channel join -b /usr/local/channel-artifacts/mychannel.block


# 更新锚节点
docker exec -it cli.peer1.org1 bash

peer channel update -o orderer1-org0:7050 -c mychannel -f /usr/local/channel-artifacts/Org1MSPanchors.tx --tls true --cafile $ORDERER_CA


docker exec -it cli.peer1.org2 bash

peer channel update -o orderer1-org0:7050 -c mychannel -f /usr/local/channel-artifacts/Org2MSPanchors.tx --tls true --cafile $ORDERER_CA