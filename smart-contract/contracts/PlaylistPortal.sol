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
