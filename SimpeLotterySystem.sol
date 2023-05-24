pragma solidity <0.8.0;

contract Lottery {
    address owner;
    address payable[] joinLottery;
    mapping(address => bool) public hasJoined;
    
    // Define the events
    event JoinedLottery(address indexed participant, uint timestamp);
    event WinnerChosen(address indexed winner, uint prize, uint timestamp);

    constructor(){
        owner = msg.sender; // Owner of the contract 
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function joinLotteryarr() public payable {
        require(msg.value > 0.02 ether, "Please enter atleast 0.02 ether to enter the tournament"); 
        require(!hasJoined[msg.sender], "This address has already joined the lottery.");
        joinLottery.push(payable(msg.sender)); 
        hasJoined[msg.sender] = true;

        // Emit the JoinedLottery event
        emit JoinedLottery(msg.sender, block.timestamp);
    }

    function getLotteryaddress() public view returns(address payable[] memory) {
        return joinLottery;
    }

    function random() private view returns (uint) {
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, joinLottery.length)));
    }

    function pickWinner() public onlyOwner {
        require(joinLottery.length > 0, "No participants in the lottery yet.");
        uint randomIndex = random() % joinLottery.length;
        address payable winner = joinLottery[randomIndex];
        
        // Send all Ether held by the contract to the winner
        uint prize = address(this).balance;
        uint ownerPrize = prize / 10; // 10% for owner
        uint winnerPrize = prize - ownerPrize; // 90% for winner
        
        // Transfer the prizes
        owner.transfer(ownerPrize);
        winner.transfer(winnerPrize);

        // Emit the WinnerChosen event
        emit WinnerChosen(winner, prize, block.timestamp);
        // Reset lottery for next round
        for (uint i = 0; i < joinLottery.length; i++) {
            hasJoined[joinLottery[i]] = false;
        }
        delete joinLottery;
    }
}
