// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DTPFactory} from "../src/DTPFactory.sol";
import {DTPToken} from "../src/DTPToken.sol";
import {MFTRegistry} from "../src/MFTRegistry.sol";
import {IAppRegistry} from "../src/interfaces/IAppRegistry.sol";

contract DTPDeployScript is Script {
    address internal _APP_REGISTRY;
    address internal _BIT_DSM_REGISTRY;
    address internal _BITCOIN_POD_MANAGER;
    
    DTPFactory public dtpFactory;
    DTPToken public dtpToken;
    MFTRegistry public mftRegistry;

    function setUp() public {
        _APP_REGISTRY = address(0x91677dD787cd9056c5805cBb74e271Fd83d88E61);
        _BIT_DSM_REGISTRY = address(0xba3C98E3D60871f92d1c8890a13207fE46534641);
        _BITCOIN_POD_MANAGER = address(0x96EAE70bC21925DdE05602c87c4483579205B1F6);
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer:", deployer);
        vm.startBroadcast(deployerPrivateKey);
        // delopy mtf registry
        mftRegistry = new MFTRegistry();
        mftRegistry.initialize(_BIT_DSM_REGISTRY);
        // deploy dtp factory
        dtpFactory = new DTPFactory();
        dtpFactory.initialize(address(mftRegistry), _APP_REGISTRY, _BITCOIN_POD_MANAGER);

        // register the dtp factory to the app registry
       // create salt and expiry for Digest Hash
        bytes32 salt = bytes32(uint256(1));
        uint256 expiry = block.timestamp + 1 days;
       
        // Try to read the digest hash with try/catch
        try
            IAppRegistry(_APP_REGISTRY).calculateAppRegistrationDigestHash(
                address(dtpFactory),
                _APP_REGISTRY,
                salt,
                expiry
            )
            returns (bytes32 digestHash) {
            console.log("Digest Hash:", vm.toString(digestHash));

            (uint8 v, bytes32 r, bytes32 s) = vm.sign(
                deployerPrivateKey,
                digestHash
            );
            bytes memory signature = abi.encodePacked(r, s, v);

            // lets verify the signature locally
            try dtpFactory.isValidSignature(digestHash, signature) returns (
                bytes4 magicValue
            ) {
                console.log(
                    "\nSignature verification result:",
                    vm.toString(magicValue)
                );
                require(
                    magicValue == 0x1626ba7e,
                    "Signature verification failed locally"
                );
            } catch Error(string memory reason) {
                console.log("\nLocal signature verification failed:", reason);
                revert("Local signature verification failed");
            }
            // if verification passed, register the app
            IAppRegistry(_APP_REGISTRY).registerApp(
                address(dtpFactory),
                signature,
                salt,
                expiry
            );
            console.log("App registered successfully");
        }
         catch Error(string memory reason) {
            console.log("Failed to calculate digest:", reason);
        } catch {
            console.log("Failed to calculate digest (no reason)");
        }
        // print the addresses of the deployed contracts
        console.log("DTPFactory:", address(dtpFactory));
        console.log("MFTRegistry:", address(mftRegistry));
        dtpFactory.updateAppMetadataURI(
            "https://raw.githubusercontent.com/usmanshahid86/test_avs_data/refs/heads/motif-app-data/avs_test.json"        );
        vm.stopBroadcast();
    }
}
