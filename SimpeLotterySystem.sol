pragma solidity <0.8.0;

// Defining a contract for a lottery system
contract Lottery {
    address owner; // Owner of the contract
    address payable[] joinLottery; // Array of players who have joined the lottery
    mapping(address => bool) public hasJoined; // Mapping to check if an address has joined the lottery or not
    
    // Event that is triggered when a participant joins the lottery
    event JoinedLottery(address indexed participant, uint timestamp);
    
    // Event that is triggered when a winner is chosen
    event WinnerChosen(address indexed winner, uint prize, uint timestamp);

    // Constructor function that sets the contract owner to the sender of the contract deployment transaction
    constructor(){
        owner = msg.sender; 
    }

    // Modifier function to ensure certain functions can only be called by the contract owner
    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Function that allows a participant to join the lottery
    function joinLotteryarr() public payable {
        require(msg.value > 0.02 ether, "Please enter atleast 0.02 ether to enter the tournament");
        require(!hasJoined[msg.sender], "This address has already joined the lottery.");
        // Add the participant to the array of participants
        joinLottery.push(payable(msg.sender)); 
        // Set the participant as having joined the lottery
        hasJoined[msg.sender] = true;
        // Emit the JoinedLottery event
        emit JoinedLottery(msg.sender, block.timestamp);
    }

    // Function to get the list of all participants
    function getLotteryaddress() public view returns(address payable[] memory) {
        return joinLottery;
    }

    // Private function to generate a random number
    function random() private view returns (uint) {
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, joinLottery.length)));
    }

    // Function to choose a winner for the lottery
    function pickWinner() public onlyOwner {
        // Require that there is at least one participant
        require(joinLottery.length > 0, "No participants in the lottery yet.");
        // Generate a random index to pick a winner
        uint randomIndex = random() % joinLottery.length;
        address payable winner = joinLottery[randomIndex];
        
        // Calculate the prize amounts
        uint prize = address(this).balance; // All Ether held by the contract
        uint ownerPrize = prize / 10; // 10% for the owner
        uint winnerPrize = prize - ownerPrize; // 90% for the winner
        
        // Transfer the prizes
        payable(owner).transfer(ownerPrize);
        winner.transfer(winnerPrize);

        // Emit the WinnerChosen event
        emit WinnerChosen(winner, prize, block.timestamp);
        
        // Reset the lottery for the next round
        for (uint i = 0; i < joinLottery.length; i++) {
            hasJoined[joinLottery[i]] = false;
        }
        delete joinLottery;
    }
}
