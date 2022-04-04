// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.0;
import "./interfaces/IERC20.sol";
import "./Verifier.sol";
import "./libraries/SafeMath.sol";
/// @title Record all the merging requests
/// @author Lặc Số Một - <expertdicer@gmail.com>
contract Recorder is Verifier{

    using SafeMath for uint256;

    event mergeRequestCreated(address indexed address1, address indexed address2,uint indexed nonce);
    event mergeRequestCanceled(uint indexed _nonce);
    event changeModerator(address indexed oldModerator, address indexed newModerator);
    event changeFee(uint indexed newFee);
    event withdrawal(address indexed token, address indexed to, uint indexed amount);
    event deposit(address indexed from, uint indexed amount);

    mapping(address => address) public mergeRequest;
    mapping(uint => uint) public deposited;

    address public trava;
    address public moderator;
    uint public nonce;
    uint public fee;
    

    modifier onlyModerator() {
        require(msg.sender == moderator);
        _;
    }

    constructor(address _trava, uint _fee) public {
        trava = _trava;
        moderator = msg.sender;
        fee = _fee;
    }

    function makeMergeRequest(
        address[] calldata addresses,
        bytes[] calldata signature,
        uint timestamp
    ) public {
        require(verifyIntegrity(addresses,signature,nonce), "Bullshitery!");
        IERC20(trava).approve(address(this),fee);
        IERC20(trava).transferFrom(msg.sender, address(this),fee);
        mergeRequest[addresses[0]] = addresses[1];
        deposited[nonce] = fee;
        uint at = nonce;
        nonce.add(1);
        emit deposit(msg.sender,fee);
        emit mergeRequestCreated(addresses[0], addresses[1],at);
    }

    function cancelMergeRequest(
        address[] calldata addresses,
        bytes[] calldata signature,
        uint _nonce,
        uint timestamp
    ) public {
        require(verifyIntegrity(addresses,signature,_nonce), "Bullshitery!");
        IERC20(trava).transfer(msg.sender, deposited[_nonce]);
        deposited[_nonce] = 0;
        emit mergeRequestCanceled(_nonce);
    }
    
    function setFee(uint _fee) public onlyModerator {
        fee = _fee;
        emit changeFee(fee);
    }

    function setModerator(address _moderator) public onlyModerator {
        moderator = _moderator;
        emit changeModerator(msg.sender, moderator);
    }

    function verifyIntegrity(
        address[] calldata addresses,          // array public key
        bytes[] calldata signature,
        uint _nonce         // array signature
    ) public returns (bool)
    {
        bytes32 messageHash = getMessageHash(addresses, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        for (uint i = 0; i < signature.length; i++) {
            (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature[i]);
            require(addresses[i] == ecrecover(ethSignedMessageHash, v, r, s), "Invalid signature");
        }
        return true;
    }

    function withdraw(address token, uint amount) public onlyModerator {
        IERC20(token).transfer(msg.sender,amount);
        emit withdrawal(token,msg.sender,amount);
    }
}
