/* eslint-disable */

import Web3 from "web3";
import contract from "truffle-contract";
import MyERC20 from "../build/contracts/MyERC20.json";
import Protocol from "../build/contracts/Protocol.json";
import MyERC20WithVotes from "../build/contracts/MyERC20WithVotes.json";
import VoteByStake from "../build/contracts/VoteByStake.json";
import VoteByBalance from "../build/contracts/VoteByBalance.json";

export default {

  async initWeb3Account(callback) {
    if (window.ethereum) {
      this.provider = window.ethereum;
      try {
        await window.ethereum.enable();
      } catch (error) {
        console.error("User denied account access");
      }
    } else {
      this.provider = new Web3.providers.HttpProvider("http://127.0.0.1:7545");
    }
    this.web3 = new Web3(this.provider);

    this.web3.eth.getAccounts((err, accs) => {
      if (err != null) {
        console.error("无法获取账号， 是否安装了 Metamask");
        this.message = "";
        return;
      }

      if (accs.length === 0) {
        console.error("无法获取账号，Metamask 时候正确配置.");
        return;
      }
      // this.account = ;
      callback(this.web3, accs[0])

      ethereum.on('accountsChanged',(accounts) => {
        console.error("accountsChanged");
        callback(this.web3, accounts[0])
      });
    })
  },


  getMyERC20() {
    const proxy = contract(MyERC20)
    proxy.setProvider(this.provider)
    return proxy.deployed();
  },

  getProtocol() {
    const proxy = contract(Protocol)
    proxy.setProvider(this.provider)
    return proxy.deployed();
  },

  getMyERC20WithVotes() {
    const proxy = contract(MyERC20WithVotes)
    proxy.setProvider(this.provider)
    return proxy.deployed();
  },

  getVoteByStake() {
    const proxy = contract(VoteByStake)
    proxy.setProvider(this.provider)
    return proxy.deployed();
  },

  getVoteByBalance() {
    const proxy = contract(VoteByBalance)
    proxy.setProvider(this.provider)
    return proxy.deployed();
  }
  


}

