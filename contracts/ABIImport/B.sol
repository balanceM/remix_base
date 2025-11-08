// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./A.sol";

contract B {
    A public contractA;
    constructor(address _contractAAddress) {
        contractA = A(_contractAAddress);
    }

    function setValueToContractA(uint256 _value) public {
        contractA.setValue(_value);
    }
    function getValueFromContractA() public view returns (uint256) {
        return contractA.getValue();
    }
}