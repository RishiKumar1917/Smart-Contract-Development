// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {MockERC20} from "../test/mocks/MockERC20.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address weth;
        address wbtc;
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        uint256 deployerKey;
    }

    uint8 private constant DECIMALS = 8;
    int256 private constant ETH_USD_PRICE = 2000e8;
    int256 private constant BTC_USD_PRICE = 30000e8;

    NetworkConfig private s_activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            s_activeNetworkConfig = getSepoliaEthConfig();
        } else {
            s_activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            weth: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtc: 0x29f2D40B0605204364af54EC677bD022dA425d03,
            wethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            wbtcUsdPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (s_activeNetworkConfig.weth != address(0)) return s_activeNetworkConfig;

        vm.startBroadcast();
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(DECIMALS, ETH_USD_PRICE);
        MockV3Aggregator btcUsdPriceFeed = new MockV3Aggregator(DECIMALS, BTC_USD_PRICE);
        MockERC20 wethMock = new MockERC20("Wrapped Ether", "WETH");
        MockERC20 wbtcMock = new MockERC20("Wrapped Bitcoin", "WBTC");
        vm.stopBroadcast();

        s_activeNetworkConfig = NetworkConfig({
            weth: address(wethMock),
            wbtc: address(wbtcMock),
            wethUsdPriceFeed: address(ethUsdPriceFeed),
            wbtcUsdPriceFeed: address(btcUsdPriceFeed),
            deployerKey: 0
        });
        return s_activeNetworkConfig;
    }

    function activeNetworkConfig() external view returns (NetworkConfig memory) {
        return s_activeNetworkConfig;
    }
}
