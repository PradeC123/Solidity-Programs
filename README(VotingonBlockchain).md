# Solidity-Programs

Contract: Election
This contract sets up a basic voting system where candidates can be added, votes can be cast by voters, and winners can be declared. It follows a specific lifecycle starting from registration to the end of the election.

Functions:
1) addCandidate:

This function allows the admin to add a new candidate for the election.
The election should not be ongoing or finished (i.e., it should be in the registration phase).
The candidate's address should not be null and the candidate should not already be registered.
The candidate's name and party name should not be empty.
The admin needs to provide the candidate's name, proposal, party name, and Ethereum address.

2) displayCandidate:

This function allows anyone to display a candidate's details.
The caller needs to provide the unique identifier (id) of the candidate.

3) addVoter:

This function allows the admin to add a new voter for the election.
The election should not be ongoing or finished (i.e., it should be in the registration phase).
The voter's address should not be null and the voter should not already be registered.
The voter's name should not be empty.
The admin needs to provide the voter's name and Ethereum address.

4) displayVoter:

This function allows anyone to display a voter's details.
The caller needs to provide the Ethereum address of the voter.

5) startElection:

This function allows the admin to start the election.
The election should not have already started or finished.
There should be at least one candidate in the election.

6) delegateVote:

This function allows any voter to delegate their voting rights to another voter.
The voter delegating their voting rights should have voting rights left.
The delegating voter should not be delegating to themselves.
The election should be ongoing.
The voter needs to provide their Ethereum address and the delegate's Ethereum address.

7) castVote:

This function allows any voter to cast a vote for a candidate.
The voter should have voting rights left.
The candidate should exist.
The election should be ongoing.
The voter needs to provide their Ethereum address and the id of the candidate.

8) endElection:

This function allows the admin to end the election.
The election should be ongoing.

9) showWinner:

This function allows the admin to display the winner of the election.
The election should be finished.
In case of a tie, a winner is chosen randomly.

10 )showElectionResult:

This function allows anyone to display the election result of a specific candidate.
The candidate should exist.
The election should be finished.
The caller needs to provide the id of the candidate.

//-----------------------------------------------------------------------------------------------------------------------------//

Events:
transferOwnershipadd: emitted when ownership is transferred to a new admin.
AddCandidate: emitted when a new candidate is added.
AddVoter: emitted when a new voter is added.
StartElection: emitted when the election starts.
DelegateVote: emitted when a voter delegates their vote to another voter.
CastVote: emitted when a vote is cast.
EndElection: emitted when the election ends.
ShowWinner: emitted when the winner of the election is shown.
//-----------------------------------------------------------------------------------------------------------------------------//
Modifiers:
adminOnly: ensures only the owner of the contract (admin) can call the function.
