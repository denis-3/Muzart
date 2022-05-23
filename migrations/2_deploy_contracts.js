const MuzartProtocol = artifacts.require("MuzartProtocol");
const Muzcoin = artifacts.require("MUZToken");
const MuzartNFT = artifacts.require("MuzartNFT");

module.exports = function(deployer) {
  deployer.deploy(Muzcoin);
  deployer.deploy(MuzartProtocol);
  deployer.deploy(MuzartNFT);
};

/* A note about deploying it on-chain:
Deploy Muzcoin.sol first, then set its address in other contracts.
Next, deploy Muzart.sol
Finally, deploy MuzartNFT.
*/
