# `MultiSigWallet`





## Modifiers

### `onlyModerator()`





### `onlyWallet()`





### `ownerDoesNotExist(address owner)`





### `ownerExists(address owner)`





### `transactionExists(uint256 transactionId)`





### `confirmed(uint256 transactionId, address owner)`





### `notConfirmed(uint256 transactionId, address owner)`





### `notExecuted(uint256 transactionId)`





### `notNull(address _address)`





### `validRequirement(uint256 ownerCount, uint256 _required)`






---

## Functions


### receive()
  o deposit ether.
    receive() external payable
  
  

```solidity
  receive() external
```




### constructor()
  initial owners and required number of confirmations.

  
  

```solidity
  constructor(
    address[] _owners,
    uint256 _required
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`_owners` | address[] | List of initial owners.
|`_required` | uint256 | Number of required confirmations.
    constructor(address[] memory





### changeRequirement()
  r of required confirmations. Transaction has to be sent by wallet.

  
  

```solidity
  changeRequirement(
    uint256 _required
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`_required` | uint256 | Number of required confirmations.
    function changeRequirement(ui





### submitTransaction()
  
  
  

```solidity
  submitTransaction() public returns (uint256 transactionId)
```




### confirmTransaction()
  a transaction.

  
  

```solidity
  confirmTransaction(
    uint256 transactionId
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`transactionId` | uint256 | Transaction ID.
    function confirmTransaction(u





### revokeConfirmation()
  a confirmation for a transaction.

  
  

```solidity
  revokeConfirmation(
    uint256 transactionId
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`transactionId` | uint256 | Transaction ID.
    function revokeConfirmation(u





### executeTransaction()
  confirmed transaction.

  
  

```solidity
  executeTransaction(
    uint256 transactionId
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`transactionId` | uint256 | Transaction ID.
    function executeTransaction(u





### isConfirmed()
  tatus of a transaction.

  
  

```solidity
  isConfirmed(
    uint256 transactionId
  ) public returns (bool)
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`transactionId` | uint256 | Transaction ID.




#### Return values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`Confirmation`| uint256 | status.
    function isConfirmed(uint tra


### addTransaction()
  
  
  

```solidity
  addTransaction() internal returns (uint256 transactionId)
```




### getConfirmationCount()
  
  
  

```solidity
  getConfirmationCount() public returns (uint256 count)
```




### getTransactionCount()
  
  
  

```solidity
  getTransactionCount() public returns (uint256 count)
```




### getOwners()
  
  
  

```solidity
  getOwners() public returns (address[])
```


#### Return values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`List`|  | of owner addresses.
    function getOwners()


### getConfirmations()
  ddresses, which confirmed transaction.

  
  

```solidity
  getConfirmations(
    uint256 transactionId
  ) public returns (address[] _confirmations)
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`transactionId` | uint256 | Transaction ID.




#### Return values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`_confirmations`| uint256 | Returns array of owner addresses.
    function getConfirmations(uin


### getTransactionIds()
  n IDs in defined range.

  
  

```solidity
  getTransactionIds(
    uint256 from,
    uint256 to,
    bool pending,
    bool executed
  ) public returns (uint256[] _transactionIds)
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`from` | uint256 | Index start position of transaction array.
|`to` | uint256 | Index end position of transaction array.
|`pending` | bool | Include pending transactions.
|`executed` | bool | Include executed transactions.




#### Return values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`_transactionIds`| uint256 | Returns array of transaction IDs.
    function getTransactionIds(ui


### disableMultiSigWallet()
  
  
  

```solidity
  disableMultiSigWallet() public
```




### isMultiSigWalletEnabled()
  
  
  

```solidity
  isMultiSigWalletEnabled() public returns (bool)
```




### addAddress()
  
  
  

```solidity
  addAddress() public
```




### removeAddess()
  
  
  

```solidity
  removeAddess() public
```




---

## Events





```solidity
  Confirmation(address sender, uint256 transactionId)
```






```solidity
  Revocation(address sender, uint256 transactionId)
```






```solidity
  Submission(uint256 transactionId)
```






```solidity
  Execution(uint256 transactionId)
```






```solidity
  ExecutionFailure(uint256 transactionId)
```






```solidity
  Deposit(address sender, uint256 value)
```






```solidity
  OwnerAddition(address owner)
```






```solidity
  OwnerRemoval(address owner)
```






```solidity
  RequirementChange(uint256 required)
```



---

## Structs

```solidity
  Transaction {

    address destination


    uint256 value


    bytes data


    bool executed

  }
```

---

