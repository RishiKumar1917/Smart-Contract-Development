// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Vm} from "./Vm.sol";

contract Test {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function assertEq(uint256 a, uint256 b) internal pure {
        require(a == b, "ASSERT_EQ");
    }

    function assertEq(address a, address b) internal pure {
        require(a == b, "ASSERT_EQ_ADDR");
    }

    function assertGt(uint256 a, uint256 b) internal pure {
        require(a > b, "ASSERT_GT");
    }

    function assertLt(uint256 a, uint256 b) internal pure {
        require(a < b, "ASSERT_LT");
    }

    function assertTrue(bool condition) internal pure {
        require(condition, "ASSERT_TRUE");
    }
}
