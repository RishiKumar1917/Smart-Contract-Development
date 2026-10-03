// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private s_status = NOT_ENTERED;

    error ReentrancyGuardReentrantCall();

    modifier nonReentrant() {
        if (s_status == ENTERED) revert ReentrancyGuardReentrantCall();
        s_status = ENTERED;
        _;
        s_status = NOT_ENTERED;
    }
}
