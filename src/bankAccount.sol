// SPDX-License-Identifier: MIT
pragma solidity >=0.3.2 <0.9.0;

contract bankAccount{
     struct Account  {
        string name;
        string email;
        bool isActive; 
        uint256 balance; 
    }

    address payable public owner;

    mapping(address => Account) public accounts;
    mapping(string => bool) public createdAccounts;
    mapping(address => uint) private balances;

   

    event depositEvent(address depositor, uint256 _amount);

    event withdrawEvent(address withdrawer, uint256 _withdraw);

    event accountCreated(address _accountAddress, string name, string email);

    constructor(){
        owner = payable (msg.sender);
        
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "You are not the owner");
        _;
    }


    modifier hasCreatedAccount() {
        require(accounts[msg.sender].isActive, "You must create an account first");
        _;
    }


    // Creating a new account
    function createbankAccount(string memory _name, string memory _email) public {
       
        // Check if an account with the given name already exists
        require(createdAccounts[_email] == false, "Account already exists");

        // Mark the account name as created
        createdAccounts[_email] = true;

        // create the account
        accounts[msg.sender] = Account(_name, _email, true, 0);
        emit accountCreated(msg.sender, _name, _email);
    }
    
   // Function to get account details 
    function getAccountDetails() public view  onlyOwner returns (string memory , string memory , bool , uint256 ) {
        Account memory account = accounts[msg.sender];
        return (account.name, account.email, account.isActive, balances[msg.sender]);
    }

    //deposit

    function deposit () public payable  onlyOwner hasCreatedAccount returns(uint){
       
        //Check if the new balance is greater than the previous one before deposit
        require((balances[msg.sender] + msg.value) >= balances[msg.sender], "No deposit made");
      
       //update the balance after making a deposit
        balances[msg.sender] += msg.value;

        emit depositEvent(msg.sender, msg.value);
        return balances[msg.sender];    
    }

    //withdraw from the account

    function withdraw(uint256 _amount) public onlyOwner returns (uint256 remainingBalance){
        //check if the withdraw amount is not greater than the current amount
        require(_amount <= balances[msg.sender], "INSUFFICIENT FUNDS");
        
        //update the balance after the withdraw
        balances[msg.sender]-= _amount;
        emit withdrawEvent(msg.sender, _amount);

        return balances[msg.sender];
        
    } 

    //sending funds to another account

     function sendFunds(address payable _to, uint256 _amount) public payable onlyOwner{
        require(balances[msg.sender] >= _amount, "INSUFFICIENT FUNDS");

        // accounts[msg.sender].balance -= _amount;
        balances[msg.sender] -= _amount;

        (bool sent, ) = _to.call{value: _amount}("");

        require(sent, "Failed to send the funds");
     }

     // To receive Ether from another account
        receive()  external payable {
            balances[msg.sender] += msg.value;
            emit depositEvent(msg.sender, msg.value);
        }


        //getting balance 
        function getBalance() public view onlyOwner returns(uint){
            return balances[msg.sender];
        }
  
}


//After deploying using foundry
// Deployer: 0x96743A8172Ba6329EdaE8373A50a0ABD2D231962
// Contract address: 0x81f924C76Ff95e27678C539611F80c9bB1C5839f
// Transaction hash: 0xaeb68e3aca2d7dcc9e0d35210d83cc4b0f32e158fca4b7e4ba148fd75ee17bbb

