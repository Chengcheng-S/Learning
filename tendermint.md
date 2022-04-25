## Tendermint

[走进Cosmos之Tendermint (hyperchain.cn)](https://tech.hyperchain.cn/cosmos-5/)

Cosmos中的Tendermint Core核心模块主要包含共识算法和网络模块，网络模块采用gossip 协议。应用层的模块通过ABCI（Application Blockchain Interface）与Tendermint核心模块进行交互，在交互的过程中，由Tendermint完成选举Proposer，BFT三阶段共识以及区块执行的逻辑。

