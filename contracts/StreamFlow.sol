 //SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {StreamRedirect, ISuperToken, IConstantFlowAgreementV1, ISuperfluid} from "./StreamRedirect.sol";


contract StreamFlow is StreamRedirect {

  // mapping(string => address) winner; // the current winner will be the doubt_poster

  constructor (
    address owner, // your primary accounts address
    ISuperfluid host, // 0xeD5B5b32110c3Ded02a07c8b8e97513FAfb883B6 Rinkby testnet
    IConstantFlowAgreementV1 cfa, // 0xF4C5310E51F6079F601a5fb7120bC72a70b96e2A for Rinkeyby testnet
    ISuperToken acceptedToken // ETHx 0xa623b2DD931C5162b7a0B25852f4024Db48bb1A0 for Rinkeyby testnet
  )
    StreamRedirect (
      host,
      cfa,
      acceptedToken,
      owner
     )
      {}

  //now I will insert a nice little hook in the _transfer, including the RedirectAll function I need
  // function _beforeTokenTransfer(
  //   address /*from*/,
  //   address to,
  //   uint256 /*tokenId*/
  // ) internal {
  //     _changeReceiver(to);
  // }

  struct Doubt {
    address payable posterAddress;
    uint quesId;
    string heading;
    string description;
    int96 bounty;
    uint timeOfPosting;
    uint dueDate;
    int maxUpvote;
    int mostUpvoteAnsIndex;
    address current_winner;
  }

  struct Answer {
    string ans;
    address answerer;
    uint upvotes;
    uint ansId;
  }

  Doubt[] internal doubts; // to store all of the doubts
  uint256 masterIndex = 0;

  mapping (uint => Answer[]) quesToAnsS;// stored all the answer in a array so its easy to iterate, and mapped it to its qId below
  mapping (uint => mapping (uint => mapping(address =>bool))) questionToAnsToupvoter;

  event NewDoubt(address indexed from, uint256 quesId, string heading, string description);

  function writeDoubt(
    string memory _heading,
    string memory _description,
    uint _dueDate, 
    int96 _bounty) public {
      doubts.push(
        Doubt(
          payable (msg.sender),
          masterIndex,
          _heading,
          _description,
          _bounty, // enter this amount in wei, it will used in the money stream.
          block.timestamp,
          _dueDate + block.timestamp,
          -1, // initialzed maxUpvote to -1, to will change to zero when first answer is upvoted, (enable cashback to owner)
          -1,//same reason as above.
          msg.sender
      ));
      emit NewDoubt(msg.sender, masterIndex, _heading, _description);
      masterIndex++;
  }

  // read all the doubts
  function readDoubts() public view returns(Doubt[] memory) {
    return doubts;
  }

  // post an answer
  function answerDoubt(string memory answer, uint qId) public {
    Answer memory ans = Answer(answer, msg.sender, 0, quesToAnsS[qId].length);
    quesToAnsS[qId].push(ans);//pushing answer to AnsS array
    questionToAnsToupvoter[qId][quesToAnsS[qId].length-1]; //initializing IDK its needed or not if not required, will remove it
  }

  // upvote an answer
  function upVote(uint _doubtIndex, uint _ansIndex) public {
    
    require(questionToAnsToupvoter[_doubtIndex][_ansIndex][msg.sender] == false, "You can upvote an answer only once");

      questionToAnsToupvoter[_doubtIndex][_ansIndex][msg.sender] = true;// marking the upvoter
      quesToAnsS[_doubtIndex][_ansIndex].upvotes++; // inc. the upvote for the answer by accessing

      //logic for updating winner in maxUpvotedAnsId
      if(int(quesToAnsS[_doubtIndex][_ansIndex].upvotes) > doubts[_doubtIndex].maxUpvote){
        updateWinner(_doubtIndex, _ansIndex) //checking maxupvote for that question to the latest upvoted ans vote
      }
    }
  }

  //A function to change the maxmimum upvotes and the winner
  function updateWinner (uint _doubtIndex, uint _ansIndex)  public {
        doubts[_doubtIndex].maxUpvote = int(quesToAnsS[_doubtIndex][_ansIndex].upvotes); // reassigning maxupvote if needer
        doubts[_doubtIndex].mostUpvoteAnsIndex = int(_ansIndex); // and mostupvoteAnsIndex
        doubts[_doubtIndex].current_winner = quesToAnsS[_doubtIndex][_ansIndex].answerer; // updates the address of current winner

        changeWinner(doubts[_doubtIndex].current_winner); // changing the winner stream
  }

  function readAnsS(uint _doubtIndex, uint _ansIndex) public view returns(Answer memory) {
    return quesToAnsS[_doubtIndex][_ansIndex];
  }

  //Function that returns the number of upvotes an answer has -> this would require the doubtID and ansID
  function readUpvotes(uint _doubtIndex, uint _ansIndex ){
    return quesToAnsS[_doubtIndex][_ansIndex].upvotes;
  }

  function changeWinner (address newWinner) public {
    _changeReceiver(newWinner);
  }
}