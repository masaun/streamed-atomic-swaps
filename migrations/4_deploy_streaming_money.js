const StreamingMoney = artifacts.require('StreamingMoney')

const Sablier = artifacts.require("./Sablier.sol");
//const sablierContractAddress = "0xc04Ad234E01327b24a831e3718DBFcbE245904CC";  // This is the contract address of Sablier.sol for all of testnet (Ropsten, Rinkeby, Kovan)
const sablierContractAddress = Sablier.address;

module.exports = async (deployer) => {
  await deployer.deploy(
    StreamingMoney,
    sablierContractAddress
  );
}
