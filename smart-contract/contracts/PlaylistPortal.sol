// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract PlaylistPortal {
    // state variables
    uint256 totalSongs;
    uint256 private randomRaffle;

    // Event arguments get stored in transaction log on Blockchain (associated with address of contract)
    event NewSong(address indexed from, uint256 timestamp, string song);

    // struct = custom datatype to hold a record of relevant attributes
    struct Suggestion {
        address suggester;
        string song;
        uint256 timestamp;
    }

    // store an array of structs (think Objects) to store all song suggestions
    Suggestion[] suggestions;

    // COOLDOWN functionality:
    // create a mapping with user address and the last time they suggested a song
    mapping(address => uint256) public lastSuggested;

    constructor() payable {
        console.log("First ever smart contract!");

        // set initial raffle with Soliditiy-given #s (how hard block is to mine & Unix time of block processed)
        randomRaffle = (block.timestamp + block.difficulty) % 100;
    }

    function suggestSong(string memory _song) public {
        // make sure current timestamp is at least 15 mins past the last suggestion timestamp
        require(
            lastSuggested[msg.sender] + 15 minutes < block.timestamp,
            "Please Wait 15 Minutes Until Suggesting Another Song"
        );
        // update current timestamp for user
        lastSuggested[msg.sender] = block.timestamp;    

        // increment state variable
        totalSongs += 1;
        console.log("%s has added a song, %s", msg.sender, _song);

        // add new song to suggestions array
        suggestions.push(Suggestion(msg.sender, _song, block.timestamp));

        // generate new raffle for next song suggester
        randomRaffle =
            (block.timestamp + block.difficulty + randomRaffle) %
            100;
        console.log("Random raffle # generated: %d", randomRaffle);
        
        if (randomRaffle <= 50) {
            console.log("%s won fake Ethereum!", msg.sender);

            // initialize prize with Solidity monetary-keyword "ether"
            uint256 ethPrize = 0.00001 ether;

            // make sure contract balance is higher than the prize
            // first param is requirement, second param is error msg
            require(
                ethPrize <= address(this).balance,
                "Contract has insufficient funds to award prize"
            );

            // send eth
            (bool success, ) = (msg.sender).call{value: ethPrize}("");
            require(success, "Withdrawal from contract failed.");
        }

        // emit = triggers stored parameters from transaction logs
        emit NewSong(msg.sender, block.timestamp, _song);
    }

    function getAllSongs() public view returns (Suggestion[] memory) {
        return suggestions;
    }

    function getTotalSongs() public view returns (uint256) {
        console.log("We have %d total songs", totalSongs);
        return totalSongs;
    }

    // function getAddresses() public view returns (address[] memory){
    //     for(uint256 i=0; i< addresses.length; i++){
    //         console.log("Address of sender: ", addresses[i]);
    //     }
    //     return addresses;
    // }
}

// App.jsx from frontend

// import React, {useEffect, useState} from "react";
// import { ethers } from "ethers";
// //  ethers is a library that helps frontend talk to our smart contract

// import "./App.css";

// import abi from "./utils/PlaylistPortal.json";
// // Contract Application Binary Interface (ABI) is the standard way to interact with contracts in the Ethereum ecosystem, both from outside the blockchain and for contract-to-contract interaction

// const App = () => {

//   // state variable to hold user's wallet
//   const [currentAccount, setCurrentAccount] = useState("");
//   const [allSongs, setAllSongs] = useState([]);
//   const [songInput, setSongInput] = useState(null);

//   const contractAddress = "0xB13178082C3F2f14B12bf74CC39F2DD87ea607C2"
//   const contractABI = abi.abi;

//   const checkWalletConnection = async () => {
//     // check for access to window.ethereum
//     try {
//       const {ethereum} = window;

//       if(!ethereum){
//         console.log("No wallet connected. Log into Metamask!")
//         return;
//       } else {
//         console.log("You have access to the ethereum object", ethereum);
//       }

//       // check for authorization to access user's wallet with eth_accounts method
//       const accounts = await ethereum.request({method: "eth_accounts" });

//       if (accounts.length !== 0){
//         const account = accounts[0];
//         console.log("Account is authorized: ", account);
//         setCurrentAccount(account);
//       } else {
//         console.log("Could not find an authorized account")
//       }
//     } catch (error){
//       console.log(error);
//     }
//   }

//   const addWallet = async () => {
//     try {
//       const {ethereum} = window;

//       if (!ethereum){
//         alert("Make a Metamask account & Login!");
//         return;
//       }

//       //  request access to the user's wallet
//       const accounts = await ethereum.request({ method: "eth_requestAccounts" });

//       console.log("Account Connected", accounts[0]);
//       setCurrentAccount(accounts[0]);
//     }
//     catch (error) {
//       console.log(error);
//     }
//   }

//   const suggestSong = async () => {
//     try {
//       const { ethereum } = window;

//       if (ethereum) {
//         // READ from Contract on Blockchain

//         // Providers allow us to send/recieve data from deployed Ethereum nodes
//         const provider = new ethers.providers.Web3Provider(ethereum);
//         const signer = provider.getSigner();
//         const playlistPortalContract = new ethers.Contract(contractAddress, contractABI, signer);

//         let songCount = await playlistPortalContract.getTotalSongs();
//         console.log("Retrieved total song count: ", songCount.toNumber());

//         // WRITE to Contract on Blockchain (changing Blockchain costs gas fees)
//         const songTxn = await playlistPortalContract.suggestSong(songInput);
//         console.log("Mining...", songTxn.hash);

//         await songTxn.wait();
//         console.log("Mined: ", songTxn.hash);

//         songCount = await playlistPortalContract.getTotalSongs();
//         console.log("Retrieved total song count: ", songCount.toNumber());

//       } else {
//         console.log("No wallet connected / No access to Ethereum object!");
//       }
//     } catch (error){
//       console.log(error);
//     }
//   }

//   const getAllSongs = async () => {
//     try {
//       const { ethereum } = window;

//       if (ethereum) {
//         // connect to Ethereum provider
//         const provider = new ethers.providers.Web3Provider(ethereum);
//         const signer = provider.getSigner();
//         const playlistPortalContract = new ethers.Contract(contractAddress, contractABI, signer);

//         const songs = await playlistPortalContract.getAllSongs();

//         let songsFormatted = [];
//         songs.forEach(song => {
//           songsFormatted.push({
//             address: song.suggester,
//             timestamp: new Date(song.timestamp * 1000),
//             song: song.song
//           });
//         });
//         setAllSongs(songsFormatted);
//       } else {
//         console.log("No wallet connected / No access to Ethereum object!")
//       }
//     } catch (error) {
//       console.log(error);
//     }

//   }

//   useEffect(()=> {
//     checkWalletConnection();
//     getAllSongs();
//   }, [])

//   return (
//     <div className="mainContainer">

//       <div className="dataContainer">
//         <div className="header">
//         🎵 Hey there!
//         </div>
//         <div className="bio">
//         My name is Dominic & this is my first ever project exploring Web3! Simply connect your Ethereum wallet & send me your favorite song. The idea is to have a Blockchain that serves as a playlist with everyone's top jams 🕺🤸🏾
//         </div>
//         <div className="input">
//           <input type="text" placeholder="Enter your favorite song..." onChange={(e => setSongInput(e.target.value)) }required/>
//         </div>
//         <button className="songButton" onClick={suggestSong}>
//           Suggest Song! 👍
//         </button>

//         {/* Only render this button if there is no current account */}
//         {!currentAccount && (
//           <button className="songButton" onClick={addWallet}>Add Wallet! 💸 </button>
//         )}

//         {allSongs.map((song, index) => {
//           return (
//             <div className="submission" key={index} style={{marginTop: "16px", padding: "8px"}}>
//               <div>🔐 Address of Sender: {song.address} </div>
//               <div>🕑 Time Submitted: {song.timestamp.toString()} </div>
//               <div>🎤 Song: {song.song} </div>
//             </div>
//           )
//         })}
//       </div>
//     </div>
//   );
// }

// export default App;
