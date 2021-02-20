<template>
<div>
  <div class="nav">
    <el-link href="#/owner"> 治理 by 管理员 </el-link> |
    <el-link href="#/stake"> 治理 by 质押投票 </el-link> |
    <el-link href="#/vote"> 治理 by 余额投票 </el-link>
  </div>

  <el-card class="margining">
    <h3>协议信息</h3>
    <p> 当前费率: {{ currFee }} </p>
    <p> 协议合约地址: {{ protocolAddr }} </p>
    <p> 由地址 {{ ownAddr }} 治理</p>
  </el-card>

</div>
</template>

<script>

import Proxy from "../proxy.js";

export default {
  name: 'Header',

  data() {
    return {
      account: null,
      ownAddr: null,
      currFee: null,
      protocolAddr: null,
    }
  },

  created() {
    Proxy.initWeb3Account((web3, acc) => {
      this.account = acc;
      this.web3 = web3;
      this.init();
    });
  },

  methods: {
    async init() {
      this.protocol = await Proxy.getProtocol();
      this.protocolAddr = this.protocol.address;
      this.owner();
      this.getFee();
    },

    owner() {
      this.protocol.owner().then((r) => {
        this.ownAddr = r;
      });
    },

    getFee() {
      this.protocol.fee().then((r) => {
        this.currFee = r.toString();
      });
    },
  }

  }
</script>
