var MyERC20WithVotes = artifacts.require("MyERC20WithVotes");


module.exports = async function(deployer) {
  return deployer.deploy(MyERC20WithVotes);
}


