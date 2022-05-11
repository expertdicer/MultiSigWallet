// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.0;
import "./Factory.sol";
import "./MultiSigWallet.sol";
import "./Verifier.sol";


/// @title Multisignature wallet factory - Allows creation of multisig wallet.
/// @author Stefan George - <stefan.george@consensys.net>
contract MultiSigWalletFactory is Factory, Verifier{

    event ConnectUser(address[] addresses, bytes[] signature);
    event DeleteUser(address userRemove, address[] addresses, bytes[] signature);
    mapping (address => MultiSigWallet) public ownerToMultiSigWallet;
    mapping (address => bool) public isAddressConnection;

    function create(
        address[] calldata _owners, 
        uint _required, 
        bytes[] calldata signature,             // array signature
        uint timestamp
        ) public
        returns (address wallet)
    {   
        // require(timestamp + 1000 <= block.timestamp, "Too late!");
        require(verifyIntegrity(_owners,signature), "Bullshitery!");

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

        emit ConnectUser(_owners, signature);
    }

    function addAddress(
        address[] calldata addresses,                  // array public key
        bytes[] calldata signature,             // array signature
        uint timestamp
    ) public returns(address){
        // require(timestamp + 1000 <= block.timestamp, "Too late!");
        require(verifyIntegrity(addresses,signature), "Bullshitery!");

        bool checkIsWallet = false;
        for (uint i = 0; i < addresses.length; i++) {
            if (isAddressConnection[ addresses[i] ] == true) {
                checkIsWallet = true;
                break;
            }
        }

        // don't have multiSigWallet
        // create new
        if (checkIsWallet == false) {
            uint required = (addresses.length + 1) / 2;
            MultiSigWallet wallet = new MultiSigWallet(addresses, required);
            register( address(wallet) );

            for (uint i = 0; i < addresses.length; i++) {
                ownerToMultiSigWallet[ addresses[i] ] = wallet;
                isAddressConnection[ addresses[i] ] = true;
            }

            emit ConnectUser(addresses, signature);
            return address(wallet);
        }

        // have wallet
        else {
            address[] memory addressesTmp;
            address[] memory rootOwner;
            MultiSigWallet rootWallet;
            MultiSigWallet walletTmp;

            for (uint i = 0; i < addresses.length; i++) {
                if (isAddressConnection[ addresses[i] ] == true) {
                    walletTmp = MultiSigWallet (ownerToMultiSigWallet[ addresses[i] ]);
                    addressesTmp = walletTmp.getOwners();
                    if (addressesTmp.length > rootOwner.length) {
                        rootWallet = walletTmp;
                        rootOwner = addressesTmp;
                    }
                }
            }

            for (uint i = 0; i < addresses.length; i++) {
                if (isAddressConnection[ addresses[i] ] == true) {
                    walletTmp = MultiSigWallet (ownerToMultiSigWallet[ addresses[i] ]);

                    if (walletTmp == rootWallet)
                        continue;

                    addressesTmp = walletTmp.getOwners();

                    for (uint j = 0; j < addressesTmp.length; j++) {
                        rootWallet.addAddress( addressesTmp[j] );
                        ownerToMultiSigWallet[ addressesTmp[j] ] = rootWallet;
                    }
                    walletTmp.changeNewOwner( address(rootWallet) );

                }

                else {
                    rootWallet.addAddress( addresses[i] );
                    ownerToMultiSigWallet[ addresses[i] ] = rootWallet;
                    isAddressConnection[ addresses[i] ] = true;
                }
            }
            
            emit ConnectUser(addresses, signature);
            return address(rootWallet);
        }
        

    }

    function updateAddress( 
        address[][] calldata addresses,                  // array public key
        bytes[][] calldata signature,             // array signature
        uint timestamp        
     ) public {
        require(addresses.length == signature.length, "Invalid data");
        for (uint i = 0; i < addresses.length; i++ ) {
                addAddress(addresses[i], signature[i], timestamp);
        }    
    }

    function deleteAddress(
        address removeX,
        address[] calldata addresses, 
        bytes[] calldata signature,             // array signature
        uint timestamp
    ) internal {

        require(isAddressConnection[removeX], "Address not connected");
        MultiSigWallet ownerX = MultiSigWallet(ownerToMultiSigWallet[removeX]);
        int numberAccept = 0;
        bytes32 messageHash = getMessageHash(addresses);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        for(uint i = 0; i < addresses.length ;i++) {

            if (isAddressConnection[ addresses[i] ] != true || MultiSigWallet(ownerToMultiSigWallet[addresses[i]]) != ownerX)
                continue;

            (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature[i]);
            if (addresses[i] == ecrecover(ethSignedMessageHash, v, r, s) )
                numberAccept++;
        }

        if (2 * numberAccept >= int(ownerX.getOwners().length) ) {
            ownerX.removeAddess(removeX);
            isAddressConnection[removeX] = false;
            emit DeleteUser(removeX, addresses, signature);
        }
        
    }

    function getAllAddress(
        address addressX
    ) public view returns (address[] memory) {
        if (isAddressConnection[addressX] == true) {
            MultiSigWallet ownerX = MultiSigWallet(ownerToMultiSigWallet[addressX]);
            return ownerX.getOwners();
        } else {
            address[] memory res = new address[](1);
            res[0] = addressX;
            return res;
        }

    }

    function checkSameUser(
        address[] calldata addresses
    ) public view returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (isAddressConnection[addresses[i] ] == false 
                || (ownerToMultiSigWallet[addresses[0]] != ownerToMultiSigWallet[ addresses[i] ]))
                return false;
        }

        return true;
    }

    function verifyIntegrity(
        address[] calldata addresses,          // array public key
        bytes[] calldata signature            // array signature
    ) public returns (bool)
    {
        
        bytes32 messageHash = getMessageHash(addresses);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        for (uint i = 0; i < addresses.length; i++) {
            (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature[i]);
            require(addresses[i] == ecrecover(ethSignedMessageHash, v, r, s), "Invalid signature");
        }

        return true;

    }

}
