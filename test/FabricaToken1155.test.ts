import {assert, config, expect, use} from 'chai'
import {Contract, utils} from 'ethers'
import {deployContract, MockProvider, solidity} from 'ethereum-waffle'
import FabricaToken from '../build/FabricaToken.json'

use(solidity);

describe('FabricaToken', () => {
  const [wallet, walletTo, validator] = new MockProvider().getWallets();
  let token: Contract;

  beforeEach(async () => {
    token = await deployContract(wallet, FabricaToken, ['ethereum']);
    // console.log('zzz token:', token?.deployTransaction?.data)
  });

  it('Mint successes and returns tokenId', async () => {
    const sessionId = 1;
    const supply = 100;
    const definition = "definition";
    const operatingAgreement = "operatingAgreement";
    const configuration = "configuration";
    const { data: tokenId } = await token.mint(walletTo.address, sessionId, supply, definition, operatingAgreement, configuration, validator.address);
    assert(tokenId);
  });

  it('Batch mint successes and returns array of tokenId', async () => {
    const sessionIds = [2, 3];
    const supplies = [10, 20];
    const definitions = ["definition 1", "definition 2"];
    const operatingAgreements = ["operatingAgreement 1", "ops 2"];
    const configurations = ["configuration 1", "config 2"];
    const { data: tokenIds } = await token.mintBatch(walletTo.address, sessionIds, supplies, definitions, operatingAgreements, configurations, [validator.address, validator.address]);
    // TODO: decode data, check if tokenIds is an array
    assert(tokenIds);
  });

  // it('Transfer adds amount to destination account', async () => {
  //   await token.transfer(walletTo.address, 7);
  //   expect(await token.balanceOf(walletTo.address)).to.equal(7);
  // });

  // it('Transfer emits event', async () => {
  //   await expect(token.transfer(walletTo.address, 7))
  //     .to.emit(token, 'Transfer')
  //     .withArgs(wallet.address, walletTo.address, 7);
  // });

  // it('Can not transfer above the amount', async () => {
  //   await expect(token.transfer(walletTo.address, 1007)).to.be.reverted;
  // });

  // it('Can not transfer from empty account', async () => {
  //   const tokenFromOtherWallet = token.connect(walletTo);
  //   await expect(tokenFromOtherWallet.transfer(wallet.address, 1))
  //     .to.be.reverted;
  // });

  // it('Calls totalSupply on FabricaToken contract', async () => {
  //   await token.totalSupply();
  //   expect('totalSupply').to.be.calledOnContract(token);
  // });

  // it('Calls balanceOf with sender address on FabricaToken contract', async () => {
  //   await token.balanceOf(wallet.address);
  //   expect('balanceOf').to.be.calledOnContractWith(token, [wallet.address]);
  // });
});