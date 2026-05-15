// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenA.sol";
import "./TokenB.sol";

contract SimpleDEX {
    address public owner;
    TokenA public tokenA;
    TokenB public tokenB;

    // Fiksni tečaj: 1 TKA = 2 TKB
    uint256 public rate = 2;

    event Swap(address indexed korisnik, uint256 iznosA, uint256 iznosB);

    constructor(address _tokenA, address _tokenB) {
        owner = msg.sender;
        tokenA = TokenA(_tokenA);
        tokenB = TokenB(_tokenB);
    }

    // Korisnik šalje TKA, dobiva TKB
    function swapAzaB(uint256 _iznosA) public {
        require(_iznosA > 0, "Iznos mora biti veci od 0");

        uint256 iznosB = _iznosA * rate;

        require(tokenB.balanceOf(address(this)) >= iznosB, "DEX nema dovoljno TKB");

        tokenA.transferFrom(msg.sender, address(this), _iznosA);
        tokenB.transfer(msg.sender, iznosB);

        emit Swap(msg.sender, _iznosA, iznosB);
    }

    // Korisnik šalje TKB, dobiva TKA
    function swapBzaA(uint256 _iznosB) public {
        require(_iznosB > 0, "Iznos mora biti veci od 0");

        uint256 iznosA = _iznosB / rate;

        require(iznosA > 0, "Iznos zamjene je prenizak - posalji najmanje 2 TKB");
        require(tokenA.balanceOf(address(this)) >= iznosA, "DEX nema dovoljno TKA");

        tokenB.transferFrom(msg.sender, address(this), _iznosB);
        tokenA.transfer(msg.sender, iznosA);

        emit Swap(msg.sender, _iznosB, iznosA);
    }

    // Vlasnik puni DEX s TokenB likvidnošću
    function depositTokenB(uint256 _iznos) public {
        require(msg.sender == owner, "Samo vlasnik moze puniti DEX");
        tokenB.transferFrom(msg.sender, address(this), _iznos);
    }

    // Vlasnik puni DEX s TokenA likvidnošću
    function depositTokenA(uint256 _iznos) public {
        require(msg.sender == owner, "Samo vlasnik moze puniti DEX");
        tokenA.transferFrom(msg.sender, address(this), _iznos);
    }

    // Provjera stanja tokena u DEX-u
    function stanjeDEX() public view returns (uint256 stanjeA, uint256 stanjeB) {
        stanjeA = tokenA.balanceOf(address(this));
        stanjeB = tokenB.balanceOf(address(this));
    }
}