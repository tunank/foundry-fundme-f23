// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("user");
    uint256 constant MONEYSEND = 0.1 ether;
    
    FundMe fundme;

    function setUp() external{
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, MONEYSEND);
    }
    
    function testAddFundersToArray() public funded{
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    function testMinimumDollarIsFive() public view{
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testCheckIfSenderIsOwner() public view {
        assertEq(fundme.getOwner(), msg.sender);
        }

    function testVersion() public view{
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFunFailWithoutEnoughFunds() public{
        vm.expectRevert();
        fundme.fund();
    }

    function testFundSuccess() public{
        vm.prank(USER); // the next tx will be sent by user

        fundme.fund{value: MONEYSEND}();
        uint256 amountfunded = fundme.s_addressToAmountFunded(USER);
        assertEq(amountfunded, MONEYSEND);
    }

    function testFunder() public funded{
        address addresssender = fundme.s_funders(0);
        assertEq(addresssender, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }
    modifier funded(){
        vm.prank(USER);
        fundme.fund{value: MONEYSEND}();
        _;
    }

    function testWithdrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;
        //Act
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;

        assertEq(endingFundmeBalance, 0);
        assertEq(startingOwnerBalance + startingFundmeBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded{
        uint160 funders = 10;
        uint160 starting = 1;

        for(uint160 i = starting; i <= funders; i++){
            hoax(address(i), MONEYSEND);
            fundme.fund{value: MONEYSEND}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        assert(address(fundme).balance == 0);
        assert(startingOwnerBalance + startingFundmeBalance == fundme.getOwner().balance);
    }
}