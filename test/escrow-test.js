const ErcEscrowAccount = artifacts.require('./examples/ErcEscrowAccount')
const ERC20EscrowMockup = artifacts.require('./examples/ERC20EscrowMockup')


const util = require('util')
contract('ERCEscrowMockup', accounts => {
    const [creator, seller, buyer01, buyer02, ...others] = accounts

    let contracts

    before(async () => {
      const seller = await ERC20EscrowMockup.new()
      const escrow = await ErcEscrowAccount.new(10000, {from: seller})

      contracts = {
        escrow
      }
      console.log('-check point-1-', util.inspect(contracts, false, null, true))
    })
    it('create escrow will return valid id', async () => {

    })
})
