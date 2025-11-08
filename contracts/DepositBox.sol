// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// 存钱罐
contract DepositBox {
    address public immutable owner;

    constructor() payable {
        owner = msg.sender;
    }

    receive() external payable {}

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Not Owner");
        // selfdestruct(payable(msg.sender));
        require(amount <= address(this).balance, "amount is bigger than contract's balance");
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed");
    }
}