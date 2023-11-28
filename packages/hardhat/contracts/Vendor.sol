pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
// import "hardhat/console.sol";

contract Vendor is Ownable {
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // create a payable buyTokens() function:
  function buyTokens() external payable {
    require(msg.value > 0, "no eth received");
    uint256 tokenAmt = msg.value * tokensPerEth;
    uint256 tokenBalance = yourToken.balanceOf(address(this));

    uint256 soldAmt = tokenBalance <= tokenAmt ? tokenBalance : tokenAmt;
    uint256 returnAmt = (soldAmt - tokenAmt) / tokensPerEth;
    require(soldAmt > 0, "no token to sell");
    yourToken.transfer(msg.sender, soldAmt);
    if (returnAmt > 0) {
      (bool success,) = payable(msg.sender).call{value: returnAmt}("");
      assert(success);
    }
    emit BuyTokens(msg.sender, msg.value, soldAmt);
  }

  // create a withdraw() function that lets the owner withdraw ETH
  function withdraw() onlyOwner external {
    payable(owner()).transfer(address(this).balance);
  }

  // create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 amount) external {
    uint256 amountOfETH = amount / tokensPerEth;
    uint256 ethBalance = address(this).balance;

    uint256 boughtETHAmt = ethBalance <= amountOfETH ? ethBalance : amountOfETH;
    uint256 soldTokenAmt = boughtETHAmt * tokensPerEth;
    require(boughtETHAmt > 0, "no eth available for exchange");
    yourToken.transferFrom(msg.sender, address(this), soldTokenAmt);
    (bool success,) = payable(msg.sender).call{value: boughtETHAmt}("");
    assert(success);
    emit SellTokens(msg.sender, soldTokenAmt, boughtETHAmt);
  }
}
