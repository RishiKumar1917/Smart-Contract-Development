// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/// @title DecentralizedStableCoin
/// @notice Educational stablecoin where mint/burn operations are restricted to DSCEngine owner.
contract DecentralizedStableCoin is ERC20, Ownable {
    error DecentralizedStableCoin__AmountMustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();
    error DecentralizedStableCoin__NotZeroAddress();

    constructor() ERC20("Decentralized Stable Coin", "DSC") Ownable(msg.sender) {}

    /// @notice Mints stablecoin to a recipient. Only DSCEngine owner can call.
    /// @param to Recipient account.
    /// @param amount Amount to mint.
    function mint(address to, uint256 amount) external onlyOwner returns (bool) {
        if (to == address(0)) revert DecentralizedStableCoin__NotZeroAddress();
        if (amount == 0) revert DecentralizedStableCoin__AmountMustBeMoreThanZero();
        _mint(to, amount);
        return true;
    }

    /// @notice Burns stablecoin held by this contract's owner context. Only DSCEngine owner can call.
    /// @param amount Amount to burn.
    function burn(uint256 amount) external onlyOwner {
        if (amount == 0) revert DecentralizedStableCoin__AmountMustBeMoreThanZero();
        if (balanceOf(msg.sender) < amount) revert DecentralizedStableCoin__BurnAmountExceedsBalance();
        _burn(msg.sender, amount);
    }
}
