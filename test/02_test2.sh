#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

TOKENSOL=`grep ^TOKENSOL= settings.txt | sed "s/^.*=//"`
TOKENJS=`grep ^TOKENJS= settings.txt | sed "s/^.*=//"`
SALESOL=`grep ^SALESOL= settings.txt | sed "s/^.*=//"`
SALEJS=`grep ^SALEJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST2OUTPUT=`grep ^TEST2OUTPUT= settings.txt | sed "s/^.*=//"`
TEST2RESULTS=`grep ^TEST2RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

BLOCKSINDAY=10

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+60" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60+30" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE            = '$MODE'\n" | tee $TEST2OUTPUT
printf "GETHATTACHPOINT = '$GETHATTACHPOINT'\n" | tee -a $TEST2OUTPUT
printf "PASSWORD        = '$PASSWORD'\n" | tee -a $TEST2OUTPUT
printf "SOURCEDIR       = '$SOURCEDIR'\n" | tee -a $TEST2OUTPUT
printf "TOKENSOL        = '$TOKENSOL'\n" | tee -a $TEST2OUTPUT
printf "TOKENJS         = '$TOKENJS'\n" | tee -a $TEST2OUTPUT
printf "SALESOL         = '$SALESOL'\n" | tee -a $TEST2OUTPUT
printf "SALEJS          = '$SALEJS'\n" | tee -a $TEST2OUTPUT
printf "DEPLOYMENTDATA  = '$DEPLOYMENTDATA'\n" | tee -a $TEST2OUTPUT
printf "INCLUDEJS       = '$INCLUDEJS'\n" | tee -a $TEST2OUTPUT
printf "TEST2OUTPUT     = '$TEST2OUTPUT'\n" | tee -a $TEST2OUTPUT
printf "TEST2RESULTS    = '$TEST2RESULTS'\n" | tee -a $TEST2OUTPUT
printf "CURRENTTIME     = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST2OUTPUT
printf "STARTTIME       = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST2OUTPUT
printf "ENDTIME         = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST2OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/$TOKENSOL .`
`cp $SOURCEDIR/$SALESOL .`

# --- Modify parameters ---
# `perl -pi -e "s/bool transferable/bool public transferable/" $TOKENSOL`
# `perl -pi -e "s/MULTISIG_WALLET_ADDRESS \= 0xc79ab28c5c03f1e7fbef056167364e6782f9ff4f;/MULTISIG_WALLET_ADDRESS \= 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976;/" GimliCrowdsale.sol`
# `perl -pi -e "s/START_DATE = 1505736000;.*$/START_DATE \= $STARTTIME; \/\/ $STARTTIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/END_DATE = 1508500800;.*$/END_DATE \= $ENDTIME; \/\/ $ENDTIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/VESTING_1_DATE = 1537272000;.*$/VESTING_1_DATE \= $VESTING1TIME; \/\/ $VESTING1TIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/VESTING_2_DATE = 1568808000;.*$/VESTING_2_DATE \= $VESTING2TIME; \/\/ $VESTING2TIME_S/" GimliCrowdsale.sol`

DIFFS1=`diff $SOURCEDIR/$TOKENSOL $TOKENSOL`
echo "--- Differences $SOURCEDIR/$TOKENSOL $TOKENSOL ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

DIFFS1=`diff $SOURCEDIR/$SALESOL $SALESOL`
echo "--- Differences $SOURCEDIR/$SALESOL $SALESOL ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

solc_0.4.16 --version | tee -a $TEST2OUTPUT

echo "var tokenOutput=`solc_0.4.16 --optimize --combined-json abi,bin,interface $TOKENSOL`;" > $TOKENJS
echo "var saleOutput=`solc_0.4.16 --optimize --combined-json abi,bin,interface $SALESOL`;" > $SALEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST2OUTPUT
loadScript("$TOKENJS");
loadScript("$SALEJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["$TOKENSOL:Token"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$TOKENSOL:Token"].bin;
var controllerAbi = JSON.parse(tokenOutput.contracts["$TOKENSOL:Controller"].abi);
var controllerBin = "0x" + tokenOutput.contracts["$TOKENSOL:Controller"].bin;
var ledgerAbi = JSON.parse(tokenOutput.contracts["$TOKENSOL:Ledger"].abi);
var ledgerBin = "0x" + tokenOutput.contracts["$TOKENSOL:Ledger"].bin;
var saleAbi = JSON.parse(saleOutput.contracts["$SALESOL:Sale"].abi);
var saleBin = "0x" + saleOutput.contracts["$SALESOL:Sale"].bin;

// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));
// console.log("DATA: controllerAbi=" + JSON.stringify(controllerAbi));
// console.log("DATA: controllerBin=" + JSON.stringify(controllerBin));
// console.log("DATA: ledgerAbi=" + JSON.stringify(ledgerAbi));
// console.log("DATA: ledgerBin=" + JSON.stringify(ledgerBin));
// console.log("DATA: saleAbi=" + JSON.stringify(saleAbi));
// console.log("DATA: saleBin=" + JSON.stringify(saleBin));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployMessage = "Deploy Contracts";
// -----------------------------------------------------------------------------
console.log("RESULT: " + deployMessage);

var tokenContract = web3.eth.contract(tokenAbi);
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);

var controllerContract = web3.eth.contract(controllerAbi);
var controllerTx = null;
var controllerAddress = null;
var controller = controllerContract.new({from: contractOwnerAccount, data: controllerBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        controllerTx = contract.transactionHash;
      } else {
        controllerAddress = contract.address;
        addAccount(controllerAddress, "Controller");
        addControllerContractAddressAndAbi(controllerAddress, controllerAbi);
        console.log("DATA: controllerAddress=" + controllerAddress);
      }
    }
  }
);

var ledgerContract = web3.eth.contract(ledgerAbi);
var ledgerTx = null;
var ledgerAddress = null;
var ledger = ledgerContract.new({from: contractOwnerAccount, data: ledgerBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        ledgerTx = contract.transactionHash;
      } else {
        ledgerAddress = contract.address;
        addAccount(ledgerAddress, "Ledger");
        addLedgerContractAddressAndAbi(ledgerAddress, ledgerAbi);
        console.log("DATA: ledgerAddress=" + ledgerAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printBalances();
printTxData("tokenAddress=" + tokenAddress, tokenTx);
printTxData("controllerAddress=" + controllerAddress, controllerTx);
printTxData("ledgerAddress=" + ledgerAddress, ledgerTx);
failIfTxStatusError(tokenTx, deployMessage);
failIfTxStatusError(controllerTx, deployMessage);
failIfTxStatusError(ledgerTx, deployMessage);
printTokenContractDetails();
printControllerContractDetails();
printLedgerContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var stitchMessage = "Init Sale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + stitchMessage);
var stitch1Tx = token.setController(controllerAddress, {from: contractOwnerAccount, gas: 500000, gasPrice: defaultGasPrice});
var stitch2Tx = controller.setToken(tokenAddress, {from: contractOwnerAccount, gas: 500000, gasPrice: defaultGasPrice});
var stitch3Tx = controller.setLedger(ledgerAddress, {from: contractOwnerAccount, gas: 500000, gasPrice: defaultGasPrice});
var stitch4Tx = ledger.setController(controllerAddress, {from: contractOwnerAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("stitch1Tx", stitch1Tx);
printTxData("stitch2Tx", stitch2Tx);
printTxData("stitch3Tx", stitch3Tx);
printTxData("stitch4Tx", stitch4Tx);
failIfTxStatusError(stitch1Tx, stitchMessage + " - token.setController(controller)");
failIfTxStatusError(stitch2Tx, stitchMessage + " - controller.setToken(token)");
failIfTxStatusError(stitch3Tx, stitchMessage + " - controller.setLedger(ledger)");
failIfTxStatusError(stitch4Tx, stitchMessage + " - ledger.setController(controller)");
printTokenContractDetails();
printControllerContractDetails();
printLedgerContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mintMessage = "Mint Tokens";
var v1 = account3 + "0000000001b69b4ba630f34e";
var v2 = account4 + "0000000001b69b4ba630f34e";
// > new BigNumber("123456789012345678").toString(16)
// "1b69b4ba630f34e"
// -----------------------------------------------------------------------------
console.log("RESULT: " + mintMessage);
var mint1Tx = ledger.multiMint(0, [v1, v2], {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("mint1Tx", mint1Tx);
failIfTxStatusError(mint1Tx, mintMessage + " - ac3 + ac4 1234567890.12345678 tokens");
printTokenContractDetails();
printControllerContractDetails();
printLedgerContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mintingStoppedMessage = "Minting Stopped";
// -----------------------------------------------------------------------------
console.log("RESULT: " + mintingStoppedMessage);
var mintingStopped1Tx = ledger.stopMinting({from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("mintingStopped1Tx", mintingStopped1Tx);
failIfTxStatusError(mintingStopped1Tx, mintingStoppedMessage);
printTokenContractDetails();
printControllerContractDetails();
printLedgerContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transferMessage = "Transfer Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + transferMessage);
var transfer1Tx = token.transfer(account6, "100", {from: account3, gas: 100000});
var transfer2Tx = token.approve(account5,  "3000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var transfer3Tx = token.transferFrom(account4, account7, "3000000", {from: account5, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("transfer1Tx", transfer1Tx);
printTxData("transfer2Tx", transfer2Tx);
printTxData("transfer3Tx", transfer3Tx);
failIfTxStatusError(transfer1Tx, transferMessage + " - transfer 0.000001 tokens ac3 -> ac6. CHECK for movement");
failIfTxStatusError(transfer2Tx, transferMessage + " - approve 0.03 tokens ac4 -> ac5");
failIfTxStatusError(transfer3Tx, transferMessage + " - transferFrom 0.03 tokens ac4 -> ac7 by ac5. CHECK for movement");
printTokenContractDetails();
printControllerContractDetails();
printLedgerContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var invalidTransferMessage = "Invalid Transfers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + invalidTransferMessage);
var invalidTransfer1Tx = token.transfer(account7, "100", {from: account5, gas: 100000});
var invalidTransfer2Tx = token.approve(account8,  "3000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
var invalidTransfer3Tx = token.transferFrom(account6, account9, "3000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("invalidTransfer1Tx", invalidTransfer1Tx);
printTxData("invalidTransfer2Tx", invalidTransfer2Tx);
printTxData("invalidTransfer3Tx", invalidTransfer3Tx);
failIfTxStatusError(invalidTransfer1Tx, invalidTransferMessage + " - invalid transfer 0.000001 tokens ac5 -> ac7. CHECK for NO movement");
failIfTxStatusError(invalidTransfer2Tx, invalidTransferMessage + " - approve 0.03 tokens ac6 -> ac8");
failIfTxStatusError(invalidTransfer3Tx, invalidTransferMessage + " - invalid transferFrom 0.03 tokens ac6 -> ac9 by ac8. CHECK for NO movement");
printTokenContractDetails();
printControllerContractDetails();
printLedgerContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var zeroTransferMessage = "Zero Transfers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + zeroTransferMessage);
var zeroTransfer1Tx = token.transfer(account7, "0", {from: account5, gas: 100000});
var zeroTransfer2Tx = token.approve(account8,  "0", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
var zeroTransfer3Tx = token.transferFrom(account6, account9, "0", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("zeroTransfer1Tx", zeroTransfer1Tx);
printTxData("zeroTransfer2Tx", zeroTransfer2Tx);
printTxData("zeroTransfer3Tx", zeroTransfer3Tx);
failIfTxStatusError(zeroTransfer1Tx, zeroTransferMessage + " - transfer 0 tokens ac3 -> ac6. CHECK for NO movement");
failIfTxStatusError(zeroTransfer2Tx, zeroTransferMessage + " - approve 0 tokens ac4 -> ac5");
failIfTxStatusError(zeroTransfer3Tx, zeroTransferMessage + " - zeroTransferFrom 0 tokens ac4 -> ac7 by ac5. CHECK for NO movement");
printTokenContractDetails();
printControllerContractDetails();
printLedgerContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST2OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST2OUTPUT | sed "s/RESULT: //" > $TEST2RESULTS
cat $TEST2RESULTS
