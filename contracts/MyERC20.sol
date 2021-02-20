import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract MyERC20 is ERC20, ERC20Detailed("A Normal ERC20 Token ", "MyERC20", 18) {

  constructor() {
    _mint(address(0x6cc67A6D136ED539d6505C545240Cf99aD1396fB), 1000e18);
    _mint(address(0x1154b7579156EcD9AE2b24DA931f6fD3b42D5A5B), 1000e18);
    _mint(address(0x25fcf8cE4D6905Ac48Be7987ce6f8424206dfd9D), 1000e18);
    _mint(address(0x884F84283f11f9664DbbE3B935c55f0cD701f1bB), 1000e18);
    _mint(address(0x54c3a4c96A618977BdC5033FA9cabA6BDcc4397f), 1000e18);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal override {
    super._transfer(sender, recipient, amount);
  }

  function _mint(address account, uint amount) internal override {
    super._mint(account, amount);
  }

  function _burn(address account, uint amount) internal override {
    super._burn(account, amount);
  }
}