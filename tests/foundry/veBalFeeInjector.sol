//SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "forge-std/Test.sol";
import "../../contracts/veBalFeeInjector.sol";


contract veBalFeeInjectorTest is Test {

    // state variables
    veBalFeeInjector public injector;

    address feeDistributor = 0xD3cf852898b21fc233251427c2DC93d3d604F3BB;
    address BAL = address(0xba100000625a3754423978a60c9317c58a424e3D);
    address WETH =address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);



    // setup
    function setUp() public {
        IERC20[] memory managedTokens = new IERC20[](2);
        managedTokens[0] = IERC20(BAL);
        managedTokens[1] = IERC20(WETH);

        injector = new veBalFeeInjector(address(3), feeDistributor, managedTokens);
    }

    // tests
    function testIsPausable() public {
        assertFalse(injector.paused(), "Injector should not be paused");
        injector.pause();
        assertTrue(injector.paused(), "Injector should be paused");
        vm.expectRevert("Pausable: paused");
        injector.payFees();
    }
}