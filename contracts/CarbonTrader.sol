// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error CarbonTrader__NotOwner();
error CarbonTrader__ParamError();
error CarbonTrader__TransferFailed();

contract CarbonTrader {
    mapping (address => uint256) private s_addressToAllowances;
    mapping (address => uint256) private s_frozenAllowances;
    mapping (address => uint256) private s_auctionAmount;

    struct trade {
        address seller;
        uint256 sellAmount;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 minimumBidAmount;
        uint256 initPriceOfUnit;

        mapping (address => uint256) deposits;
        mapping (address => string) bidInfos;
        mapping (address => string) bidSecrets;
    }
    mapping (string => trade) private s_trade;

    address private immutable i_owner;
    IERC20 private immutable i_usdtToken;

    constructor (address usdtTokenAddress) {
        i_owner = msg.sender;
        i_usdtToken = IERC20(usdtTokenAddress);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert CarbonTrader__NotOwner();
        }
        _;
    }

    function issueAllowance(address user, uint256 amount) public onlyOwner {
        s_addressToAllowances[user] += amount;
    }

    function getAllowance(address user) public view returns (uint256) {
        return s_addressToAllowances[user];
    }

    function freezeAllowance(address user, uint256 freezeAmount) public onlyOwner {
        s_addressToAllowances[user] -= freezeAmount;
        s_frozenAllowances[user] += freezeAmount;
    }

    function unfreezeAllowance(address user, uint256 freezeAmount) public onlyOwner {
        s_addressToAllowances[user] += freezeAmount;
        s_frozenAllowances[user] -= freezeAmount;
    }

    function getFrozenAllowance(address user) public view returns (uint256) {
        return s_frozenAllowances[user];
    }

    function destroyAllowance(address user, uint256 destroyAmount) public onlyOwner {
        s_addressToAllowances[user] -= destroyAmount;
    }

    function destroyAllAllowance(address user) public onlyOwner {
        s_addressToAllowances[user] = 0;
        s_frozenAllowances[user] = 0;
    }

    function startTrade (
        string memory tradeID,
        uint256 amount,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 minimumBidAmount,
        uint256 initPriceOfUnit
    ) public {
        if (
            amount <= 0 ||
            startTimestamp >= endTimestamp ||
            minimumBidAmount <= 0 ||
            initPriceOfUnit <= 0 ||
            minimumBidAmount > amount
        ) revert CarbonTrader__ParamError();

        trade storage newTrade = s_trade[tradeID];
        newTrade.seller = msg.sender;
        newTrade.sellAmount = amount;
        newTrade.startTimestamp = startTimestamp;
        newTrade.endTimestamp = endTimestamp;
        newTrade.minimumBidAmount = minimumBidAmount;
        newTrade.initPriceOfUnit = initPriceOfUnit;

        s_addressToAllowances[msg.sender] -= amount;
        s_frozenAllowances[msg.sender] += amount;
    }

    function getTrade(string memory tradeID) public view returns (address, uint256, uint256, uint256, uint256, uint256) {
        trade storage curTrade = s_trade[tradeID];
        return (
            curTrade.seller,
            curTrade.sellAmount,
            curTrade.startTimestamp,
            curTrade.endTimestamp,
            curTrade.minimumBidAmount,
            curTrade.initPriceOfUnit
        );
    }

    function deposit(string memory tradeID, uint256 amount, string memory info) public {
        trade storage curTrade = s_trade[tradeID];

        bool success = i_usdtToken.transferFrom(msg.sender, address(this), amount);
        if (!success) revert CarbonTrader__TransferFailed();

        curTrade.deposits[msg.sender] = amount;
    }

    function refundDeposit(string memory tradeID) public {
        trade storage curTrade = s_trade[tradeID];
        uint256 depositAmount = curTrade.deposits[msg.sender];

        bool success = i_usdtToken.transfer(msg.sender, depositAmount);
        if (!success) revert CarbonTrader__TransferFailed();

        curTrade.deposits[msg.sender] = 0;
    }

    function setBidInfo(string memory tradeID, string memory info) public {
        trade storage curTrade = s_trade[tradeID];
        curTrade.bidInfos[msg.sender] = info;
    }

    function setBidSecret(string memory tradeID, string memory secret) public {
        trade storage curTrade = s_trade[tradeID];
        curTrade.bidSecrets[msg.sender] = secret;
    }

    function getBidSecret(string memory tradeID) public view returns(string memory) {
        trade storage curTrade = s_trade[tradeID];
        return curTrade.bidSecrets[msg.sender];
    }

    function finalizeAuctionAndTransferCarbon(string memory tradeID, uint256  allowanceAmount, uint256 addtionalAmountToPay) public {
        uint256 depositAmount = s_trade[tradeID].deposits[msg.sender];
        s_trade[tradeID].deposits[msg.sender] = 0;

        address seller = s_trade[tradeID].seller;
        s_auctionAmount[seller] += (depositAmount + addtionalAmountToPay);

        s_frozenAllowances[seller] = 0;

        s_addressToAllowances[msg.sender] += allowanceAmount;

        bool success = i_usdtToken.transferFrom(msg.sender, address(this), addtionalAmountToPay);
        if (!success) revert CarbonTrader__TransferFailed();
    }

    function withdrawAcutuibAmount() public {
        uint256 auctionAmount = s_auctionAmount[msg.sender];
        bool success = i_usdtToken.transfer(msg.sender, auctionAmount);
        if (!success) revert CarbonTrader__TransferFailed();

        s_auctionAmount[msg.sender] = 0;
    }
}