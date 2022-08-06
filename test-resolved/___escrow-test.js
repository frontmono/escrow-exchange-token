const ERCEscrowMockup = artifacts.require('./examples/ERCEscrowMockup')
const util = require('util')
contract('ERCEscrowMockup', accounts => {
    const [creator, seller, buyer01, buyer02, ...others] = accounts
    let initalBalance
    let tokenSeller
    let tokenBuyer
    const escrowID = 1
    const totalFund = 100
    const payed01 = 10
    let bigIntEscrowID
    let bigIntTotalFund
    let bigIntZero
    let bigIntPayed01
    before(async () => {
        tokenSeller = await ERCEscrowMockup.new(creator, 10000, true)
        tokenBuyer = await ERCEscrowMockup.new(creator, 10000, false)
        console.log('--contract address---', {sellerContract: tokenSeller.address, buyerContract: tokenBuyer.address})
        await tokenSeller.transfer(seller, 1000, {from: creator})
        await tokenBuyer.transfer(buyer01, 100, {from: creator})
        await tokenBuyer.transfer(buyer02, 100, {from: creator})
        // console.log('---1--', await tokenSeller.helper_getCurrentAddress());
        // console.log('---2--', tokenSeller.address);
        initalBalance = await tokenSeller.balanceOf(creator)

        bigIntTotalFund = await tokenSeller.helper_bigInt256(totalFund)
        bigIntEscrowID = await tokenSeller.helper_bigInt256(escrowID)
        bigIntZero = await tokenSeller.helper_bigInt256(0)
        bigIntPayed01 = await tokenSeller.helper_bigInt256(payed01)
    })
    it('create escrow will return valid id', async () => {
        const res1 = await tokenSeller.escrowAccountCreate(100, tokenBuyer.address, {from: seller})
        // console.log('---res1--', res1)
        // console.log('---res1 logs-1-', res1.logs)
        //console.log('---res1 logs-2-', res1.logs[0].args)
        const logParam = res1.logs[0].args.escrowIdSeller
        assert(logParam.eq(bigIntEscrowID))
    })
    it('seller and buyer total balance is 100, 0', async () => {
        let resSeller = await tokenSeller.escrowBalanceOf(seller, escrowID)
        let resBuyer = await tokenBuyer.escrowBalanceOf(seller, escrowID)
        //console.log('----check---', {resSeller, resBuyer})
        assert(resSeller.eq(bigIntTotalFund))
        assert(resBuyer.eq(bigIntZero))
    })
    it('buyer pay escrow ', async () => {
        let resSeller = await tokenSeller.escrowPurchase(escrowID, payed01, {from: buyer01})
        console.log('-check point-1-', util.inspect(resSeller, false, null, true))
    })
})
