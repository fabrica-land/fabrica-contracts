import { assert, config, expect, use } from 'chai'
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';
import { Contract, utils, BigNumber } from 'ethers';
import FabricaToken from '../build/FabricaToken.json'
import Validator from '../build/Validator.json'

use(solidity);

config.includeStack = true;

describe('FabricaToken', async () => {
  const [wallet, walletTo] = new MockProvider().getWallets();
  let validator: Contract;
  let token: Contract;

  beforeEach(async () => {
    validator = await deployContract(wallet, Validator, []);
    token = await deployContract(wallet, FabricaToken, []);
  });

  it('Mint succeeds and returns an tokenId', async () => {
    const sessionId = 1;
    const supply = 100;
    const definition = "definition";
    const operatingAgreement = "operatingAgreement";
    const configuration = "configuration";
    const result = await token.mint([walletTo.address], sessionId, [supply], definition, operatingAgreement, configuration, validator.address);
    const { data: tokenId } = result;

    const generatedId = await token.generateId(walletTo.address, sessionId, operatingAgreement);
    const decoded = BigNumber.from(generatedId._hex).toString();
    console.log('zzz tokenId', tokenId);
    console.log('zzz generatedId', generatedId);
    console.log('zzz decoded', decoded);

    const balanceOf = await token.balanceOf(walletTo.address, generatedId._hex);
    console.log('zzz balanceOf', balanceOf);

    assert(tokenId);
  });

  it('Batch mint succeeds and returns an array of tokenIds', async () => {
    const sessionIds = [2, 3];
    const supply = 20;
    const definitions = ["definition 1", "definition 2"];
    const operatingAgreements = ["operatingAgreement 1", "ops 2"];
    const configurations = ["configuration 1", "config 2"];
    const { data: tokenIds } = await token.mintBatch([walletTo.address], sessionIds, [supply], definitions, operatingAgreements, configurations, [validator.address, validator.address]);

    assert(tokenIds);
  });

  it('generateId call succeeds and returns the tokenId consistently', async () => {
    const sessionId = 1;
    const sessionId2 = 2;
    const operatingAgreement = "operatingAgreement";
    const { _hex: id } = await token.generateId(wallet.address, sessionId, operatingAgreement);
    const { _hex: id2 } = await token.generateId(wallet.address, sessionId, operatingAgreement);
    const { _hex: id3 } = await token.generateId(wallet.address, sessionId2, operatingAgreement);

    assert(id === id2 && id !== id3);
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