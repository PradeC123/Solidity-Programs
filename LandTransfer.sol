pragma solidity ^0.8.0; 

contract PropertyTransfer{
    address public owner; 
    struct Property{
        string name; 
        address owner; 
        uint value; 
        uint area;
    }
    // Define the events
    event PropertyAdded(uint id, string name, uint value, uint area, address owner);
    event OwnershipTransfered(uint id , address newOwner);
    //
    mapping(uint=>Property) public PropertyRecord; 
    // 
    constructor() {
        owner = msg.sender; //Owner of the contract
    }
    //
    modifier onlyOwner{
        require(msg.sender == owner, "The execution of this contract lies with it's owner"); 
        _;
    }
    // 
    function addProperty(uint id, string memory _name, uint _value, uint _area) public onlyOwner{
        PropertyRecord[id].name = _name; 
        PropertyRecord[id].owner = msg.sender; 
        PropertyRecord[id].value = _value; 
        PropertyRecord[id].area = _area;
        // 
        emit PropertyAdded(id, _name, _value, _area, msg.sender);
    }
    //
    function getPropertyRecord(uint _id) public view returns(string memory _name, address _owner, uint _value, uint _area){
        return (PropertyRecord[_id].name, PropertyRecord[_id].owner, PropertyRecord[_id].value, PropertyRecord[_id].area); 
    }

    // 
    modifier onlyPropertyOwner(uint _id) {
        require(msg.sender == PropertyRecord[_id].owner, "Only the owner of the property can execute this");
        _;
    }

    function TransferOwnership(uint _id, address _newowner) public onlyPropertyOwner(_id) {
        require(msg.sender != _newowner, "The owner cannot transfer the ownership to itself");
        PropertyRecord[_id].owner = _newowner;
        //
        emit OwnershipTransfered(_id, _newowner);
    }

}