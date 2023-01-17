// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0<0.9.0;


interface MoleculeFactory {

    function queryStatus(address user, address [] memory moleculeNftAddress ) external view returns(bool);
    function queryGeneralBatchStatus(address addr, uint[] memory regionalId) external view returns(bool);
    function queryProviderBatchStatus(address addr, uint[] memory batchId, address provider) external view returns(bool);
}


contract MoleculeScanV2 {

    // goerli testnet moleculeFactory Address
    address private constant  moleculeFactory = 0x0590923445E29ae0BD11E0809D2d5572eDD64d1D;

    modifier moleculeNftVerify(address [] memory _moleculeNftAddress){
        MoleculeFactory M = MoleculeFactory(moleculeFactory);
     bool status = M.queryStatus(msg.sender,_moleculeNftAddress);
      require(status == true, "Molecule Access Denied ");
      _;
  }

  modifier moleculeGeneralBatchVerify(uint [] memory _regionalId){
      MoleculeFactory M = MoleculeFactory(moleculeFactory);
      bool status = M.queryGeneralBatchStatus(msg.sender,_regionalId);
      require(status == false,"Molecule Access Denied");
      _;
  }

  modifier moleculeProviderBatchVerify(uint[] memory _batchId,address _provider){
      MoleculeFactory M = MoleculeFactory(moleculeFactory);
      bool status = M.queryProviderBatchStatus(msg.sender,_batchId,_provider);
      require(status == false,"Molecule Access Denied");
      _;
  }

}
