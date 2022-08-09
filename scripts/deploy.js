const main = async() => {

  // configuring for Goreli testnet

    const host = '0x22ff293e14F1EC3A09B137e9e06084AFd63adDF9';
    const fDAIx = '0xF2d68898557cCb2Cf4C10c3Ef2B034b2a69DAD00';
    const cfa_address = '0xEd6BcbF6907D4feEEe8a8875543249bEa9D308E8';

    //your address here...
    const owner = "0xd4C88BDeE3a708d6A13A7aFE3B5f93f1DA5375D8";

    const [deployer] = await ethers.getSigners();
    console.log("Deployed by ", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const streamContractFactory = await hre.ethers.getContractFactory("StreamFlow");
    const streamContract = await streamContractFactory.deploy(owner, host, cfa_address, fDAIx);
    await streamContract.deployed();
    
    console.log("Stream Contract address: ", streamContract.address);
}

const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.error(error);
      process.exit(1);
    }
  };
  
  runMain();

// using rinkeby