// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 < 0.9.0;

import "./TokenA.sol";
import "./TokenB.sol";

contract AmmDEX {
    address public owner;
    TokenA public tokenA;
    TokenB public tokenB;

    uint256 public rezervaA;
    uint256 public rezervaB;

    mapping(address => uint256) public lpUdio;
    uint256 public ukupniLPUdio;

    event LikvidnostDodana(address indexed pruzatelj, uint256 iznosA, uint256 iznosB, uint256 lpUdio);
    event LikvidnostPovucena(address indexed pruzatelj, uint256 iznosA, uint256 iznosB);
    event Swap(address indexed korisnik, string smjer, uint256 iznosUlaz, uint256 iznosIzlaz);

    constructor(address _tokenA, address _tokenB) {
        owner = msg.sender;
        tokenA = TokenA(_tokenA);
        tokenB = TokenB(_tokenB);
    }

    function dodajLikvidnost(uint256 _iznosA, uint256 _iznosB) public {
        require(_iznosA > 0 && _iznosB > 0, "Iznosi moraju biti veci od 0");

        tokenA.transferFrom(msg.sender, address(this), _iznosA);
        tokenB.transferFrom(msg.sender, address(this), _iznosB);

        uint256 noviLP;
        if (ukupniLPUdio == 0) {
            noviLP = _iznosA + _iznosB;
        } else {
            noviLP = (_iznosA * ukupniLPUdio) / rezervaA;
        }

        lpUdio[msg.sender] += noviLP;
        ukupniLPUdio += noviLP;
        rezervaA += _iznosA;
        rezervaB += _iznosB;

        emit LikvidnostDodana(msg.sender, _iznosA, _iznosB, noviLP);
    }

    function povuciLikvidnost(uint256 _lpIznos) public {
        require(_lpIznos > 0, "Iznos mora biti veci od 0");
        require(lpUdio[msg.sender] >= _lpIznos, "Nedovoljno LP udjela");

        uint256 iznosA = (_lpIznos * rezervaA) / ukupniLPUdio;
        uint256 iznosB = (_lpIznos * rezervaB) / ukupniLPUdio;

        require(iznosA > 0 && iznosB > 0, "Iznos povlacenja je prenizak");

        lpUdio[msg.sender] -= _lpIznos;
        ukupniLPUdio -= _lpIznos;
        rezervaA -= iznosA;
        rezervaB -= iznosB;

        tokenA.transfer(msg.sender, iznosA);
        tokenB.transfer(msg.sender, iznosB);

        emit LikvidnostPovucena(msg.sender, iznosA, iznosB);
    }

    function swapAzaB(uint256 _iznosA) public returns (uint256) {
        require(_iznosA > 0, "Iznos mora biti veci od 0");
        require(rezervaA > 0 && rezervaB > 0, "Bazen je prazan");

        uint256 iznosANakonNaknade = _iznosA * 997;
        uint256 iznosB = (rezervaB * iznosANakonNaknade) / (rezervaA * 1000 + iznosANakonNaknade);

        require(iznosB > 0, "Iznos zamjene je prenizak");
        require(rezervaB >= iznosB, "Nedovoljno rezervi TKB");

        tokenA.transferFrom(msg.sender, address(this), _iznosA);
        tokenB.transfer(msg.sender, iznosB);

        rezervaA += _iznosA;
        rezervaB -= iznosB;

        emit Swap(msg.sender, "TKA -> TKB", _iznosA, iznosB);
        return iznosB;
    }

    function swapBzaA(uint256 _iznosB) public returns (uint256) {
        require(_iznosB > 0, "Iznos mora biti veci od 0");
        require(rezervaA > 0 && rezervaB > 0, "Bazen je prazan");

        uint256 iznosBNakonNaknade = _iznosB * 997;
        uint256 iznosA = (rezervaA * iznosBNakonNaknade) / (rezervaB * 1000 + iznosBNakonNaknade);

        require(iznosA > 0, "Iznos zamjene je prenizak");
        require(rezervaA >= iznosA, "Nedovoljno rezervi TKA");

        tokenB.transferFrom(msg.sender, address(this), _iznosB);
        tokenA.transfer(msg.sender, iznosA);

        rezervaB += _iznosB;
        rezervaA -= iznosA;

        emit Swap(msg.sender, "TKB -> TKA", _iznosB, iznosA);
        return iznosA;
    }

    function izracunajCijenu(uint256 _iznosUlaz, uint256 _rezervaUlaz, uint256 _rezervaIzlaz)
        public pure returns (uint256)
    {
        require(_iznosUlaz > 0, "Iznos mora biti veci od 0");
        require(_rezervaUlaz > 0 && _rezervaIzlaz > 0, "Rezerve moraju biti vece od 0");

        uint256 ulazNakonNaknade = _iznosUlaz * 997;
        return (_rezervaIzlaz * ulazNakonNaknade) / (_rezervaUlaz * 1000 + ulazNakonNaknade);
    }

    function stanjeRezervacija() public view returns (uint256, uint256) {
        return (rezervaA, rezervaB);
    }

    function mojLPUdio() public view returns (uint256) {
        return lpUdio[msg.sender];
    }
}