pragma solidity ^0.4.24;


contract ErcEscrowAccount {
    struct EscrowBalance {
        uint256 seller;
        uint256 buyer;
    }

    mapping(uint256 => EscrowBalance) _balances;
    address _creator;

    uint32 _rule_totalBuyer = 0;

    constructor(uint256 totalSupply) {


    }


}
