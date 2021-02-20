var MyERC20 = artifacts.require("MyERC20");

module.exports = function(deployer) {
  return deployer.deploy(MyERC20);
}
