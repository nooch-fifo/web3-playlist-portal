// The Hardhat Runtime Environment, or HRE for short, is an object containing all
// the functionality that Hardhat exposes by using the code specified in hardhat.config.js


const main = async () => {

    // compile Contract
    const playlistContractFactory = await hre.ethers.getContractFactory("PlaylistPortal");
    // create local Ethereum network for this contract
    const playlistContract = await playlistContractFactory.deploy({
        // deploy contract & fund it with .1 ETH from my wallet
        value: hre.ethers.utils.parseEther("0.1"),
    });
    // wait for contract to be deployed
    await playlistContract.deployed();

    // get address of deployed contract on blockchain
    console.log("Contract deployed to:", playlistContract.address);

    // CALL THE FUNCTIONS THAT ARE PUBLICLY DEPLOYED ON BLOCKCHAIN LIKE AN API 

    // check if my contract has sufficient balance
    let ethBalance = await hre.ethers.provider.getBalance(
        playlistContract.address
    );
    console.log("Smart contract ETH balance:", hre.ethers.utils.formatEther(ethBalance));

    let songCount;
    songCount = await playlistContract.getTotalSongs();
    console.log(songCount.toNumber());

    // send a song suggestion
    const songTxn = await playlistContract.suggestSong("Believe - Cher");
    await songTxn.wait(); // wait for the txn to be mined
    
    // Signer = object in Ethers.js that represents an Eth account (used for sending transactions to contracts/accounts)
    // create user accounts (me and a random person) 
    const [_, randomPerson] = await hre.ethers.getSigners();

    // simulate transaction w/ random person suggesting a 2nd song
    const songTxn2 = await playlistContract.connect(randomPerson).suggestSong("Billie Jean - Michael Jackson");
    await songTxn2.wait();
    
    // check contract eth balance after song suggestion 
    ethBalance = await hre.ethers.provider.getBalance(playlistContract.address);
    console.log("Smart contract ETH balance:", hre.ethers.utils.formatEther(ethBalance));

    let allSongs = await playlistContract.getAllSongs();
    console.log(allSongs);

    songCount = await playlistContract.getTotalSongs();
    console.log(songCount.toNumber());

    console.log("Contract deployed by:", _.address);
    
};

const runMain = async () => {
    try {
        await main();
        // exit Node process without error
        process.exit(0);
    } catch (error) {
        console.log(error);
        // exit Node process while indicating 'Uncaught Fatal Exception' error
        process.exit(1);
    }
};

runMain();