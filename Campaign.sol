
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Campaign {

    address public owner;
    //proje ismi
    string public name ="Canaria";

    //Proje aciklamasi
    string public description="Test";

    //Minimum bagis miktari
    uint public minContribution=1000;

    

    struct Request {
        string requestDescription;
         uint value;
         address receipent;
         bool isCompleted;
         uint approvalCount;
         mapping(address => bool)approvals;
    }

    Request[] public requests;

    //Bool bir deger degil string de verebilirdik. //Contributer bunlar.
    mapping(address => bool) public approvers; //ilgili adres mapping icereisinde ture | false donecek. True ise dahil edilmis kisidir.
    uint public approversCount=0; //approver sayisi tutulacak.


    event NewRequest(string requestDescription, uint value, address receipent);

    constructor (){
        owner = msg.sender;
        //name= _name;
        //description = _description;
        //minContribution = _minContribution;
    } 

    modifier onlyOwner () {
        //do smth before function
        require(msg.sender == owner,"only owner");
        _;

        //do smth after function

    }


    //Para gonderilebilir olmasi icin 'payable' olmalı.
    function contribute () public payable {
        
        require(msg.value >= minContribution, "less than min contribution");
        approvers[msg.sender] = true;  //mapping içerisinde ilgili adres var anlamına geliyor. 
        approversCount++;
    }

    function createRequest(string calldata _description, uint _value, address _receipent) public onlyOwner {
        
        Request storage newRequest = requests.push(); 

        newRequest.requestDescription = _description;
        newRequest.value = _value;
        newRequest.receipent = _receipent;

        emit NewRequest(_description,_value,_receipent);
    }

    function approveRequest(uint _index) public {
        require (approvers[msg.sender] == true,"not contributer");
        Request storage currentRequest = requests[_index];
        require(currentRequest.approvals[msg.sender] == false,"already approved");
        currentRequest.approvals[msg.sender]=true;
        currentRequest.approvalCount++;

    }

    function finalizeRequest (uint _index) public onlyOwner {

        require(msg.sender == owner, "only owner");
        Request storage currentRequest = requests[_index];
        require(currentRequest.isCompleted ==false,"already completed");
        require(currentRequest.approvalCount > (currentRequest.approvalCount/2),"not enough approvals");
        currentRequest.isCompleted = true;

        payable (currentRequest.receipent).transfer(currentRequest.value);
    }
}
