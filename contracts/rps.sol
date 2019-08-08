pragma solidity 0.5.10;

contract rps {
  address public owner;
  uint256 public balance;
  uint256 public gamesPlayed;
  string public lastResult;

  enum hand {ROCK, PAPER, SCISSORS}
  enum result {WIN, LOSE, TIE}
  event Outcome(string result);

  constructor() public payable{
    owner = msg.sender;
    balance = msg.value;
    gamesPlayed = 0;
    lastResult = "";
  }

  // Give balance to bot
  function giveBalance() public payable{
    if (msg.sender == owner) {
      balance += msg.value;
    }
  }

  // Get games played
  function getGamesPlayed() public view returns(uint256) {
    return gamesPlayed;
  }

  // Get bot balance
  function getBalance() public view returns(uint256){
    return balance;
  }

  // Get last game result
  function getLastResult() public view returns(string memory){
    return lastResult;
  }

  // Withdraw from bot
  function withdraw(uint256 amount) public {
    require(balance >= amount, "Balance too low");
    if (msg.sender == owner) {
      msg.sender.transfer(amount);
      balance -= amount;
    }
  }

  // Bet choice
  function bet(uint256 choice) public payable{
    require(choice >= 0 && choice <= 2, "Choose a valid rps");
    require(balance >= 1, "Bot balance too low");
    require(msg.value >= 1, "Bet 1 IOTX");
    balance += msg.value;
    hand playerHand = convertHand(choice);
    hand botHand = generateHand();
    result res = determineWin(botHand, playerHand);
    emitResult(res);
    distReward(res);
  }

  //Return result in string form
  function resultToString(result res) public pure returns(string memory) {
    if (res == result.WIN) {
      return "You won! :) 2 IOTX returned!";
    }
    if (res == result.LOSE) {
      return "You lose :( 0 IOTX for you";
    }
    if (res == result.TIE) {
      return "You tied! :O 1 IOTX returned!";
    }
    return "";
  }

  // Convert int to hand
  function convertHand(uint256 choice) public pure returns(hand){
    if (choice == 0) {
      return hand.ROCK;
    }
    if (choice == 1) {
      return hand.PAPER;
    }
    if (choice == 2) {
      return hand.SCISSORS;
    }
  }
  // Get a random hand
  function generateHand() public view returns(hand){
    // uint8 rand = uint8(uint256(keccak256(block.timestamp))%3 + 1);
    uint rand = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 3 + 1;
    if (rand == 0) {
      return hand.ROCK;
    }
    if (rand == 1) {
      return hand.PAPER;
    }
    if (rand == 2) {
      return hand.SCISSORS;
    }
  }

  // Emit outcome based on result for js display result
  function emitResult(result outcome) public {
    if (outcome == result.TIE) {
      emit Outcome("TIE");
      lastResult = resultToString(outcome);
    }
    if (outcome == result.WIN) {
      emit Outcome("WIN");
      lastResult = resultToString(outcome);
    }
    if (outcome == result.LOSE) {
      emit Outcome("LOSE");
      lastResult = resultToString(outcome);
    }
  }

  // Determine winning
  function determineWin(hand bot,hand player) public pure returns(result) {
    // Check tie
    if (bot == player) {
      return result.TIE;
    }
    // Check win/lose
    if (bot == hand.ROCK) {
      if (player == hand.PAPER) {
        return result.WIN;
      } else {
        return result.LOSE;
      }
    }
    if (bot == hand.PAPER) {
      if (player == hand.SCISSORS) {
        return result.WIN;
      } else {
        return result.LOSE;
      }
    }
    if (bot == hand.SCISSORS) {
      if (player == hand.ROCK) {
        return result.WIN;
      } else {
        return result.LOSE;
      }
    }
  }

  // Give off rewards based on result
  function distReward(result res) public {
    if (res == result.WIN) {
      msg.sender.transfer(2*10**18);
      balance -= 2*10**18;
    } else if (res == result.TIE) {
      msg.sender.transfer(10**18);
      balance -= 10**18;
    }
    gamesPlayed++;
  }
}