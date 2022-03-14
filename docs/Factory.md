# `Factory`






## Functions


### getInstantiationCount()
  
  
  Returns number of instantiations by creator.


```solidity
  getInstantiationCount(
    address creator
  ) public returns (uint256)
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`creator` | address | Contract creator.




#### Return values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`Returns`| address | number of instantiations by creator.


### register()
  
  
  Registers contract in factory registry.


```solidity
  register(
    address instantiation
  ) internal
```
#### Parameters list:

| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`instantiation` | address | Address of contract instantiation.





---

## Events





```solidity
  ContractInstantiation(address sender, address instantiation)
```



---


