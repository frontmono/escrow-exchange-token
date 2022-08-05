pragma solidity ^0.4.24;
import "zeppelin-solidity/contracts/token/ERC20/BasicToken.sol";

contract ERCEscrowMockup is BasicToken {

    struct EscrowAccount {
        uint256 totalSupply;
        address seller;
        mapping(address => uint256) balances;
        uint32  numberOfByers;
    }

    constructor (address initialAccount, uint256 initialBalance) public {
        balances[initialAccount] = initialBalance;
        totalSupply_ = initialBalance;
    }
}
