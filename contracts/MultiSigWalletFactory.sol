// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.0;
import "./Factory.sol";
import "./MultiSigWallet.sol";
import "./Verifier.sol";


/// @title Multisignature wallet factory - Allows creation of multisig wallet.
/// @author Stefan George - <stefan.george@consensys.net>
contract MultiSigWalletFactory is Factory, Verifier{

    event addUser(address[] address1, address address2);
    event connectUser(address[] addresses, uint _nonce, bytes[] signature);
    event deleteUser(address userRemove, address[] addresses, bytes[] signature);
    mapping (address => MultiSigWallet) public ownerToMultiSigWallet;
    mapping (address => bool) public isAddressConnection;
    mapping (address => bool) public updater;
    mapping (MultiSigWallet => uint) public nonce;

    function create(
        address[] calldata _owners, 
        uint _required, 
        uint _nonce,
        bytes[] calldata signature,             // array signature
        uint timestamp
        ) public
        returns (address wallet)
    {   
        // require(timestamp + 1000 <= block.timestamp, "Too late!");
        require(verifyIntegrity(_owners, _nonce, signature), "Bullshitery!");

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

        nonce[wallet] = 0;

        emit addUser(_owners, address(wallet));
        emit connectUser(_owners, nonce[wallet], signature);
    }

    function addAddress(
        address[] calldata addresses,                  // array public key
        uint _nonce,
        bytes[] calldata signature,             // array signature
        uint timestamp
    ) public returns(address){

        require(verifyIntegrity(addresses, _nonce, signature), "Bullshitery!");

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
            nonce[wallet] = 0;
            return address(wallet);
            emit addUser(addresses, address(wallet));
            emit connectUser(addresses, nonce[wallet], signature);
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

            require( nonce[rootWallet] + 1 == _nonce, "Nonce must be inc 1" );

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
            nonce[rootWallet] = nonce[rootWallet] + 1;

            return address(rootWallet);
            emit addUser(addresses, address(rootWallet));
            emit connectUser(addresses, nonce[rootWallet], signature);
        }
        
    }

   
    function updateAddress( 
        address[][] calldata addresses,                  // array public key
        uint[] calldata _nonce,
        bytes[][] calldata signature,             // array signature
        uint timestamp        
     ) public {
        require(_nonce.length >= 1 && _nonce.length == addresses.length && _nonce.length == signature.length, "Cannot update address");
        
        uint nonceMin = _nonce[0];
        uint nonceMax = _nonce[0];
        for (uint i = 1; i < _nonce.length; i++ ) {
            if (nonceMin > _nonce[i]) 
                nonceMin = _nonce[i];

            if (nonceMax < _nonce[i])
                nonceMax = _nonce[i];
        }

        for (uint _nonceId = nonceMin; _nonceId <= nonceMax; _nonceId++) {
            for (uint i = 0; i < _nonce.length; i++ ) {
                if (_nonce[i] == _nonceId) {
                    addAddress(addresses[i], _nonce[i], signature[i], timestamp);
                }
            }
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


    mapping (MultiSigWallet => uint) addressSig;
    function verifyIntegrity(
        address[] calldata addresses,          // array public key
        uint _nonce,
        bytes[] calldata signature            // array signature
    ) public returns (bool)
    {
        
        uint addressNotInWallet = 0;
        MultiSigWallet wallet;

        for (uint i = 0; i < addresses.length; i++) {
            if (isAddressConnection[ addresses[i] ] != true ) {
                addressNotInWallet = addressNotInWallet + 1;
            } else {
                addressSig[ MultiSigWallet( ownerToMultiSigWallet[ addresses[i] ] ) ] = 0;

            }
        }

        bytes32 messageHash = getMessageHash(addresses, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        uint addressAddConnection = 0;

        for (uint i = 0; i < addresses.length; i++) {
            address tmp = addresses[i];
            (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature[i]);
            
            if(tmp == ecrecover(ethSignedMessageHash, v, r, s)) {
                if (isAddressConnection[ tmp ] == true) {
                    wallet = MultiSigWallet( ownerToMultiSigWallet[ tmp ] );
                    addressSig[wallet] = addressSig[wallet] + 1;
                } else {
                    addressAddConnection = addressAddConnection + 1;
                }
            }
        }

        bool isValidSignature = true;
        if (addressAddConnection != addressNotInWallet) {
            isValidSignature = false;
        }

        for (uint i = 0; i < addresses.length; i++) {
            address tmp = addresses[i];
            if (isAddressConnection[tmp] == true) {
                wallet = MultiSigWallet( ownerToMultiSigWallet[tmp] );
                if ( addressSig[wallet] < ((wallet.getOwners()).length + 1)/2 ) {
                    isValidSignature = false;
                    break;
                }
            }
        }

        require(isValidSignature == true, "Invalid signature");

        return true;
    }




}
