// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

contract Election{ 
    //-----------------------Struct for Candidate and Voters---------------------------------// 
    struct Candidate{
        uint id; 
        string Candidatename; 
        string proposal;
        string Party; 
        address CandidateAddress;
        address payable deposit; 
    }
    struct Voter{
        string Votname; 
        address VoterAddress; 
        uint voteCount;
        uint votedCandidateId; // add this line to track voted candidate
        bool isDelegated; // add this line to track delegation status
    }
    //--------------------------Mappings in the Contract--------------------------------------------//
    mapping(uint => Candidate) public Candidates;  
    mapping(address => Voter) public Voters;
    mapping(uint => uint) public Votes; // Each candidate's vote count
    //----------------------------------Event----------------------------------------------//
    event transferOwnershipadd(address owner);
    event AddCandidate(uint id, string Candname, string Party, address CandidateAddress);
    event AddVoter(string Votname, address VoterAddress);
    event StartElection(string ElectionStatus);
    event DelegateVote(address ownership, address delegateAddress); 
    event CastVote(address VoterAddress);
    event EndElection(string ElectionStatus);
    event ShowWinner(string Candname, string Party, uint VoteCount); 
    //-----------------------------Owner of the contract------------------------------------// 
    address public owner; // Address of the owner

    constructor(){
        owner = msg.sender; 
    }

    modifier adminOnly(){
        require(msg.sender == owner, "Access Granted to the Admins Only");
        _;
    }
    //Transfer the ownership (AdminOnly Access)
    function transferOwnership(address _newOwner) public adminOnly{
        owner = _newOwner; 
        // Emit Transferownership 
        emit transferOwnershipadd(owner);
    }
    //------------------------------------------------------------------------------------//
    // Election Cycle Events
    string[] ElectionStatus_Arr = ["Not-Started", "OnGoing", "Finished"];
    string public ElectionStatus = ElectionStatus_Arr[0];
    //------------------------------------------------------------------------------------//
    //------------------------------------------------------------------------------------//
    //------------------------------------------------------------------------------------//
    // Function 1: Add new Candidate
    uint public candidatesCount = 1; 
    uint minimumDeposit = 0.01 ether;

    function addCandidate(string memory _Candidatename, 
    string memory _proposal,
    string memory _party,  
    address _CandidateAddress,
    address payable _deposit) public payable adminOnly{
        // Require Conditions
        require(keccak256(bytes(ElectionStatus)) == keccak256(bytes(ElectionStatus_Arr[0])), "Election has already started");
        require(_CandidateAddress != address(0), "Candidate address cannot be zero");
        require(_CandidateAddress != owner, " Admin/Owner of the Contract Cannot Contest Election"); 
        for(uint i = 1; i < candidatesCount; i++){
            require(Candidates[i].CandidateAddress != _CandidateAddress, "This candidate is already registered");
        }
        require(bytes(_Candidatename).length > 0, "Candidate name cannot be empty");
        require(bytes(_party).length > 0, "Party name cannot be empty");  
        require(msg.value >= minimumDeposit, "Minimum deposit amount not met");
  

        // Adding Candidates 
        Candidates[candidatesCount] = Candidate(candidatesCount,
         _Candidatename, 
         _proposal,
         _party,
         _CandidateAddress,
         _deposit);

         candidatesCount++; 
         
         // Emit 
        emit AddCandidate(candidatesCount, _Candidatename, _proposal, _CandidateAddress);
    }
    //------------------------------------------------------------------------------------//
    // Function 4: Display Candidates Details
    function displayCandidate(uint _CandidateId) public view returns(string memory, 
    string memory, 
    string memory, 
    address){
        // Require Conditions (If any)

        return (Candidates[_CandidateId].Candidatename, 
        Candidates[_CandidateId].proposal,
        Candidates[_CandidateId].Party,
        Candidates[_CandidateId].CandidateAddress);

    }
    //------------------------------------------------------------------------------------//
    // Function 2: Add a New Voter 
    uint public VoterCount; 

    function addVoter(string memory _Votname,
    address _VoterAddress
    ) public adminOnly{
        // Require Conditions
        require(keccak256(bytes(ElectionStatus)) == keccak256(bytes(ElectionStatus_Arr[0])), "Election has already started");
        require(_VoterAddress != address(0), "Voter address cannot be zero");
        require(Voters[_VoterAddress].VoterAddress != _VoterAddress, "This voter is already registered");
        require(bytes(_Votname).length > 0, "Voter name cannot be empty"); 

        //Adding Voters (Default 1 vote per Voter)
        Voters[_VoterAddress] = Voter(_Votname, _VoterAddress, 1, 0, false); 
        VoterCount++;
        
        //Emit
        emit AddVoter(_Votname, _VoterAddress); 
    } 
    //------------------------------------------------------------------------------------//
    // Function 10: Display Voter Details 

    function viewVoterProfile(address _VoterAddress) public view returns (string memory, uint, bool) {
        return (Voters[_VoterAddress].Votname, 
        Voters[_VoterAddress].votedCandidateId, 
        Voters[_VoterAddress].isDelegated);
}
    //--------------------------- Start of Elections -------------------------------------//
    //------------------------------------------------------------------------------------//
    // Function 3: Start the Election 

    function startElection() public adminOnly{
        // Require Conditions 
        // The election should not have already started
        require(keccak256(bytes(ElectionStatus)) != keccak256(bytes(ElectionStatus_Arr[1])), "Election already started");
        // The election should not have already ended
        require(keccak256(bytes(ElectionStatus)) != keccak256(bytes(ElectionStatus_Arr[2])), "Election has already ended");
        // There should be at least one candidate
        require(candidatesCount > 1, "There should be at least one candidate");

        // Start 
        ElectionStatus = ElectionStatus_Arr[1];

        // Emit 
        emit StartElection(ElectionStatus);
    }
    //------------------------------------------------------------------------------------//
    // Function 6: Delegate Voting Rights 
    function delegateVote(address _ownership, address _delegateAddress) public{
        // Require Statement
        // The voter should have voting rights left
        require(Voters[_ownership].voteCount > 0, "You have no voting rights left to delegate");

        // The delegating voter shouldn't be delegating to themselves
        require(_ownership != _delegateAddress, "You can't delegate voting rights to yourself");

         // The delegate should be a registered voter
        require(Voters[_delegateAddress].VoterAddress == _delegateAddress, "Delegate must be a registered voter");

        // The election should be ongoing
        require(keccak256(bytes(ElectionStatus)) == keccak256(bytes(ElectionStatus_Arr[1])), "Election is not ongoing");


        // Transfer Ownership 
        Voter storage ownerProfile = Voters[_ownership]; 
        Voter storage delegateProfile = Voters[_delegateAddress]; 

        delegateProfile. voteCount += ownerProfile.voteCount; 
        ownerProfile.voteCount = 0;
        ownerProfile.isDelegated = true;  // add this line to update delegation status

        // Emit 
        emit DelegateVote(_ownership, _delegateAddress); 
    }
    //------------------------------------------------------------------------------------//
    // Function 7: Cast the Vote 
    function castVote(address _Voteraddress, uint _CandidateId) public{
        // Require 

        // Voter should have voting rights left
        require(Voters[_Voteraddress].voteCount > 0, "No voting rights left");

        // Candidate should exist
        require(_CandidateId > 0 && _CandidateId <= candidatesCount, "Candidate does not exist");

        // The election should be ongoing
        require(keccak256(bytes(ElectionStatus)) == keccak256(bytes(ElectionStatus_Arr[1])), "Election is not ongoing");

        //--------Voting------------
        // Decrease voter's count
        Voters[_Voteraddress].voteCount--;
        Voters[_Voteraddress].votedCandidateId = _CandidateId;

        // Increase candidate's vote count
        Votes[_CandidateId]++;


        // Emit
        emit CastVote(_Voteraddress); 
    }
    //----------------------------Start of Elections--------------------------------------//
    //------------------------------------------------------------------------------------//
    // Function 8: End the Election 
    function endElection() public adminOnly {
        // Require Condtions
        // The election should be ongoing
        require(keccak256(bytes(ElectionStatus)) == keccak256(bytes(ElectionStatus_Arr[1])), "Election is not ongoing");

        // End the election 
        ElectionStatus = ElectionStatus_Arr[2];

        // Calculate the minimum threshold for deposit return (e.g., 10% of total votes)
        uint minimumThreshold = totalVotes * 10 / 100;

        // Iterate over the candidates to determine deposit return or confiscation
        for (uint i = 1; i < candidatesCount; i++) {
            Candidate storage candidate = Candidates[i];

            // Return deposit if candidate meets the minimum threshold of votes
            if (Votes[i] >= minimumThreshold) {
                candidate.deposit.transfer(candidate.deposit);
            } else {
            // Confiscate deposit by not transferring it back to the candidate
            continue; 
            }
    }

        // Emit 
        emit EndElection(ElectionStatus); 
    }

    //------------------------------------------------------------------------------------//
    // Function 5: Show the Winner of the election 

    function showWinner() public adminOnly returns(string memory, 
    string memory, 
    uint)
    {
        uint highestVoteCount = 0; 
        uint winnerCounter = 0; 
        uint[] memory winner_array = new uint[](candidatesCount); 

        //Require Conditions

        // The election should be finished
        require(keccak256(bytes(ElectionStatus)) == keccak256(bytes(ElectionStatus_Arr[2])), "Election has not ended yet");

        
        // Counting the highest Vote Count 
        for (uint i = 1; i <= candidatesCount; i++) {
            if (Votes[i] >= highestVoteCount) {
                highestVoteCount = Votes[i];
                }
        }

        // Obtaining all the candidates with same highest score 
        for (uint i = 1; i <= candidatesCount; i++){
            if(Votes[i] == highestVoteCount){
                winner_array[winnerCounter] = i;
                winnerCounter++;
            }
        }

        // In the Case if we have a tie, the winner is decided via lottery system to declare the winner.
        uint CandidateId;
        if(winnerCounter > 1) {
            CandidateId = winner_array[uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % winnerCounter];
        } else {
            CandidateId = winner_array[0];
        }

        // Emit 
        emit ShowWinner(Candidates[CandidateId].Candidatename,Candidates[CandidateId].Party, Votes[CandidateId]);
    
        return (Candidates[CandidateId].Candidatename,
        Candidates[CandidateId].Party,
        Votes[CandidateId]);

    }

    //------------------------------------------------------------------------------------//
    // Function 7: Show election Results

    function showElectionResult(uint _CandidateId) public view returns(string memory, 
    string memory, 
    uint) {
        // Require Conditions
        // The candidate should exist
        require(_CandidateId > 0 && _CandidateId <= candidatesCount, "Candidate does not exist");

        // The election should be finished
        require(keccak256(bytes(ElectionStatus)) == keccak256(bytes(ElectionStatus_Arr[2])), "Election has not ended yet");

        
        // Displaying Election Results
        return (Candidates[_CandidateId].Candidatename,
        Candidates[_CandidateId].Party,
        Votes[_CandidateId]
        );
    }
    //------------------------------------------------------------------------------------//
    // Function 11: Reset Elections or Conducting Fresh Elections. 

    function resetElection() public adminOnly {
    // Require Conditions
    // The election should have already ended
    require(keccak256(bytes(ElectionStatus)) == keccak256(bytes(ElectionStatus_Arr[2])), "Election has not ended yet");

    // Reset state variables
    for (uint i = 1; i < candidatesCount; i++) {
        delete Candidates[i];
        delete Votes[i];
    }
    candidatesCount = 1;
    VoterCount = 0;
    ElectionStatus = ElectionStatus_Arr[0];
    // Emit
    emit StartElection(ElectionStatus);
    }

}
