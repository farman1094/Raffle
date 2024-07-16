//SPDX-License-Identifier: MIT

// Contract elements should be laid out in the following order:

// 1. Pragma statements
// 2. Import statements
// 3. Events
// 4. Errors
// 5. Interfaces
// 6. Libraries
// 7. Contracts

// Inside each contract, library or interface, use the following order:

// 1. Type declarations
// 2. State variables
// 3. Events
// 4. Errors
// 5. Modifiers
// 6. Functions

pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title  Raffle
 * @author 0xFarman
 * @notice A simple contact of Raffle
 * @dev Implements Chainlink VRFv2.5
 */
contract Raffle is VRFConsumerBaseV2Plus {
    //error
    error Raffle__SendMoreToEnterRaffle();
    error Raffle__transferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpKeepNotNeeded(uint256 balance, uint256 players, uint256 raffleState);

    //type declaration
    enum RaffleState {
        OPEN, //1
        CALCULATING //2

    }

    //State Variables
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint32 private immutable i_callbackGasLimit;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint256 private immutable i_subscriptionId;

    RaffleState private s_raffleState;
    uint256 private s_lastTimeStamp;

    address private s_recentWinner;
    address payable[] private s_players;

    //events
    event RaffleEntered(address indexed player);
    event winnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

    // /_vrfCoordinator
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN; //RaffleState(0);
            // s_vrfCoordinator.requestRandomWords();
    }

    function enterRaffle() external payable {
        //   require(msg.value >= i_entranceFee, Raffle__NotEnoughtEthSent(msg.value) );
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // automatically called
    /**
     * @dev - this is the function that chainlink nodes will monitor
     * If it is the time to pick the winner
     * The following should be true in order for upKeepNeeded to be true
     *  1. The time has been passed
     *  2. The lottery is OPEN
     *  3. The contract has ETH (players)
     *  4. Implicitly, your contract has LINK
     * @param - ignored
     * @return upKeepNeeded //true if it is time to restart the lottery
     * @return - ignored
     */
    function checkUpKeep(bytes memory /* checkData */ )
        public
        view
        returns (bool upKeepNeeded, bytes memory /* performData */ )
    {
        bool timeHasPassed = ((block.timestamp - s_lastTimeStamp) >= i_interval);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upKeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;
        return (upKeepNeeded, "");
    }

    function performUpKeep(bytes calldata /* checkData */ ) external {
        // check to see if enought time has passed
        (bool upKeepNeeded,) = checkUpKeep("");

        if (!upKeepNeeded) {
            revert Raffle__UpKeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }

        // Effects (internal changes )
        s_raffleState = RaffleState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                //set nativePayment to true to pay for VRF requests with sepolia ETH instead of link
                VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
            )
        });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(uint256, /* requestId */ uint256[] calldata randomWords) internal override {
        //checks if any (conditonal or conditons)
        // effect changign the internal state of contract
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN; //resetting
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit winnerPicked(s_recentWinner);

        //paying a winner // Interaction
        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__transferFailed();
        }
    }

    //Getter Functions
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayers(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }
    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }
    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }
}
