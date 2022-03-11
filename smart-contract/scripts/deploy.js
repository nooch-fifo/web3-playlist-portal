const main = async () => {
    // deploy smart contract to Ethereum block
    const [deployer] = await hre.ethers.getSigners();
    const accountBal = await deployer.getBalance();

    // deploying from my account
    console.log("Deploying contracts with account: ", deployer.address);
    console.log("Account balance: ", accountBal.toString());

       // compile Contract
       const playlistContractFactory = await hre.ethers.getContractFactory("PlaylistPortal");
       // create Ethereum block for this contract deployment
       const playlistContract = await playlistContractFactory.deploy({
           value: hre.ethers.utils.parseEther("0.001"),
       });
       // wait for contract to be deployed
       await playlistContract.deployed();

       // address of smart contaract on block
       console.log("PlaylistPortal address: ", playlistContract.address);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();