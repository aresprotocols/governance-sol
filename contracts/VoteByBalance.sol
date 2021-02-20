pragma solidity =0.8.0;

import "./IERC20WithVotes.sol";

// DEMO 代码勿作为产品使用
contract VoteByBalance {

  IERC20WithVotes public immutable myToken;

  uint public proposalCount;

  event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, uint startBlock, uint endBlock);
  event VoteCast(address voter, uint proposalId, bool support, uint votes);
  event ProposalExecuted(uint id, uint eta);

  struct Proposal {
    uint id;
    address proposer;
    uint eta;
    address[] targets;
    uint[] values;
    string[] signatures;
    bytes[] calldatas;
    uint startBlock;
    uint endBlock;
    uint forVotes;
    uint againstVotes;
    bool executed;
    mapping (address => Receipt) receipts;
  }

  mapping (uint => Proposal) public proposals;

  /// @notice Ballot receipt record for a voter
  struct Receipt {
      bool hasVoted;
      bool support;
      uint votes;
  }

  /// @notice Possible states that a proposal may be in
  enum ProposalState {
    Pending,
    Active,
    Defeated,
    Succeeded,
    Expired,
    Executed
  }

  constructor(IERC20WithVotes token) {
    myToken = token;
  }

  // 提案（提交执行对象与动作）
  function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas) public returns (uint) {
      require(proposalCount == 0 || state(proposalCount) > ProposalState.Active, "Wait last Proposal end");

      require(targets.length == values.length && targets.length == signatures.length && targets.length == calldatas.length, "Governor::propose: proposal function information arity mismatch");
      require(targets.length != 0, "Governor::propose: must provide actions");

      uint startBlock = block.number;
      uint endBlock = startBlock + 5;

      proposalCount++;

      Proposal storage newProposal = proposals[proposalCount];
      newProposal.id = proposalCount;
      newProposal.proposer = msg.sender;
      newProposal.eta = 0;
      newProposal.targets =  targets;
      newProposal.values=  values;
      newProposal.signatures = signatures;
      newProposal.calldatas = calldatas;
      newProposal.startBlock = startBlock;
      newProposal.endBlock = endBlock;
      newProposal.forVotes = 0;
      newProposal.againstVotes = 0;
      newProposal.executed = false;

      emit ProposalCreated(newProposal.id, msg.sender, targets, values, signatures, calldatas, startBlock, endBlock);
      return newProposal.id;
  }

    function execute(uint proposalId) public payable {
        require(state(proposalId) == ProposalState.Succeeded, "Governor::execute: only Succeeded proposal can be executed ");
        Proposal storage proposal = proposals[proposalId];
        proposal.eta = block.timestamp;
        proposal.executed = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            _executeTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i]);
        }
        emit ProposalExecuted(proposalId, block.timestamp);
    }

    function _executeTransaction(address target, uint value, string memory signature, bytes memory data) internal returns (bytes memory) {
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "_executeTransaction: Transaction execution reverted.");
        return returnData;
    }

    function getActions(uint proposalId) public view returns (address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas) {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

    function getReceipt(uint proposalId, address voter) public view returns (Receipt memory) {
      return proposals[proposalId].receipts[voter];
    }


  function state(uint proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId && proposalId > 0, "Governor::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else { 
            return ProposalState.Expired;
        } 
    }

  function castVote(uint proposalId, bool support) public {
    
    require(state(proposalId) == ProposalState.Active, "voting is closed");
    address voter = msg.sender;
    Proposal storage proposal = proposals[proposalId];
    Receipt storage receipt = proposal.receipts[voter];

    require(receipt.hasVoted == false, "voter already voted");

    // 投票票数 = 票数
    uint votes = myToken.getPriorVotes(voter, proposal.startBlock);

    if (support) {
        proposal.forVotes = proposal.forVotes + votes;
    } else {
        proposal.againstVotes = proposal.againstVotes + votes;
    }

    receipt.hasVoted = true;
    receipt.support = support;
    receipt.votes = votes;

    emit VoteCast(voter, proposalId, support, votes);

  }

}