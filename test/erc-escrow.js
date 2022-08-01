const ERC2000 = artifacts.require('ERC2000')

contract('EscrowToken', accounts => {
    const [owner, user1, user2] = accounts
    let initalBalance
    let token
    before(async () => {
        //deployer.deploy(sender, 'foo', 'bar')
        token = await ERC2000.new('a', 'b', {from: owner, gas: 6000000})
        // token = await HelloERC20.new(owner, 10000)
        // initalBalance = await token.balanceOf(owner)
    })

    it('should mint total supply of tokens to initial account', async () => {
        // const balance = await token.balanceOf(owner)
        // assert(balance.eq(initalBalance))
    })
})
