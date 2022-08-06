pragma solidity ^0.4.24;
import "zeppelin-solidity/contracts/token/ERC20/BasicToken.sol";

/*
  To reduce complicity,
    - no period
    - exchange rate is 1:1
*/

contract ERCEscrowMockup is BasicToken {

    struct EscrowAccount {
        uint256 totalFund;
        address seller;
        address linkContract;
        uint256 linkEscrowId;
        mapping(address => uint256) balances;
        uint32  numberOfByers;
    }

    mapping(uint256 => EscrowAccount) _escrowAccounts;
    uint256 _escrowNonce = 0;
    bool _escrowIsSeller;




    constructor (address initialAccount, uint256 initialBalance, bool isSeller) public {
        balances[initialAccount] = initialBalance;
        totalSupply_ = initialBalance;
        _escrowIsSeller = isSeller;
    }

    event EscrowAccountCreated(address creator, uint256 supply, uint256 escrowIdSeller, uint256 escrowIdBuyer);
    event EscrowAccountDeposit(uint256 escrowId, uint256 newBalance);

    event dummyEventAddr(address addr, uint32 u32Arg);
    event dummyEventUin256(uint256 value, uint32 u32Arg);

    function escrowBalanceOf(address _owner, uint256 _escrowId) public view returns (uint256) {
        EscrowAccount storage account = _escrowAccounts[_escrowId];
        return account.balances[_owner];
    }


    function escrowAccountCreate(uint256 totalFund, address linkAddress) public returns(uint256)  {

        address owner = msg.sender;
        uint256 nonce = 0;
        uint256 fundAmount = 0;

        uint256 balanceOfOwner = balances[owner];

        if(_escrowIsSeller){
            fundAmount = totalFund;
        }

        require(balanceOfOwner >= fundAmount, "fund amount exceeds balance");


        _escrowNonce ++;
        nonce = _escrowNonce;
        EscrowAccount storage account = _escrowAccounts[nonce];

        balances[owner] = balanceOfOwner - fundAmount;
        account.seller = owner;
        account.totalFund = totalFund;
        account.numberOfByers = 0;
        account.linkContract = linkAddress;
        account.balances[owner] = fundAmount;


        if(_escrowIsSeller){
          nonce = ERCEscrowMockup(linkAddress).escrowAccountCreate(totalFund, address(this));
          account.linkEscrowId = nonce;
          emit EscrowAccountCreated(owner, totalFund, _escrowNonce, nonce);
        }
        return _escrowNonce;

    }

    function escrowPurchase(uint256 _escrowId, uint256 _valuePayed) public {
        address owner = msg.sender;
        EscrowAccount storage account = _escrowAccounts[_escrowId];
        uint256 escrowBalance = account.balances[owner];



        if(_escrowIsSeller){
            require(account.linkEscrowId != 0, "already finished or not created");
            emit dummyEventAddr(owner, 1);
            ERCEscrowMockup(account.linkContract).escrowPurchase(account.linkEscrowId, _valuePayed);
            /*

            ERCEscrowMockup(account.linkContract).escrowPurchase(account.linkEscrowId, _valuePayed);

            //emit dummyEventAddr(account.seller);
            //emit dummyEventUin256(account.balances[account.seller]);
            //emit dummyEventUin256(_valuePayed);

            require(_valuePayed <= account.balances[account.seller], "no more token in seller contract");

            account.balances[account.seller] = account.balances[account.seller] - _valuePayed;
            account.balances[owner] = account.balances[owner] + _valuePayed;
            emit EscrowAccountDeposit(_escrowId, account.balances[owner]);
            */
        }else{
            emit dummyEventAddr(owner, 2);
            //emit dummyEventAddr(owner);
            //require(_valuePayed <= balances[owner], "in sufficient fund in buyer contract");
            //balances[owner] = balances[owner] - _valuePayed;
            //account.balances[owner] = account.balances[owner] + _valuePayed;
        }


    }







    function helper_bigInt256(uint256 _u256Val) public view returns (uint256) {
        return _u256Val;
    }
    function helper_getCurrentAddress() public view returns (address) {
      return address(this);
    }
}
