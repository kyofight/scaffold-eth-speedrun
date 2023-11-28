// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public deadline = block.timestamp + 72 hours;
  uint256 public constant threshold = 1 ether;
  bool public openForWithdraw = false;

  event Stake(address sender, uint256 amount);

  modifier notCompleted {
    require(block.timestamp >= deadline, "deadline is not met");
    require(exampleExternalContract.completed() == false, "already completed");
    _;
  }

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  function stake() external payable {
    require(msg.value > 0, "stake ETH must greater than 0");
    require(block.timestamp <= deadline, "deadline passed");
    unchecked {
      balances[msg.sender] += msg.value;
    }
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() notCompleted external payable {
    require(openForWithdraw == false, "withdraw is available");
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() notCompleted external payable {
    require(address(this).balance < threshold, "threshold was met");
    require(openForWithdraw == true, "withdraw is not available");
    require(balances[msg.sender] > 0, "you have no stake");
    uint256 pay = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool success,) = msg.sender.call{value: pay}("");
    assert(success);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    return deadline <= block.timestamp ? 0 : deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    (bool success,) = address(this).delegatecall(
        abi.encodeWithSignature("stake()")
    );
    assert(success);
  }

}
