// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IERC20} from "./IERC20.sol";

contract SimpleDEX {
    IERC20 public tokenA;
    IERC20 public tokenB;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function swapTokenAForTokenB(
        uint256 amountA,
        uint256 minAmountB
    ) external returns (uint256) {
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer failed");
        uint256 amountB = amountA; // 1:1 ratio for simplicity
        require(amountB >= minAmountB, "Insufficient amountB");
        require(tokenB.transfer(msg.sender, amountB), "Transfer failed");
        return amountB;
    }

    function swapTokenBForTokenA(
        uint256 amountB,
        uint256 minAmountA
    ) external returns (uint256) {
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer failed");
        uint256 amountA = amountB; // 1:1 ratio for simplicity
        require(amountA >= minAmountA, "Insufficient amountA");
        require(tokenA.transfer(msg.sender, amountA), "Transfer failed");
        return amountA;
    }

    function addLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external {
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer failed");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer failed");
    }

    function removeLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external {
        require(tokenA.transfer(msg.sender, amountA), "Transfer failed");
        require(tokenB.transfer(msg.sender, amountB), "Transfer failed");
    }
}