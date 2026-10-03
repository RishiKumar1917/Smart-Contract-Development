// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

library OracleLib {
    error OracleLib__StalePrice();
    error OracleLib__InvalidPrice();

    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        (roundId, answer, startedAt, updatedAt, answeredInRound) = priceFeed.latestRoundData();
        if (updatedAt == 0 || block.timestamp - updatedAt > TIMEOUT) revert OracleLib__StalePrice();
        if (answer <= 0) revert OracleLib__InvalidPrice();
    }
}
