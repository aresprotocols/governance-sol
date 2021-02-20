pragma solidity =0.8.0;

contract Protocol {
  address public owner;
  uint256 public fee = 10;  // fee percent

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner) _;
  }

  function setFee(uint256 _fee) public onlyOwner {
    fee = _fee;
  }

  function transferOwnership(address newOwner) public onlyOwner  {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    owner = newOwner;
  }

}


