// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// ETH钱包
contract EtherWallet {
    address payable public immutable owner;
    event Log(string funName, address from, uint256 value, bytes data);

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }

    function withdraw1() external {
        require(msg.sender == owner, "Not owner");
    
        // 固定提供 2300 gas，不足以执行复杂操作（如修改状态变量）
        // 转账失败时会自动回滚交易（抛出异常）
        // 不会返回布尔值，失败直接终止执行
        owner.transfer(100);
    }

    function withdraw2() external {
        require(msg.sender == owner, "Not owner");
        // 同样提供 2300 gas
        // 转账失败时不会回滚，而是返回 false
        // 需要手动检查返回值来处理失败情况
        bool success = payable(msg.sender).send(200);
        require(success, "Send failed");
    }

    function withdraw3() external {
        require(msg.sender == owner, "Not owner");
        // 不限制 gas（使用交易剩余的所有 gas）
        // 可以调用接收方的 fallback 或 receive 函数执行复杂逻辑
        // 返回两个值：布尔值（成功 / 失败）和字节数据（函数返回值）
        // 转账失败不会自动回滚，需手动处理
        (bool success, ) = msg.sender.call{value: 300}("");
        require(success, "Call Failed");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

}