const StreamingMoney = artifacts.require('StreamingMoney')

const Sablier = artifacts.require("./Sablier.sol");
const sablierContractAddress = Sablier.address;

module.exports = async (deployer) => {
  await deployer.deploy(
    StreamingMoney,
    sablierContractAddress
  );
}
