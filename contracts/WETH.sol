// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// 包装 ETH 主币，作为 ERC20 的合约
contract WETH {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Transfer(address indexed src, address indexed toAds, uint256 amount);
    event Approval(address indexed src, address indexed delegateAds, uint256 amount);
    event Deposit(address indexed toAds, uint256 amount);
    event Withdraw(address indexed src, uint256 amount);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping (address => uint256)) public allowance;

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(amount <= balanceOf[msg.sender]);

        balanceOf[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function transferFrom(
        address src,
        address toAds, 
        uint256 amount
    ) public returns (bool) {
        require(balanceOf[src] >= amount);

        if (src != msg.sender) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        balanceOf[src] -= amount;
        balanceOf[toAds] += amount;
        emit Transfer(src, toAds, amount);
        return true;
    }

    function approval(address delegateAds, uint256 amount) public returns (bool) {
        require(delegateAds != msg.sender, "don't need approval yourself");
        allowance[msg.sender][delegateAds] = amount;
        emit Approval(msg.sender, delegateAds, amount);
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }
}