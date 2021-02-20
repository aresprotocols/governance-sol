<template>
<div>
  <h1> 治理 DEMO - 余额投票</h1>
  <Header></Header>

  <el-card class="margining">
    <p>余额治理合约地址： {{ contractAddr }} </p>
    <p> 我的余额: {{ myBalance }} , 票数: {{ votes }} </p>

    <h3>提案</h3>
    <div class="row-center">
      <el-input v-model="target" placeholder="执行目标" ></el-input>
      <el-input v-model="signature" placeholder="执行函数" ></el-input>
      <el-input  v-model="param" placeholder="参数" ></el-input>
      <el-button @click="propose">发起提案</el-button>
    </div>

  <h3>提案列表</h3>

    <div v-for="(propose , id) in proposeList" :key="id" >
      <div > 提案编号：{{  id }} , 投票截止于：{{  propose.endBlock }} , 当前高度：{{ blockNum }} </div>
      <div > 动作： {{ propose.target }}:{{  propose.action }}:{{propose.calldata}}</div>

      <div> 提案状态: <b>{{  proposalState[propose.state] }}</b> <el-button v-if="propose.state==3" @click="execute(id)">执行</el-button> </div>
      <div> 投票数据:  {{  propose.forVotes }} 赞成票, {{  propose.againstVotes }} 反对票 </div>
      <div> 我的投票：{{  propose.myVotes }}
        <label v-if="propose.myVotes > 0 && propose.support">赞成票</label>
        <label v-if="propose.myVotes > 0 && !propose.support">反对票</label>
        <div v-if="propose.myVotes == 0">
          <el-button @click="voteFor(id)">赞成</el-button>
          <el-button @click="voteAgainst(id)">反对</el-button>
        </div>
      </div>
    </div>
  </el-card>


</div>
</template>

<script>
/* eslint-disable */

import Proxy from "../proxy.js";
import Header from "./Header.vue";


export default {
  name: 'HOME',
  data() {
    return {
      account: null,
      contractAddr: null,
      myBalance: null,
      blockNum: null,
      votes: null,

      target: null,
      signature: null,
      param: null,

      proposalState: ["等待投票", "投票中", "失败", "成功", "过期", "已执行"],
      proposeList: {}
    }
  },

  components: {
    'Header': Header
  },

  created() {
    Proxy.initWeb3Account((web3, acc) => {
      this.account = acc
      this.web3 = web3
      this.init()
    });
  },

  methods: {
    async init() {
      this.token = await Proxy.getMyERC20WithVotes();
      this.protocol = await Proxy.getProtocol();
      this.governor = await Proxy.getVoteByBalance();
      this.contractAddr = this.governor.address;
      this.getBlockNumber();
      this.getBalance();
      this.getProposes();
    },

    getBlockNumber() {
      this.web3.eth.getBlockNumber().then(r => {
        this.blockNum = r
      })
    },

    getBalance() {
      this.token.balanceOf(this.account).then((r) => {
        this.myBalance = this.web3.utils.fromWei(r);
      })

      this.token.getCurrentVotes(this.account).then((r) => {
        this.votes = this.web3.utils.fromWei(r);
      })

      // this.token.getPriorVotes(this.account, this.blockNum - 1).then((r) => {
      //   this.votes = this.web3.utils.fromWei(r);
      // })
    },

    approve() {
      let amount = this.web3.utils.toWei(this.stakeAmount);
      this.token.approve(this.contractAddr, amount, {from: this.account}).then(
        () => { this.getBlockNumber(); }
      )
    },


    async getProposes() {
      let num = await this.governor.proposalCount();
      for (let i = num.toNumber(); i > 0; i--) {
        try {
          await this.getPropose(i);
        } catch (e) {
          console.log(e);
        }

      }
    },

    async getPropose(id) {
      console.log("propose ID:" + id)
      let proposeInfo = await this.governor.proposals(id);
      let action = await this.governor.getActions(id);
      let state = await this.governor.state(id);
      let myReceipt = await this.governor.getReceipt(id, this.account)
      console.log(action.signatures[0])

      this.proposeList[proposeInfo.id] = {
        action: action.signatures[0],
        target: action.targets[0],
        calldata: action.calldatas[0],
        state: state.toNumber(),
        proposer: proposeInfo.proposer,
        forVotes: this.web3.utils.fromWei(proposeInfo.forVotes),
        againstVotes: this.web3.utils.fromWei(proposeInfo.againstVotes),
        endBlock: proposeInfo.endBlock,
        myVotes: this.web3.utils.fromWei(myReceipt.votes),
        support: myReceipt.support,
      }

      this.$forceUpdate();
    },

    propose() {
      let calldata ;
      if (this.signature == "setFee(uint256)") {
        calldata = this.web3.eth.abi.encodeParameter('uint256', this.param);
      } else {
        calldata = this.web3.eth.abi.encodeParameter("address", this.param);
      }

      this.commitPropose(this.target, 0, this.signature, calldata)
    },

    commitPropose(target, value, signature, calldata) {
      this.governor.propose([target],[value], [signature], [calldata], {from: this.account}).then(() => {
        return this.governor.proposalCount();
      }).then(id => {
        this.getPropose(id)
      })
    },

    execute(id) {
      this.governor.execute(id, {from: this.account}).then(() => {
        this.getPropose(id);
      })
    },

    voteFor(id) {
      this.governor.castVote(id, true, {from: this.account}).then(() => {
        this.getPropose(id);
      })
    },

    voteAgainst(id) {
      this.governor.castVote(id, false, {from: this.account}).then(() => {
        this.getPropose(id);
      })
    },


  }
}
</script>
