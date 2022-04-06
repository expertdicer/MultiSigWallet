// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.0;

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Lặc Số Một - <expertdicer@gmail.com>
contract MultiSigWallet {
    /* ========== EVENTS ========== */


    /**
    * @notice This event is emited when sender confirm transaction
    * @param sender Address of sender
    * @param transactionId Id's transaction
    */
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    /* ========== CONSTANT ========== */
    /*
     *  constant
     */
    uint constant public MAX_OWNER_COUNT = 50;

    /* ======== STATE VARIABLES ======== */
    /*
     *  Storage
     */
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    address public moderator;
    uint public required;
    uint public transactionCount;
    // bool public isActive;

    /* ========== DATA STRUCTURES ========== */
    struct Transaction {
        address destination;                // địa chỉ contract sẽ đc gọi
        uint value;                         // value: giá trị native token sẽ đc truyền
        bytes data;                         // data: data sẽ được excuted
        bool executed;                      // executed: đã đc thi hành hay chưa
    }
    /* ========== MODIFIERS ========== */
    /**
    * @notice This modifier require authority moderator
    */
    modifier onlyModerator() {
        require(msg.sender == moderator);
        _;
    }

    /**
    * @notice This modifier require authority wallet
    */
    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    /**
    * @notice This modifier require param owner does not exists in owners
    * @param owner Address to check whether exist or not
    */
    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }
    /**
    * @notice This modifier require param owner exists in owners
    * @param owner Address to check whether exist or not
    */
    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }
    /**
    * @notice This modifier require the transaction with transactionId exists
    * @param transactionId Transaction ID
    */
    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != address(0));
        _;
    }
    /**
    * @notice This modifier require owner address confirmed the transaction with transactionId
    * @param transactionId Transaction ID
    * @param owner  Address to check
    */
    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }
    /**
    * @notice This modifier require owner address have not confirmed the transaction with transactionId
    * @param transactionId Transaction ID
    * @param owner Address to check
    */
    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    /**
    * @notice This modifier require the transaction with transactionId have not executed
    * @param transactionId Transaction ID
    */
    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }
    /**
    * @notice This modifier require the address not null
    * @param _address Address to check
    */
    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }


    /**
    * @notice This modifier require the _require is valid with ownerCount
    * @param ownerCount The ownerCount to check
    * @param _require The requirement confirmation to check
    */
    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT
            && _required <= ownerCount
            && _required != 0
            && ownerCount != 0);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    receive() external payable
    {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    /* ========== FUNCTIONS ========== */

    /*
     * Public constructor
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    constructor(address[] memory _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            isOwner[_owners[i]] = true;
        }
        moderator = msg.sender;
        owners = _owners;
        required = _required;
        // isActive = true;
    }

    /**
     * @notice This function changes number of confirmations required
     * @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
     * @param _required Number of required confirmations.
     */

    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

    /**
     * @notice This function submit new transaction and confirm it on behalf of msg.sender
     * @param destination Address of new transaction
     * @param value The value of native token
     * @param data Data is going to execute
     * @return transactionId The transactionId of new transaction
     */
    function submitTransaction(address destination, uint value, bytes calldata data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }
    /**
     * @notice This function allows an msg.sender confirm a transaction with transactionId
     * @dev Allows an owner to confirm a transaction.
     * @param transactionId Transaction ID
     */

    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /**
     * @notice This function allows an msg.sender revoke a transaction with transactionId
     * @dev Allows an owner to revoke a confirmation for a transaction.
     * @param transactionId Transaction ID
     */

    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }
    /**
     * @notice This function allows anyone to execute a confirmed transaction.
     * @param transactionId Transaction ID
     */
    function executeTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            
            (bool success, bytes memory data) = txn.destination.call{ value: txn.value, gas: 34710 } (txn.data);
            
            // if (external_call(txn.destination, txn.value, txn.data.length, txn.data))  
            if (success == true) {        
                emit Execution(transactionId);
            }
            else {  
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }

        }
    }

    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    // function external_call(address destination, uint value, uint dataLength, bytes memory data) internal returns (bool) {
    //     bool result;
    //     assembly {
    //         let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
    //         let d := add(mload(0), 32) // First 32 bytes are the padded length of data, so exclude that
    //         result := call(
    //             sub(gas(), 34710),   // 34710 is the value that solidity is currently emitting
    //                                // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
    //                                // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
    //             destination,
    //             value,
    //             d,
    //             dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
    //             x,
    //             0                  // Output is ignored, therefore the output size is zero
    //         )
    //     }
    //     return result;
    // }
    /**
     * @notice This function returns the confirmation status of a transaction.
     * @param transactionId Transaction ID
     * @return Confirmation status.
     */

    function isConfirmed(uint transactionId)
        public
        view
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /**
     * @notice This function submit new transaction
     * @param destination Address of new transaction
     * @param value The value of native token
     * @param data Data is going to execute
     * @return transactionId The transactionId of new transaction
     */
    function addTransaction(address destination, uint value, bytes calldata data)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    /**
     * @notice This function get the number of confirmation on transaction
     * @param transactionId Transaction ID
     * @return count The number of confirmation 
     */
    function getConfirmationCount(uint transactionId)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /**
     * @notice This function gets the number of transactions with options pending or executed
     * @param pending Include pending transactions.
     * @param executed Include executed transactions.
     * @return count The number of transactions.
     */
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }

    
     /**
     * @notice This function returns list of owners.
     * @return owners List of owner addresses.
     */

    function getOwners()
        public
        view
        returns (address[] memory)
    {
        return owners;
    }
    /**
     * @notice This function returns array with owner addresses, which confirmed transaction.
     * @param transactionId Transaction ID.
     * @return _confirmations Returns array of owner addresses.
     */

    function getConfirmations(uint transactionId)
        public
        view
        returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }
    /**
     * @notice This function returns list of transaction IDs in defined range.
     * @param from Index start position of transaction array.
     * @param to Index end position of transaction array.
     * @param pending Include pending transactions.
     * @param executed Include executed transactions.
     * @return _transactionIds Returns array of transaction IDs.
     */
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        view
        returns (uint[] memory _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }

    // disable multi sig wallet
    // function disableMultiSigWallet() public {
    //     isActive = false;
    // }

    // check multiSigWallet enabled
    // function isMultiSigWalletEnabled() public returns (bool) {
    //     return isActive;
    // }

    // add address
    
     /**
     * @notice This function adds a new owner
     * @param owner The owner's address is going to be added.
     */
    function addAddress(address owner)
        public
        onlyModerator()
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        owners.push(owner);
        isOwner[owner] = true;
    }

    /**
     * @notice This function removes an old owner
     * @param owner The owner's address is going to be removed
     */
    function removeAddess(address owner)
        public 
        onlyModerator()
        validRequirement(owners.length - 1, required)
    {
        for (uint i = 0; i < owners.length; i++) {
            if (owner == owners[i]) {
                owners[i] = owners[ owners.length - 1 ];
                owners.pop();
                isOwner[owner] = false;
                break;
            }
        }
    }

    /**
     * @notice This function removes all owners and adds a new owner
     * @param owner Owner address.
     */
    function changeNewOwner(address owner) public onlyModerator() {
        required = 1;
        for (uint i = 0; i < owners.length; i++) {
            isOwner[owner] = false;
        }

        delete owners;
        owners.push(owner);
        isOwner[owner] = true;

    }
}
