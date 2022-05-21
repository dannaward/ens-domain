// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const [owner, owner2] = await hre.ethers.getSigners();

  // We get the contract to deploy
  const Domains = await hre.ethers.getContractFactory("Domains");
  const domains = await Domains.deploy();

  await domains.deployed();

  console.log("Domains deployed to:", domains.address);
  console.log("Domains deployed by", owner.address);

  const registerDanna = await domains.connect(owner2).register("danna");
  await registerDanna.wait();
  console.log("Danna was registered.");

  const dannaDomainOwnerAddress = await domains.getAddress("danna");
  console.log("Owner of danna address is ...", dannaDomainOwnerAddress);

  // let setDannaRecordFromNonOwner = await domains.setRecord("danna", "0x123456546"); // 에러가 나야 함
  // await setDannaRecordFromNonOwner.wait()

  let setDannaRecordFromNonOwner = await domains.connect(owner2).setRecord("danna", "0x123456546"); // 에러가 나야 함
  await setDannaRecordFromNonOwner.wait()

  const dannaDomain = await domains.getRecord("danna");
  console.log("OK!!!", dannaDomain);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
