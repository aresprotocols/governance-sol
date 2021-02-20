<template>
<div>
  <h1> 治理 DEMO - 管理员 </h1>
  <Header></Header>

  <el-card class="margining">
    <div class="row-center">
      <el-input v-model="newFee" placeholder="输入新费率"></el-input>
      <el-button @click="setFee">更新费率</el-button>
    </div>

    <div class="row-center">
      <el-input v-model="delegateTo" placeholder="输入新管理员"></el-input>
      <el-button @click="transferOwn">转移管理员</el-button>
    </div>
  </el-card>

</div>
</template>

<script>
/* eslint-disable */

import Proxy from "../proxy.js";
import Header from "./Header.vue";

export default {
  name: "HOME",
  data() {
    return {
      account: null,
      currFee: null,
      newFee: null,
      delegateTo: null

    };
  },

  components: {
    'Header': Header
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
      this.token = await Proxy.getMyERC20();
      this.protocol = await Proxy.getProtocol();
    },

    setFee() {
      this.protocol.setFee(this.newFee, {from: this.account}).then(() => {
        this.getFee()
      });
    },

    transferOwn() {
      try {
        this.protocol
          .transferOwnership(this.delegateTo, {
            from: this.account,
          })
          .then((r) => {
            this.owner();
          });
      } catch (e) {
        console.log("transferOwnerToGov error:" + e);
      }
    },

  },
};
</script>
