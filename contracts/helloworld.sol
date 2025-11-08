// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract HelloWorld {
    string storeMsg;

    function set(string memory message) public {
        storeMsg = message;
    }

    function get() public view returns (string memory)  {
        return  storeMsg;        
    }

    type Weight is uint128;
    type Price is uint128;

    Weight w = Weight.wrap(10);
    Price  p = Price.wrap(5);

    Weight wp = Weight.wrap(Weight.unwrap(w) + Price.unwrap(p));


}