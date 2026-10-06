// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract DecentralizedStableCoinTest is Test {
    DecentralizedStableCoin internal dsc;
    address internal user = address(1);

    function setUp() external {
        dsc = new DecentralizedStableCoin();
    }

    function testOnlyOwnerCanMint() external {
        vm.prank(user);
        vm.expectRevert(Ownable.OwnableUnauthorizedAccount.selector);
        dsc.mint(user, 1e18);
    }

    function testMintAndBurnByOwner() external {
        dsc.mint(user, 100e18);
        vm.startPrank(user);
        dsc.transfer(address(dsc), 50e18);
        vm.stopPrank();

        dsc.burn(50e18);
        assertEq(dsc.balanceOf(address(dsc)), 0);
        assertEq(dsc.balanceOf(user), 50e18);
    }
}
