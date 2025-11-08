// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract A {
    uint256 public value;
    function setValue(uint256 value_) public {
        value = value_;
    }
    function getValue() public view returns (uint256) {
        return value;
    }
}