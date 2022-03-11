import React, {useEffect, useState} from "react";
import { ethers } from "ethers";
//  ethers is a library that helps frontend talk to our smart contract

import "./App.css";

import abi from "./utils/PlaylistPortal.json";
// Contract Application Binary Interface (ABI) is the standard way to interact with contracts in the Ethereum ecosystem, both from outside the blockchain and for contract-to-contract interaction

const App = () => {
  
  // state variable to hold user's wallet
  const [currentAccount, setCurrentAccount] = useState("");
  const [allSongs, setAllSongs] = useState([]);
  const [songInput, setSongInput] = useState(null);
  const [loading, setLoading] = useState(false);
  
  const contractAddress = "0x5512eDC9D568dEF3c38129716489AF219cAab427";
  const contractABI = abi.abi;

  
  const checkWalletConnection = async () => {
    // check for access to window.ethereum
    try {
      const {ethereum} = window;

      if(!ethereum){
        console.log("No wallet connected. Log into Metamask!")
        return;
      } else {
        console.log("You have access to the ethereum object", ethereum);
      }

      // check for authorization to access user's wallet with eth_accounts method
      const accounts = await ethereum.request({method: "eth_accounts" });

      if (accounts.length !== 0){
        const account = accounts[0];
        console.log("Account is authorized: ", account);
        setCurrentAccount(account);
        getAllSongs();
      } else {
        console.log("Could not find an authorized account")
      }
    } catch (error){
      console.log(error);
    }
  }

  
  const addWallet = async () => {
    try {
      const {ethereum} = window;

      if (!ethereum){
        alert("Make a Metamask account & Login!");
        return;
      }

      //  request access to the user's wallet
      const accounts = await ethereum.request({ method: "eth_requestAccounts" });

      console.log("Account Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
    }
    catch (error) {
      console.log(error);
    }
  }

  
  const suggestSong = async () => {
    try {
      const { ethereum } = window;

      if (ethereum) {
        // READ from Contract on Blockchain
        
        // Providers allow us to send/recieve data from deployed Ethereum nodes
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const playlistPortalContract = new ethers.Contract(contractAddress, contractABI, signer);

        let songCount = await playlistPortalContract.getTotalSongs();
        console.log("Retrieved total song count: ", songCount.toNumber());

        // WRITE to Contract on Blockchain (changing Blockchain costs gas fees)
        const songTxn = await playlistPortalContract.suggestSong(songInput, { gasLimit: 1000000 });
        setLoading(true);
        console.log("Mining...", songTxn.hash);

        await songTxn.wait();
        setLoading(false);
        console.log("Mined: ", songTxn.hash);

        songCount = await playlistPortalContract.getTotalSongs();
        console.log("Retrieved total song count: ", songCount.toNumber());
        
      } else {
        console.log("No wallet connected / No access to Ethereum object!");
      }
    } catch (error){
      console.log(error);
    }
  }

  const getAllSongs = async () => {
    try {
      const { ethereum } = window;

      if (ethereum) {
        // connect to Ethereum provider
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const playlistPortalContract = new ethers.Contract(contractAddress, contractABI, signer);

        const songs = await playlistPortalContract.getAllSongs();
        
        // only pick out song, time, and sender for UI
        let songsFormatted = [];
        songs.forEach(song => {
          songsFormatted.push({
            address: song.suggester,
            timestamp: new Date(song.timestamp * 1000),
            song: song.song
          });
        });
        setAllSongs(songsFormatted);
      } else {
        console.log("No wallet connected / No access to Ethereum object!")
      }
    } catch (error) {
      console.log(error);
    }

  }

  
  useEffect(()=> {
    checkWalletConnection();
  }, [])


if(loading){
  return(
    <p>⛏️ One moment please! Your transaction to the Blockchain is being mined... 💫</p>
  )
}
  
  return (
    <div className="mainContainer">

      <div className="dataContainer">
        <div className="header">
        🎶 Hey there! 
        </div>
        <div className="bio">
        My name is Dominic & this is my first ever project exploring Web3! Simply connect your Ethereum wallet & send me your favorite song. The idea is to have a Blockchain that serves as a playlist with everyone's top jams 🕺🤸🏾
        </div>
        <div className="input">
          <input type="text" placeholder="Enter your favorite song..." onChange={(e => setSongInput(e.target.value)) }required/>
        </div>
        <button className="songButton" onClick={suggestSong}>
          Suggest Song! 👍
        </button>

        {/* Only render this button if there is no current account */}
        {!currentAccount && (
          <button className="songButton" onClick={addWallet}>Add Wallet! 💸 </button>
        )}

        {currentAccount && (
        <div className="playlist">
          🎧 Playlist Portal: 
        </div>
      )}

        {allSongs.map((song, index) => {
          return (  
            <div className="submission" key={index} style={{marginTop: "16px", padding: "8px"}}>
              <div>🔐 Address of Sender: {song.address} </div>
              <div>🕑 Time Submitted: {song.timestamp.toString()} </div>
              <div>🎤 Song: {song.song} </div>
            </div>
          )
        })}
      </div>
    </div>
  );
}

export default App;