// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.0;
import "./Factory.sol";
import "./MultiSigWallet.sol";
import "./Verifier.sol";


/// @title Multisignature wallet factory - Allows creation of multisig wallet.
/// @author Stefan George - <stefan.george@consensys.net>
contract MultiSigWalletFactory is Factory, Verifier{
    mapping (address => MultiSigWallet) ownerToMultiSigWallet;
    mapping (address => bool) isAddressConnection;

    function create(
        address[] calldata _owners, 
        uint _required, 
        bytes8[] calldata chainID,              // array chain ID
        address[] calldata addresses,                  // array public key
        bytes[] calldata signature,             // array signature
        uint timestamp
        ) public
        returns (address wallet)
    {   
        // require(timestamp + 1000 <= block.timestamp, "Too late!");
        require(verifyIntegrity(chainID,addresses,signature), "Bullshitery");

        for (uint i = 0; i < _owners.length; i++) {
            require(isAddressConnection[_owners[i]] == false, "Owner is used");
        }

        MultiSigWallet wallet = new MultiSigWallet(_owners, _required);            // deploy 1 contract mulltisigWallet mới
        register(address(wallet));                                           // Lưu lại: tại địa chỉ "wallet" thì đã có instant
                                                                    // msg.sender có 1 instant là wallet
        for (uint i = 0; i < _owners.length; i++) {
            ownerToMultiSigWallet[ _owners[i] ] = wallet;
            isAddressConnection[_owners[i]] = true;
        }
    }

    function addAddress(
        uint _required, 
        bytes8[] calldata chainID,              // array chain ID
        address[] calldata addresses,                  // array public key
        bytes[] calldata signature,             // array signature
        uint timestamp
    ) public {
        // require(timestamp + 1000 <= block.timestamp, "Too late!");
        require(verifyIntegrity(chainID,addresses,signature), "Bullshitery");
        require(addresses.length == 2, "Only two addresses");
        address x = addresses[0];
        address y = addresses[1];

        if (isAddressConnection[x] == true 
            && isAddressConnection[y] == true
            && ownerToMultiSigWallet[x] == ownerToMultiSigWallet[y])
            return;

        require(isAddressConnection[x] == true || isAddressConnection[y] == true);
        
        if (isAddressConnection[x] == false) {
            MultiSigWallet ownerY = MultiSigWallet(ownerToMultiSigWallet[y]);
            ownerY.addAddress(x);
            ownerToMultiSigWallet[x] = ownerY;
            isAddressConnection[x] = true;
            return;
        }

        if (isAddressConnection[y] == false) {
            MultiSigWallet ownerX = MultiSigWallet(ownerToMultiSigWallet[x]);
            ownerX.addAddress(y);
            ownerToMultiSigWallet[y] = ownerX;
            isAddressConnection[y] = true;
            return;
        }

        MultiSigWallet ownerX = MultiSigWallet(ownerToMultiSigWallet[x]);
        MultiSigWallet ownerY = MultiSigWallet(ownerToMultiSigWallet[y]);
        
        require(ownerX.isMultiSigWalletEnabled() == true);
        require(ownerY.isMultiSigWalletEnabled() == true);

        address[] memory addressX = ownerX.getOwners();
        address[] memory addressY = ownerY.getOwners();

        if (addressX.length < addressY.length) {
            for (uint i = 0; i < addressX.length; i++) {
                ownerY.addAddress(addressX[i]);
                //ownerX.removeAddess(addressX[i]);

                ownerToMultiSigWallet[ addressX[i] ] = ownerY;
                isAddressConnection[ addressX[i] ] = true;
            }
            ownerX.disableMultiSigWallet();
        }
    
        else {
            for (uint i = 0; i < addressY.length; i++) {
                ownerX.addAddress(addressY[i]);
                //ownerY.removeAddess(addressY[i]);

                ownerToMultiSigWallet[ addressY[i] ] = ownerX;
                isAddressConnection[ addressY[i] ] = true;
            }
            ownerY.disableMultiSigWallet();
        }

    }

    function deleteAddress(
        address removeX,
        bytes8[] calldata chainID,              // array chain ID
        address[] calldata addresses, 
        bytes[] calldata signature,             // array signature
        uint timestamp
    ) public {

        if (isAddressConnection[removeX] == true) {
            MultiSigWallet ownerX = MultiSigWallet(ownerToMultiSigWallet[removeX]);
            int numberAccept = 0;
            bytes32 messageHash = getMessageHash(chainID, addresses);
            bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
            for(uint i = 0; i < chainID.length ;i++) {

                if (isAddressConnection[ addresses[i] ] != true || MultiSigWallet(ownerToMultiSigWallet[addresses[i]]) != ownerX)
                    continue;

                (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature[i]);
                if (addresses[i] == ecrecover(ethSignedMessageHash, v, r, s) )
                    numberAccept++;
            }

            if (2 * numberAccept >= int(ownerX.getOwners().length) ) {
                ownerX.removeAddess(removeX);
                isAddressConnection[removeX] = false;
            }
        }

    }

    function getAllAddress(
        address addessX
    ) public view returns (address[] memory) {
        require(isAddressConnection[addessX] == true);
        MultiSigWallet ownerX = MultiSigWallet(ownerToMultiSigWallet[addessX]);
        require(ownerX.isActive() == true);
        return ownerX.getOwners();
    }

    function checkSameUser(
        address[] calldata addresses
    ) public view returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (isAddressConnection[ addresses[i] ] == false 
                || ownerToMultiSigWallet[ addresses[0] ] != ownerToMultiSigWallet[ addresses[i] ])
                return false;
        }

        return true;
    }

    function verifyIntegrity(
        bytes8[] calldata chainID,              // array chain ID
        address[] calldata addresses,          // array public key
        bytes[] calldata signature            // array signature
    ) public returns (bool)
    {

        
        // for(uint i = 0; i < chainID.length ;i++)
        // {
        //   bytes32 messageHash = getMessageHash(chainID[i], addresses[i]);
        //   bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        //   (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature[i]);
        //   require(addresses[i] == ecrecover(ethSignedMessageHash, v, r, s), "Invalid signature");
        // }   
        
        bytes32 messageHash = getMessageHash(chainID, addresses);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        for (uint i = 0; i < chainID.length; i++) {
            (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature[i]);
            require(addresses[i] == ecrecover(ethSignedMessageHash, v, r, s), "Invalid signature");
        }

        return true;

    }
      

}
