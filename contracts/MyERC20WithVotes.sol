import "./ERC20.sol";
import "./ERC20Detailed.sol";

// DEMO 代码勿作为产品使用
contract MyERC20WithVotes is ERC20, ERC20Detailed("A Gov Token ", "MyERC20Votes", 18) {


  struct Checkpoint {
      uint fromBlock;
      uint votes;
  }

  mapping (address => mapping (uint => Checkpoint)) public checkpoints;
  mapping (address => uint) public numCheckpoints;
  
  /// @notice A record of each accounts delegate
  mapping (address => address) public delegates;

  event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
  event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

  constructor() {
    _mint(address(0x6cc67A6D136ED539d6505C545240Cf99aD1396fB), 1000e18);
    _mint(address(0x1154b7579156EcD9AE2b24DA931f6fD3b42D5A5B), 1000e18);
    _mint(address(0x25fcf8cE4D6905Ac48Be7987ce6f8424206dfd9D), 1000e18);
    _mint(address(0x884F84283f11f9664DbbE3B935c55f0cD701f1bB), 1000e18);
    _mint(address(0x54c3a4c96A618977BdC5033FA9cabA6BDcc4397f), 1000e18);
  }

  function _mint(address account, uint amount) internal override {
    super._mint(account, amount);

    if(delegates[account] == address(0)) {
      delegates[account] = account;
    } 
    _moveDelegates(address(0), delegates[account], amount);
    
  }

  function _burn(address account, uint amount) internal override {
    super._burn(account, amount);

    _moveDelegates(delegates[account], address(0), amount);
  }


  function _transfer(address sender, address recipient, uint256 amount) internal override {
    super._transfer(sender, recipient, amount);
    _moveDelegates(delegates[sender], delegates[recipient], amount);
  }

    function getCurrentVotes(address account) external view returns (uint) {
        uint nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    // 获取某高度对应的对应投票数
    function getPriorVotes(address account, uint blockNumber) public view returns (uint) {
        require(blockNumber < block.number, "getPriorVotes: not yet determined");

        uint nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint lower = 0;
        uint upper = nCheckpoints - 1;
        while (upper > lower) {
            uint center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint delegatorBalance = balanceOf(delegator);
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

    function _moveDelegates(address srcRep, address dstRep, uint amount) internal {
      if (srcRep != dstRep && amount > 0) {
        if (srcRep != address(0)) {
            uint srcRepNum = numCheckpoints[srcRep];
            uint srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
            uint srcRepNew = srcRepOld - amount;
            _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
        }

        if (dstRep != address(0)) {
            uint dstRepNum = numCheckpoints[dstRep];
            uint dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
            uint dstRepNew = dstRepOld +  amount;
            _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
        }
      }
    }

    function _writeCheckpoint(address delegatee, uint nCheckpoints, uint oldVotes, uint newVotes) internal {
      uint blockNumber = block.number;

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }


}