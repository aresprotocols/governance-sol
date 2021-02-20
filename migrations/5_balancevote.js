var MyERC20WithVotes = artifacts.require("MyERC20WithVotes");
var VoteByBalance = artifacts.require("VoteByBalance");


module.exports = async function(deployer) {
  let token = await MyERC20WithVotes.deployed();
  return deployer.deploy(VoteByBalance, token.address);
}


