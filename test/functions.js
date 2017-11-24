// Nov 24 2017
var ethPriceUSD = 407.7440;
var defaultGasPrice = web3.toWei(1, "gwei");

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - Wallet");
addAccount(eth.accounts[3], "Account #3");
addAccount(eth.accounts[4], "Account #4");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6");
addAccount(eth.accounts[7], "Account #7");
addAccount(eth.accounts[8], "Account #8");
addAccount(eth.accounts[9], "Account #9");


var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var wallet = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];
var account7 = eth.accounts[7];
var account8 = eth.accounts[8];
var account9 = eth.accounts[9];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length && i < accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                          Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  var block = eth.getBlock(txReceipt.blockNumber);
  console.log("RESULT: " + name + " status=" + txReceipt.status + (txReceipt.status == 0 ? " Failure" : " Success") + " gas=" + tx.gas +
    " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH + " costUSD=" + gasCostUSD +
    " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + web3.fromWei(gasPrice, "gwei") + " gwei block=" + 
    txReceipt.blockNumber + " txIx=" + tx.transactionIndex + " txId=" + txId +
    " @ " + block.timestamp + " " + new Date(block.timestamp * 1000).toUTCString());
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function failIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 0) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 1) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
// Wait until some unixTime + additional seconds
//-----------------------------------------------------------------------------
function waitUntil(message, unixTime, addSeconds) {
  var t = parseInt(unixTime) + parseInt(addSeconds) + parseInt(1);
  var time = new Date(t * 1000);
  console.log("RESULT: Waiting until '" + message + "' at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
  while ((new Date()).getTime() <= time.getTime()) {
  }
  console.log("RESULT: Waited until '" + message + "' at at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
// Wait until some block
//-----------------------------------------------------------------------------
function waitUntilBlock(message, block, addBlocks) {
  var b = parseInt(block) + parseInt(addBlocks);
  console.log("RESULT: Waiting until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
  while (eth.blockNumber <= b) {
  }
  console.log("RESULT: Waited until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
// App Sale Contract
//-----------------------------------------------------------------------------
var saleContractAddress = null;
var saleContractAbi = null;

function addSaleContractAddressAndAbi(address, tokenAbi) {
  saleContractAddress = address;
  saleContractAbi = tokenAbi;
}

var saleFromBlock = 0;

function printSaleContractDetails() {
  console.log("RESULT: saleContractAddress=" + saleContractAddress);
  if (saleContractAddress != null && saleContractAbi != null) {
    var contract = eth.contract(saleContractAbi).at(saleContractAddress);
    console.log("RESULT: sale.owner=" + contract.owner());
    console.log("RESULT: sale.newOwner=" + contract.newOwner());
    console.log("RESULT: sale.notice=" + contract.notice());
    console.log("RESULT: sale.start=" + contract.start() + " " + new Date(contract.start() * 1000).toUTCString());
    console.log("RESULT: sale.end=" + contract.end() + " " + new Date(contract.end() * 1000).toUTCString());
    console.log("RESULT: sale.cap=" + contract.cap() + " " + contract.cap().shift(-18) + " ETH");
    console.log("RESULT: sale.live=" + contract.live());

    var latestBlock = eth.blockNumber;
    var i;

    var startSaleEvents = contract.StartSale({}, { fromBlock: saleFromBlock, toBlock: latestBlock });
    i = 0;
    startSaleEvents.watch(function (error, result) {
      console.log("RESULT: StartSale " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    startSaleEvents.stopWatching();

    var endSaleEvents = contract.EndSale({}, { fromBlock: saleFromBlock, toBlock: latestBlock });
    i = 0;
    endSaleEvents.watch(function (error, result) {
      console.log("RESULT: EndSale " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    endSaleEvents.stopWatching();

    var etherInEvents = contract.EtherIn({}, { fromBlock: saleFromBlock, toBlock: latestBlock });
    i = 0;
    etherInEvents.watch(function (error, result) {
      console.log("RESULT: EtherIn " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    etherInEvents.stopWatching();

    saleFromBlock = latestBlock + 1;
  }
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 0;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  // console.log("RESULT: tokenContractAbi=" + JSON.stringify(tokenContractAbi));
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.owner=" + contract.owner());
    // NOT public console.log("RESULT: token.newOwner=" + contract.newOwner());
    console.log("RESULT: token.paused=" + contract.paused());
    console.log("RESULT: token.finalized=" + contract.finalized());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.controller=" + contract.controller());
    console.log("RESULT: token.motd=" + contract.motd());
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));

    var latestBlock = eth.blockNumber;
    var i;

    var motdEvents = contract.Motd({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    motdEvents.watch(function (error, result) {
      console.log("RESULT: Motd " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    motdEvents.stopWatching();

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " owner=" + result.args.owner +
        " spender=" + result.args.spender + " value=" + result.args.value.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": from=" + result.args.from + " to=" + result.args.to +
        " value=" + result.args.value.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// Controller Contract
// -----------------------------------------------------------------------------
var controllerContractAddress = null;
var controllerContractAbi = null;

function addControllerContractAddressAndAbi(address, controllerAbi) {
  controllerContractAddress = address;
  controllerContractAbi = controllerAbi;
}

//-----------------------------------------------------------------------------
// Controller Contract
//-----------------------------------------------------------------------------
function printControllerContractDetails() {
  console.log("RESULT: controllerContractAddress=" + controllerContractAddress);
  // console.log("RESULT: controllerContractAbi=" + JSON.stringify(controllerContractAbi));
  if (controllerContractAddress != null && controllerContractAbi != null) {
    var contract = eth.contract(controllerContractAbi).at(controllerContractAddress);
    console.log("RESULT: controller.owner=" + contract.owner());
    console.log("RESULT: controller.finalized=" + contract.finalized());
    console.log("RESULT: controller.ledger=" + contract.ledger());
    console.log("RESULT: controller.token=" + contract.token());
  }
}


// -----------------------------------------------------------------------------
// Ledger Contract
// -----------------------------------------------------------------------------
var ledgerContractAddress = null;
var ledgerContractAbi = null;

function addLedgerContractAddressAndAbi(address, ledgerAbi) {
  ledgerContractAddress = address;
  ledgerContractAbi = ledgerAbi;
}

//-----------------------------------------------------------------------------
// Ledger Contract
//-----------------------------------------------------------------------------
function printLedgerContractDetails() {
  console.log("RESULT: ledgerContractAddress=" + ledgerContractAddress);
  // console.log("RESULT: ledgerContractAbi=" + JSON.stringify(ledgerContractAbi));
  if (ledgerContractAddress != null && ledgerContractAbi != null) {
    var contract = eth.contract(ledgerContractAbi).at(ledgerContractAddress);
    console.log("RESULT: ledger.owner=" + contract.owner());
    console.log("RESULT: ledger.finalized=" + contract.finalized());
    console.log("RESULT: ledger.controller=" + contract.controller());
    console.log("RESULT: ledger.totalSupply=" + contract.totalSupply());
    console.log("RESULT: ledger.mintingNonce=" + contract.mintingNonce());
    console.log("RESULT: ledger.mintingStopped=" + contract.mintingStopped());
  }
}