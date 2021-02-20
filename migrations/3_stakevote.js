var MyERC20 = artifacts.require("MyERC20");
var VoteByStake = artifacts.require("VoteByStake");



module.exports = async function(deployer) {
  let token = await MyERC20.deployed();
  return deployer.deploy(VoteByStake, token.address);
}


