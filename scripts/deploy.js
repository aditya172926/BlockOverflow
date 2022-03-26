const main = async() => {

    const host = '0xeD5B5b32110c3Ded02a07c8b8e97513FAfb883B6';
    const fDAIx = '0x745861AeD1EEe363b4AaA5F1994Be40b1e05Ff90';
    const cfa_address = '0xF4C5310E51F6079F601a5fb7120bC72a70b96e2A';

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