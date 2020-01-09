const PlatformRegistry = artifacts.require('PlatformRegistry')

module.exports = async (deployer) => {
  await deployer.deploy(
    PlatformRegistry
  );
}
