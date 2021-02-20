pragma solidity =0.8.0;
import "./IERC20.sol";

interface IERC20WithVotes is IERC20 {
  function getPriorVotes(address account, uint blockNumber) external view returns (uint);
}