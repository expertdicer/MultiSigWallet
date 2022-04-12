// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.0;
import "./Factory.sol";
import "./MultiSigWallet.sol";
import "./Verifier.sol";


/// @title Multisignature wallet factory - Allows creation of multisig wallet.
/// @author Stefan George - <stefan.george@consensys.net>
contract MultiSigWalletFactory is Factory, Verifier{

    event addUser(address[] address1, address address2);
    mapping (address => MultiSigWallet) public ownerToMultiSigWallet;
    mapping (address => bool) public isAddressConnection;
    mapping (address => bool) public updater;

    modifier onlyUpdater() {
        require(updater[msg.sender] == true, "only updater");
        _;
    }

    constructor() public {   
        updater[msg.sender] = true;
    }

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
        require(verifyIntegrity(chainID,addresses,signature), "Bullshitery!");

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
        emit addUser(addresses, address(wallet));
    }

    function addAddress(
        bytes8[] calldata chainID,              // array chain ID
        address[] calldata addresses,                  // array public key
        bytes[] calldata signature,             // array signature
        uint timestamp
    ) public returns(address){
        // require(timestamp + 1000 <= block.timestamp, "Too late!");
        require(verifyIntegrity(chainID,addresses,signature), "Bullshitery!");
        require(addresses.length == 2, "Only two addresses");
        address x = addresses[0];
        address y = addresses[1];

        require(isAddressConnection[x] || isAddressConnection[y] , "Need one address connected!");
        if (isAddressConnection[x] && isAddressConnection[y])
            require(ownerToMultiSigWallet[x] != ownerToMultiSigWallet[y], 
            "Both address connected to the same Identity!");
        
        if (!isAddressConnection[x]) {
            MultiSigWallet(ownerToMultiSigWallet[y]).addAddress(x);
            ownerToMultiSigWallet[x] = ownerToMultiSigWallet[y];
            isAddressConnection[x] = true;
            return address(ownerToMultiSigWallet[y]);
            emit addUser(addresses, address(ownerToMultiSigWallet[y]));
        }

        if (!isAddressConnection[y]) {
            MultiSigWallet(ownerToMultiSigWallet[x]).addAddress(y);
            ownerToMultiSigWallet[y] = ownerToMultiSigWallet[x];
            isAddressConnection[y] = true;
            return address(ownerToMultiSigWallet[x]);
            emit addUser(addresses, address(ownerToMultiSigWallet[x]));
        }

        MultiSigWallet multiSigX = MultiSigWallet(ownerToMultiSigWallet[x]);
        MultiSigWallet multiSigY = MultiSigWallet(ownerToMultiSigWallet[y]);
        
        // require(multiSigX.isMultiSigWalletEnabled() == true);
        // require(multiSigY.isMultiSigWalletEnabled() == true);

        address[] memory addressX = multiSigX.getOwners();
        address[] memory addressY = multiSigY.getOwners();

        if (addressX.length < addressY.length) {
            for (uint i = 0; i < addressX.length; i++) {
                multiSigY.addAddress(addressX[i]);
                ownerToMultiSigWallet[ addressX[i] ] = multiSigY;
            }
            multiSigX.changeNewOwner(address(multiSigY));
            return address(ownerToMultiSigWallet[y]);
            emit addUser(addresses, address(multiSigY));
        }
    
        else {
            for (uint i = 0; i < addressY.length; i++) {
                multiSigX.addAddress(addressY[i]);
                ownerToMultiSigWallet[ addressY[i] ] = multiSigX;
            }
            multiSigY.changeNewOwner(address(multiSigX));
            return address(ownerToMultiSigWallet[x]);
            emit addUser(addresses, address(multiSigX));
        }
        

    }

    function deleteAddress(
        address removeX,
        bytes8[] calldata chainID,              // array chain ID
        address[] calldata addresses, 
        bytes[] calldata signature,             // array signature
        uint timestamp
    ) public {

        require(isAddressConnection[removeX], "Address not connected");
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

    function addNewUpdater(address _updater) public onlyUpdater {
        updater[_updater] = true;
    }

    function removeUpdater(address _updater) public onlyUpdater {
        updater[_updater] = false;
    }

    function updaterConnectAddress(address addressA, address[] calldata addressesB) public onlyUpdater returns (address) {
        require(isAddressConnection[addressA], "address A must be connected!");
        MultiSigWallet multiSigA = MultiSigWallet(ownerToMultiSigWallet[addressA]);

        for (uint i = 0; i < addressesB.length; i++) {
            address addressB = addressesB[i];

            if (!isAddressConnection[addressB]) {
                multiSigA.addAddress(addressB);
                isAddressConnection[addressB] = true;
                ownerToMultiSigWallet[addressB] = multiSigA;
                continue;
            }

            else {
                MultiSigWallet multiSigB = MultiSigWallet(ownerToMultiSigWallet[addressB]);
                if (multiSigA != multiSigB) {
                    address[] memory ownerOfWalletB = multiSigB.getOwners();
                    for (uint i = 0; i < ownerOfWalletB.length; i++) {
                        multiSigA.addAddress(ownerOfWalletB[i]);
                        ownerToMultiSigWallet[ ownerOfWalletB[i] ] = multiSigA;
                    }
                    multiSigB.changeNewOwner( address(multiSigA) );
                }
            }
        }

        return address(multiSigA);
    }
      

}
