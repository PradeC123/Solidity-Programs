// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract JobPortal{
    //-------------Struct for Job and Appicant-----------------------// 
    struct Job {
    uint jobId;  // The unique ID of the job
    address employerId;  // The Ethereum address of the employer who posted the job
    string title;  // The title of the job
    string description;  // A description of the job, including responsibilities and tasks
    string location;  // The location of the job, which can be physical or remote
    uint salary;  // The annual salary for the job
    bool isOpen;  // A boolean value representing whether the job is still open for applications
    string jobType; // The type of job (e.g., "construction", "farming", "domestic help")
    uint[] appliedCandidate;  // An array of applied Candidates, representing jobs the applicant has applied for
    }

    
   struct Applicant {
        address id;  // The Ethereum address of the applicant
        string name;  // The name of the applicant
        string email;  // The email address of the applicant
        uint[] appliedJobs;  // An array of job IDs, representing jobs the applicant has applied for
        mapping(uint => uint) ratings;  // A mapping of job IDs to ratings received for each job
        string jobType; // The type of job (e.g., "construction", "farming", "domestic help")
        string education; // The educational background of the applicant
        string skills; // The skills of the applicant
        string experience; // The job experience of the applicant
        string location; // The location of the applicant
        string languages; // Languages known by the applicant
        bool availability; // The availability status of the applicant
        string personalStatement; // Personal statement of the applicant
    }
    //-------------Admin of the Contract-----------------------// 
    address public owner; 

    constructor(){
        owner = msg.sender; // Owner's Address 
    }

    modifier adminOnly(){
        require(owner == msg.sender, "Rights reserved only the Admin of the contract");
        _;
    }
    //-------------------------------------------------------// 
    mapping(address => Applicant) applicants; 
    mapping(uint=>Job) JobPost; 
    //-------------------------------------------------------//
    //-----------------Add a new applicant------------------//
    //-------------------------------------------------------// 
    // Function to add an applicant
    //-------------------------------------------------------//
    // Function to add an applicant
    function addApplicant(address _id, string memory _name, string memory _email, string memory _jobType, string memory _education, string memory _skills, string memory _experience, string memory _location, string memory _languages, bool _availability, string memory _personalStatement) public adminOnly {
    // Check that the address is not zero
    require(_id != address(0), "Invalid address");
    
    // Check that the applicant does not already exist
    require(applicants[_id].id == address(0), "Applicant already exists");

    // Check that the name is not empty
    require(bytes(_name).length > 0, "Invalid name");

    // Check that the email is not empty
    require(bytes(_email).length > 0, "Invalid email");

    // Check that the job type is not empty
    require(bytes(_jobType).length > 0, "Invalid job type");

    // More requirements can be added as needed...

    // Add Candidate
    Applicant storage applicant = applicants[_id];
    applicant.id = _id;
    applicant.name = _name;
    applicant.email = _email;
    applicant.jobType = _jobType;
    applicant.education = _education;
    applicant.skills = _skills;
    applicant.experience = _experience;
    applicant.location = _location;
    applicant.languages = _languages;
    applicant.availability = _availability;
    applicant.personalStatement = _personalStatement;
    }
    //-------------------------------------------------------//
    // Function to fetch the applicant
    function fetchApplicant(address _id) public view returns (address, string memory, string memory, string memory, string memory, string memory, string memory, string memory, string memory, bool, string memory) {
        Applicant storage applicant = applicants[_id];
        return (applicant.id, applicant.name, applicant.email, applicant.jobType, applicant.education, applicant.skills, applicant.experience, applicant.location, applicant.languages, applicant.availability, applicant.personalStatement);
    }
    //-------------------------------------------------------//
    // Get applicant type 
    // Function to fetch the applicant type 
    function getApplicantType(address _id) public view returns(string memory){
        Applicant storage applicant = applicants[_id];
        return (applicant.jobType); 
    }
    //----------------------Add Jobs---------------------------------//
    uint public jobId = 0; 

    function addJob(address _employerId, string memory _title, string memory _description, string memory _location, uint _salary, string memory _jobType) public adminOnly{
    // Check that the employer address is not zero
    require(_employerId != address(0), "Invalid employer address");

    // Check that the title is not empty
    require(bytes(_title).length > 0, "Invalid title");

    // Check that the description is not empty
    require(bytes(_description).length > 0, "Invalid description");

    // Check that the location is not empty
    require(bytes(_location).length > 0, "Invalid location");

    // Check that the salary is greater than zero
    require(_salary > 0, "Invalid salary");

    // Check that the job type is not empty
    require(bytes(_jobType).length > 0, "Invalid job type");

    jobId++;
    uint[] memory emptyArray;
    JobPost[jobId] = Job(jobId, _employerId, _title, _description, _location, _salary, true, _jobType, emptyArray);
    }

    //----------------------fetch job data---------------------------------//
    // Function to fetch job data
    function fetchJob(uint _jobId) public view returns(uint, address, string memory, string memory, string memory, uint, bool, string memory) {
        Job storage job = JobPost[_jobId];
        return (job.jobId, job.employerId, job.title, job.description, job.location, job.salary, job.isOpen, job.jobType);
    }
    //-------------------------------------------------------//
    // Function to allow an applicant to apply for a job
    function applyForJob(address _applicantId, uint _jobId) public {
    // Check that the applicant exists
    require(applicants[_applicantId].id != address(0), "Applicant does not exist");

    // Check that the job exists
    require(JobPost[_jobId].jobId == _jobId, "Job does not exist");

    // Check that the job is still open
    require(JobPost[_jobId].isOpen, "Job is not open");

    // Check that the applicant has not already applied for this job
    for (uint i = 0; i < applicants[_applicantId].appliedJobs.length; i++) {
        require(applicants[_applicantId].appliedJobs[i] != _jobId, "Applicant has already applied for this job");
    }

    // Add the job to the applicant's appliedJobs array
    applicants[_applicantId].appliedJobs.push(_jobId);

    // Add the candidate to the job's applied Candidate array 
    JobPost[_jobId].appliedCandidate.push(_jobId);
    }

    //-------------------------------------------------------//
    // Function to provide a rating to an applicant
    function provideRating(address _applicantId, uint _jobId, uint _rating) public adminOnly {
    // Check that the applicant exists
    require(applicants[_applicantId].id != address(0), "Applicant does not exist");

    // Check that the job exists
    require(JobPost[_jobId].jobId == _jobId, "Job does not exist");

    // Check that the rating is in an acceptable range (e.g., 1-5)
    require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");

    // Check if the applicant has applied for the given job
    bool hasApplied = false;
    for (uint i = 0; i < applicants[_applicantId].appliedJobs.length; i++) {
        if (applicants[_applicantId].appliedJobs[i] == _jobId) {
            hasApplied = true;
            break;
        }
    }
    require(hasApplied, "Applicant has not applied for this job");

    // Assign the rating to the applicant for the specified job
    applicants[_applicantId].ratings[_jobId] = _rating;
    }
  
    //-------------------------------------------------------//
    // Function to fetch applicant ratings
    function fetchApplicantRatings(address _applicantId) public view returns (uint[] memory, uint[] memory) {
    // Check that the applicant exists
    require(applicants[_applicantId].id != address(0), "Applicant does not exist");

    Applicant storage applicant = applicants[_applicantId];
    uint[] memory jobIds = new uint[](applicant.appliedJobs.length);
    uint[] memory ratings = new uint[](applicant.appliedJobs.length);
    
    for (uint i = 0; i < applicant.appliedJobs.length; i++) {
        jobIds[i] = applicant.appliedJobs[i];
        ratings[i] = applicant.ratings[applicant.appliedJobs[i]];
    }
    return (jobIds, ratings);
}

    
}