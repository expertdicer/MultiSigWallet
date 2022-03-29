# `OwnerManager`






## Functions


### setupOwners()
  
  
  Setup function sets initial storage of contract.


```solidity
  setupOwners(
    address[] _owners,
    uint256 _threshold
  ) internal
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`_owners` | address[] | List of Safe owners.
|`_threshold` | uint256 | Number of required confirmations for a Safe transaction.





### addOwnerWithThreshold()
  Adds the owner `owner` to the Safe and updates the threshold to `_threshold`.

  
  Allows to add a new owner to the Safe and update the threshold at the same time.
     This can only be done via a Safe transaction.


```solidity
  addOwnerWithThreshold(
    address owner,
    uint256 _threshold
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`owner` | address | New owner address.
|`_threshold` | uint256 | New threshold.





### removeOwner()
  Removes the owner `owner` from the Safe and updates the threshold to `_threshold`.

  
  Allows to remove an owner from the Safe and update the threshold at the same time.
     This can only be done via a Safe transaction.


```solidity
  removeOwner(
    address prevOwner,
    address owner,
    uint256 _threshold
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`prevOwner` | address | Owner that pointed to the owner to be removed in the linked list
|`owner` | address | Owner address to be removed.
|`_threshold` | uint256 | New threshold.





### swapOwner()
  Replaces the owner `oldOwner` in the Safe with `newOwner`.

  
  Allows to swap/replace an owner from the Safe with another address.
     This can only be done via a Safe transaction.


```solidity
  swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`prevOwner` | address | Owner that pointed to the owner to be replaced in the linked list
|`oldOwner` | address | Owner address to be replaced.
|`newOwner` | address | New owner address.





### changeThreshold()
  Changes the threshold of the Safe to `_threshold`.

  
  Allows to update the number of required confirmations by Safe owners.
     This can only be done via a Safe transaction.


```solidity
  changeThreshold(
    uint256 _threshold
  ) public
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`_threshold` | uint256 | New threshold.





### getThreshold()
  
  
  

```solidity
  getThreshold() public returns (uint256)
```




### isOwner()
  
  
  

```solidity
  isOwner() public returns (bool)
```




### getOwners()
  
  
  Returns array of owners.


```solidity
  getOwners() public returns (address[])
```


#### Return values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`Array`|  | of Safe owners.


---

## Events





```solidity
  AddedOwner(address owner)
```






```solidity
  RemovedOwner(address owner)
```






```solidity
  ChangedThreshold(uint256 threshold)
```



---


