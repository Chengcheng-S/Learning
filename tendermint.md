## Tendermint

cosmos 白皮书

https://v1.cosmos.network/resources/whitepaper/zh-CN



cosmos 官方文档

https://tutorials.cosmos.network/academy/2-main-concepts/architecture.html



https://docs.tendermint.com/master/tendermint-core/mempool/



https://tutorials.cosmos.network/academy/2-main-concepts/messages.html



https://docs.tendermint.com/v0.35/introduction/what-is-tendermint.html

https://docs.tendermint.com/master/introduction/what-is-tendermint.html

cosmos-sdk tx lifetime

https://docs.cosmos.network/main/basics/query-lifecycle.html



[走进Cosmos之Tendermint (hyperchain.cn)](https://tech.hyperchain.cn/cosmos-5/)

Cosmos中的Tendermint Core核心模块主要包含共识算法和网络模块，网络模块采用gossip 协议。应用层的模块通过ABCI（Application Blockchain Interface）与Tendermint核心模块进行交互，在交互的过程中，由Tendermint完成选举Proposer，BFT三阶段共识以及区块执行的逻辑。



Tendermint core主要由两个组件组成：

- 区块链共识引擎： 确保事务以相同的顺序记录在每台机器上。
- 通用程序接口 ABCI(application blockchain interface),使交易可以用任何编程语言处理。与其他区块链和共识解决方案不同，这种解决方案预先打包了内置状态机。

### ABCI Application

ABCI接口定义分为三类：信息查询、交易检索、共识相关的处理

```go
type Application interface {
	// Info/Query Connection
	Info(context.Context, *RequestInfo) (*ResponseInfo, error)    // Return application info
	Query(context.Context, *RequestQuery) (*ResponseQuery, error) // Query for state

	// Mempool Connection
	CheckTx(context.Context, *RequestCheckTx) (*ResponseCheckTx, error) // Validate a tx for the mempool

	// Consensus Connection
	InitChain(context.Context, *RequestInitChain) (*ResponseInitChain, error) // Initialize blockchain w validators/other info from TendermintCore
	PrepareProposal(context.Context, *RequestPrepareProposal) (*ResponsePrepareProposal, error)
	ProcessProposal(context.Context, *RequestProcessProposal) (*ResponseProcessProposal, error)
	// Commit the state and return the application Merkle root hash
	Commit(context.Context) (*ResponseCommit, error)
	// Create application specific vote extension
	ExtendVote(context.Context, *RequestExtendVote) (*ResponseExtendVote, error)
	// Verify application's vote extension data
	VerifyVoteExtension(context.Context, *RequestVerifyVoteExtension) (*ResponseVerifyVoteExtension, error)
	// Deliver the decided block with its txs to the Application
	FinalizeBlock(context.Context, *RequestFinalizeBlock) (*ResponseFinalizeBlock, error)

	// State Sync Connection
	ListSnapshots(context.Context, *RequestListSnapshots) (*ResponseListSnapshots, error)                // List available snapshots
	OfferSnapshot(context.Context, *RequestOfferSnapshot) (*ResponseOfferSnapshot, error)                // Offer a snapshot to the application
	LoadSnapshotChunk(context.Context, *RequestLoadSnapshotChunk) (*ResponseLoadSnapshotChunk, error)    // Load a snapshot chunk
	ApplySnapshotChunk(context.Context, *RequestApplySnapshotChunk) (*ResponseApplySnapshotChunk, error) // Apply a shapshot chunk
}
```

- `DeliverTX` （*区块中的每笔交易都通过此消息进行传递*）应用的主要工作流程， 通过该消息真正执行交易，包含验证交易、更新状态等。
- `CheckTX` 类似于`DeilverTX` 仅用于验证交易，Tendermint core的mempool首先使用CheckTx 检查交易的有效性，只把有效的消息广播出去。
- `Commit` 通知应用程序计算当前的世界状态，以放入到下一个区块头中。

一个应用程序可以有多个ABCI 链接，tendermint core 创建应用程序的三个ABCI 链接：

- 在mempool中广播时验证交易
- 共识引擎运行区块提案
- 查询应用程序状态

### 共识引擎

在区块链的每个高度，都会运行一个`round-base`的协议来确定下一个区块，每轮由三步以及两个特殊步骤完成：

- `propose` `prevote` `precommit`
- commit
- NewHeight 

`NewHeight -> (Propose -> Prevote -> Precommit)+ -> Commit -> NewHeight ->...` 

`Propose->Prevote->Precommit` 称为`round`在某个高度可能需要多轮。

如：

- 指定的proposer 离线
- 指定提议者的提议区块无效
- 指定提议者的区块没有即时传播
- 提议区块有效，但是在区块达到`pre-commit`时，没有及时收到提议区块2/3+的prevote，足够的验证者节点。尽管需要2/3+的prevote才能进入下一步，但至少有一个验证者可能已经投了<nil> 或恶意投递到了其他块
- 提议区块是有效的，并且为足够多的节点收到了2/3 +的prevote，对于验证节点，没有接收到提议区块2/3 + 的precommit



Tendermint 异步的BFT共识协议。

协议的参与者称为验证者。验证者们轮流提出交易区块并对其进行投票。每个高度只有一个区块。若一个区块不能正常完成提交，就会进入下一轮，且新的验证者可以针对该高度提出一个新的区块。成功提交区块需要两个阶段的投票`pre-vote` `pre-commit` ，当超过2/3的验证者在同一轮中为同一个块`pre-commmit` 投票时，该区块就会被提交。

> 当超过2/3的验证者为同一个区块pre-vote 投票后，系统判定为`polka` 也就是说每个`pre-commit` 都必须在同一轮中通过一个`polka`证明是合理的。

Tendermint 引入**锁定机制**（容错机制），确保没有两个验证者在同一高度提交不同的区块。 一旦验证者`pre-commit`区块，它就会被锁定在该区块中。即：

- 必须为他锁定的区块投票
- 它只能解锁并`precommit` 一个新块，若之后的一轮中有一个用于该块的polka

一旦验证人预投票了一个区块，那么该验证人就会被锁定在这个区块。然后该验证人必须在预提交的区块进行预投票。当前一轮预提议和预投票没成功提交区块时，该验证人就会被解锁，然后进行对新块的下一轮预提交。

> porposal 定义了一个区块的提案，通过`BlockID` 字段引用区块，必须由正确的提议者签名才使给定的HeightRound被视为有效。其可能取决于前一轮的投票，即所谓的`proof-of-block` (POL)若`POLRound >=0` 则blockId 对应着锁定在POLRound中的块。 

```go
type Proposal struct {
	Type      tmproto.SignedMsgType
	Height    int64     `json:"height,string"`
	Round     int32     `json:"round"`     // there can not be greater than 2_147_483_647 rounds
	POLRound  int32     `json:"pol_round"` // -1 if null.
	BlockID   BlockID   `json:"block_id"`
	Timestamp time.Time `json:"timestamp"`
	Signature []byte    `json:"signature"`
}
```



在propose开始阶段，被选中的proposer会给全网络广播一个proposal。如果proposer锁定在上一轮中的block上，那么proposer在本轮中发起的proposal会是锁定的block，并且在proposal中加上proof-of-lock字段。

在Prevote开始阶段，每个Validator会判断自己是否锁定在上一轮的proposal区块上，如果锁定在之前的proposal区块中，那么在本轮中继续为之前锁定的proposal区块签名并广播prevote投票。否则为当前轮中接收到的proposal区块签名并广播prevote投票。如果由于某些原因当前Validator并没有收到任何proposal区块，那么签名并广播一个空的prevote投票。

在Precommit开始阶段，每个Validator会判断，如果收集到了超过2/3 prevote投票，那么为这个区块签名并广播precommit投票，并且当前Validator会锁定在这个区块上，同时释放之前锁定的区块，一个Validator一次只能锁定在一个区块上。

如果一个Validator收集到超过2/3空区块（nil)的prevote投票，那么释放之前锁定的区块。处于锁定状态的Validator会为锁定的区块收集prevote投票，并把这些投票打成包放入proof-of-lock中，proof-of-lock会在之后的propose阶段用到。如果一个Validator没有收集到超过2/3的prevote投票，那么它不会锁定在任何区块上。

在precommit阶段后期，如果Validator收集到超过2/3的precommit投票，那么Validator进入到commit阶段。否则进入下一轮的propose阶段。

#### commit 阶段

- validator 收到被全网commit的区块，validator会为这个区块广播一个commit投票
- Validator需要为被全网络precommit的区块，收集到超过2/3commit投票。

一旦两个条件全部满足了，节点会将commitTime设置到当前时间上，并且会进入NewHeight阶段。在整个共识过程的任何阶段，一旦节点收到超过2/3commit投票，那么它会立刻进入到commit阶段。

 

































