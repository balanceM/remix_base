// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Callee {
    event FuncCalled(string);

    function foo() external payable {
        emit FuncCalled("this is foo");
    }

    // receive() external payable {
    //     emit FuncCalled("this is receive");
    // }

    fallback() external payable {
        emit FuncCalled("this is fallback");
    }
}

contract caller {
    address payable callee;

    constructor() payable {
        callee = payable(address(new Callee()));
    }

    function transferReceive() external {
        callee.transfer(1);
    }

    function sendReceive() external {
        bool success = callee.send(1);
        require(success, "Failed to send Ether");
    }

    function callReceive() external {
        (bool success, bytes memory data) = callee.call{value: 1}("");
        require(success, "Failed to send Ether");
    }

    function callFoo() external {
        (bool success, bytes memory data) = callee.call{value: 1}(
            abi.encodeWithSignature("Foo()")
        );
        require(success, "Failed to send Ether");
    }

    function callFallback() external {
        (bool success, bytes memory data) = callee.call{value: 1} (
            abi.encodeWithSignature("funcNotExist()")
        );
        require(success, "Failed to send Ether");
    }
}
contract Demo {
    //当给返回值赋值后，并且有个return，以最后的return为主
    function test() public pure returns (uint256 mul) {
        uint256 a = 10;
        mul = 100;
        return a;
    }
}

contract Utils {
    function sum(uint[] memory arr) public pure returns (uint256 res) {
        res = 0;
        for(uint i=0; i < arr.length; i++) {
            res +=arr[i];
        }
    }
}