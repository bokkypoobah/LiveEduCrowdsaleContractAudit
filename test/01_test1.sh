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
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

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

printf "MODE            = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD        = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR       = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "TOKENSOL        = '$TOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "TOKENJS         = '$TOKENJS'\n" | tee -a $TEST1OUTPUT
printf "SALESOL         = '$SALESOL'\n" | tee -a $TEST1OUTPUT
printf "SALEJS          = '$SALEJS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA  = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS       = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT     = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS    = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME     = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "STARTTIME       = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST1OUTPUT
printf "ENDTIME         = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST1OUTPUT

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
echo "--- Differences $SOURCEDIR/$TOKENSOL $TOKENSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$SALESOL $SALESOL`
echo "--- Differences $SOURCEDIR/$SALESOL $SALESOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.4.16 --version | tee -a $TEST1OUTPUT

echo "var tokenOutput=`solc_0.4.16 --optimize --combined-json abi,bin,interface $TOKENSOL`;" > $TOKENJS
echo "var saleOutput=`solc_0.4.16 --optimize --combined-json abi,bin,interface $SALESOL`;" > $SALEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
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
var deploySaleMessage = "Deploy Sale Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + deploySaleMessage);
var saleContract = web3.eth.contract(saleAbi);
var saleTx = null;
var saleAddress = null;

var sale = saleContract.new({from: contractOwnerAccount, data: saleBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        saleTx = contract.transactionHash;
      } else {
        saleAddress = contract.address;
        addAccount(saleAddress, "Sale");
        addSaleContractAddressAndAbi(saleAddress, saleAbi);
        console.log("DATA: saleAddress=" + saleAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("saleAddress=" + saleAddress, saleTx);
printBalances();
failIfTxStatusError(saleTx, deploySaleMessage);
printSaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var contribute1Message = "Contribute Before Sale init()-ed";
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribute1Message);
var contribute1Tx = eth.sendTransaction({from: account3, to: saleAddress, value: web3.toWei(1, "ether"), gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("contribute1Tx", contribute1Tx);
printBalances();
passIfTxStatusError(contribute1Tx, contribute1Message + " - Expecting failure");
printSaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var initSaleMessage = "Init Sale";
var cap = web3.toWei(100, "ether");
// -----------------------------------------------------------------------------
console.log("RESULT: " + initSaleMessage);
var initSale1Tx = sale.init($STARTTIME, $ENDTIME, cap, {from: contractOwnerAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("initSale1Tx", initSale1Tx);
printBalances();
failIfTxStatusError(initSale1Tx, initSaleMessage);
printSaleContractDetails();
console.log("RESULT: ");


waitUntil("Start", $STARTTIME, 0);


// -----------------------------------------------------------------------------
var contribute2Message = "Contribute After Sale Start";
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribute2Message);
var contribute2_1Tx = eth.sendTransaction({from: account3, to: saleAddress, value: web3.toWei(10, "ether"), gas: 500000, gasPrice: defaultGasPrice});
var contribute2_2Tx = eth.sendTransaction({from: account4, to: saleAddress, value: web3.toWei(10, "ether"), gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("contribute2_1Tx", contribute2_1Tx);
printTxData("contribute2_2Tx", contribute2_2Tx);
printBalances();
failIfTxStatusError(contribute2_1Tx, contribute2Message + " - ac3 10 ETH");
failIfTxStatusError(contribute2_2Tx, contribute2Message + " - ac4 10 ETH");
printSaleContractDetails();
console.log("RESULT: ");


waitUntil("End", $ENDTIME, 0);


// -----------------------------------------------------------------------------
var contribute3Message = "Contribute After Sale Ended";
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribute3Message);
var contribute3_1Tx = eth.sendTransaction({from: account3, to: saleAddress, value: web3.toWei(10000, "ether"), gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var contribute3_2Tx = eth.sendTransaction({from: account4, to: saleAddress, value: web3.toWei(10000, "ether"), gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("contribute3_1Tx", contribute3_1Tx);
printTxData("contribute3_2Tx", contribute3_2Tx);
printBalances();
failIfTxStatusError(contribute3_1Tx, contribute3Message + " - ac3 10,000 ETH - NOTE that this contribution should not have been accepted as it is over the cap and after the end");
passIfTxStatusError(contribute3_2Tx, contribute3Message + " - ac4 10,000 ETH - Expecting failure");
printSaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var withdrawMessage = "Withdraw";
// -----------------------------------------------------------------------------
console.log("RESULT: " + withdrawMessage);
var withdraw1Tx = sale.withdraw({from: contractOwnerAccount, gas: 500000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printTxData("withdraw1Tx", withdraw1Tx);
printBalances();
failIfTxStatusError(withdraw1Tx, withdrawMessage);
printSaleContractDetails();
console.log("RESULT: ");

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
