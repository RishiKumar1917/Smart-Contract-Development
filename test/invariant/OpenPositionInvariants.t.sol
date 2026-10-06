// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract OpenPositionInvariants is Test {
    DecentralizedStableCoin internal dsc;
    DSCEngine internal engine;
    MockERC20 internal weth;

    function setUp() external {
        weth = new MockERC20("WETH", "WETH");
        MockV3Aggregator ethUsd = new MockV3Aggregator(8, 2000e8);
        dsc = new DecentralizedStableCoin();

        address[] memory tokens = new address[](1);
        address[] memory feeds = new address[](1);
        tokens[0] = address(weth);
        feeds[0] = address(ethUsd);

        engine = new DSCEngine(tokens, feeds, address(dsc));
        dsc.transferOwnership(address(engine));
    }

    function invariantTotalSupplyBackedByCollateral() external view {
        uint256 collateralValue = engine.getAccountCollateralValue(address(this));
        assertTrue(dsc.totalSupply() <= collateralValue * 2);
    }
}
