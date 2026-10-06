// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract DSCEngineTest is Test {
    DecentralizedStableCoin internal dsc;
    DSCEngine internal engine;
    MockERC20 internal weth;
    MockV3Aggregator internal ethUsd;

    address internal user = address(1);
    uint256 internal constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        weth = new MockERC20("WETH", "WETH");
        ethUsd = new MockV3Aggregator(8, 2000e8);
        dsc = new DecentralizedStableCoin();

        address[] memory tokens = new address[](1);
        address[] memory feeds = new address[](1);
        tokens[0] = address(weth);
        feeds[0] = address(ethUsd);

        engine = new DSCEngine(tokens, feeds, address(dsc));
        dsc.transferOwnership(address(engine));

        weth.mint(user, STARTING_BALANCE);
        vm.prank(user);
        weth.approve(address(engine), type(uint256).max);
    }

    function testDepositCollateralUpdatesBalance() external {
        vm.prank(user);
        engine.depositCollateral(address(weth), 10 ether);
        assertEq(engine.getCollateralBalanceOfUser(user, address(weth)), 10 ether);
    }

    function testCannotMintBeyondHealthFactor() external {
        vm.startPrank(user);
        engine.depositCollateral(address(weth), 1 ether);
        vm.expectRevert();
        engine.mintDsc(1500e18);
        vm.stopPrank();
    }

    function testMintWithinLimits() external {
        vm.startPrank(user);
        engine.depositCollateral(address(weth), 1 ether);
        engine.mintDsc(900e18);
        vm.stopPrank();

        assertEq(dsc.balanceOf(user), 900e18);
    }

    function testLiquidationFlow() external {
        address liquidator = address(2);
        weth.mint(liquidator, STARTING_BALANCE);

        vm.startPrank(user);
        engine.depositCollateral(address(weth), 10 ether);
        engine.mintDsc(9000e18);
        vm.stopPrank();

        vm.prank(address(this));
        ethUsd.updateAnswer(1000e8);

        vm.startPrank(liquidator);
        weth.approve(address(engine), type(uint256).max);
        engine.depositCollateral(address(weth), 10 ether);
        engine.mintDsc(2000e18);
        dsc.approve(address(engine), type(uint256).max);
        engine.liquidate(address(weth), user, 1000e18);
        vm.stopPrank();

        uint256 hf = engine.getHealthFactor(user);
        assertGt(hf, 0);
    }

    function testFuzzCannotMintIfUndercollateralized(uint256 collateralAmount, uint256 mintAmount) external {
        collateralAmount = collateralAmount % 100 ether;
        mintAmount = mintAmount % 200_000e18;
        if (collateralAmount == 0 || mintAmount == 0) return;

        vm.startPrank(user);
        engine.depositCollateral(address(weth), collateralAmount);
        uint256 maxMint = (engine.getUsdValue(address(weth), collateralAmount) * 50) / 100;
        if (mintAmount > maxMint) {
            vm.expectRevert();
            engine.mintDsc(mintAmount);
        } else {
            engine.mintDsc(mintAmount);
            assertEq(dsc.balanceOf(user), mintAmount);
        }
        vm.stopPrank();
    }
}
