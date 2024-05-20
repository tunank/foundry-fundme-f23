// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract HelperConfig is Script{
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e18;
    
    struct NetworkConfig{
        address PriceFeed; //Eth/USD price feed address
    }

    constructor(){
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaConfig();
        } 
        else if (block.chainid == 1){
            activeNetworkConfig = getEthConfig();
        }
        else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            PriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
        return sepoliaConfig;
    }

    function getEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            PriceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
        return ethConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.PriceFeed != address(0)){
            return activeNetworkConfig;
        }


        vm.startBroadcast();
        MockV3Aggregator mockpriceFeed = new MockV3Aggregator(
            DECIMAL, 
            INITIAL_PRICE
            );
        vm.stopBroadcast();

        NetworkConfig memory anvilEthConfig = NetworkConfig({
            PriceFeed: address(mockpriceFeed)
            });
        
        return anvilEthConfig;
    }
}