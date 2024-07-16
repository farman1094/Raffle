// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

contract Interaction is Test {

}

/* 
 Type of test
 1) Unit test (basic Test)
 2) Integration Test(script test)
 3) Forked test (pseudo)
 4) staging test (testing on virtual enviorment) mainnet or testnet

 fuzzing
 stateful fuzing
 stateless fuzing
 formal verification

 deploy:
forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $SEPOLIA_RPC_URL --account farman --broadcast --verify --etherscan-api-key $ESCAN_API_KEY -vvvv
forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $ANVIL_RPC_URL --private-key $ANVIL_PKEY --broadcast -vvvv


 */
