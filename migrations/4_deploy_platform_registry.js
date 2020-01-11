const PlatformRegistry = artifacts.require('PlatformRegistry')

const Sablier = artifacts.require("./Sablier.sol");
const sablierContractAddress = Sablier.address;

module.exports = async (deployer) => {
  await deployer.deploy(
    PlatformRegistry,
    sablierContractAddress
  );
}
