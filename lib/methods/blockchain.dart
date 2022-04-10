import 'package:dialog_context/dialog_context.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

Future<DeployedContract> loadContract() async {
  String abi = await rootBundle.loadString("assets/abi.json");
  String contractAddress = "0x6A1578Bf4FE2514BE9A2B81D87566c0E86BC493D";
  final contract = DeployedContract(
      ContractAbi.fromJson(abi, "SharedOwnership"),
      EthereumAddress.fromHex(contractAddress));
  return contract;
}

Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
  Client httpClient;
  Web3Client ethClient;
  httpClient = Client();
  ethClient = Web3Client(
      'https://rinkeby.infura.io/v3/1a47048363ec47db96388454619239fe',
      httpClient);
  final contract = await loadContract();
  final ethFunction = contract.function(functionName);
  final result = await ethClient.call(
      contract: contract, function: ethFunction, params: args);
  return result;
}

Future<String> submit(
    String functionName, List<dynamic> args, BuildContext context) async {
  Client httpClient;
  Web3Client ethClient;
  httpClient = Client();
  ethClient = Web3Client(
      'https://rinkeby.infura.io/v3/79a71b288cea4e2ea6e41389d8c7b46f',
      httpClient);
  EthPrivateKey credential = EthPrivateKey.fromHex(
      "2d0b3dd23b10339a1791f4cdc82602029db757c031191bef9b0652474892a2b7");
  DeployedContract contract = await loadContract();
  final ethFunction = contract.function(functionName);
  final result = await ethClient.sendTransaction(
    credential,
    Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
        maxGas: 1000000,
        gasPrice: EtherAmount.inWei(BigInt.from(10000000000))),
    fetchChainIdFromNetworkId: true,
  );
  Flushbar flush;
  Flushbar<bool>(
    title: "Hey Ninja",
    message:
        "A transaction happened on blockchain, Do you want to see its details?",
    icon: Icon(
      Icons.info_outline,
      color: Colors.blue,
    ),
    mainButton: FlatButton(
      onPressed: () {
        flush.dismiss(true); // result = true
      },
      child: Text(
        "Check details",
        style: TextStyle(color: Colors.amber),
      ),
    ),
  ) // <bool> is the type of the result passed to dismiss() and collected by show().then((result){})
    ..show(context).then((result) {
      if (result) {}
    });
  DialogContext().showSnackBar(
      snackBar: SnackBar(
    content: Text('A transaction happened on blockchain.'),
    duration: Duration(seconds: 10),
    action: SnackBarAction(
        label: 'Show Transaction details',
        onPressed: () {
          launch('https://rinkeby.etherscan.io/tx/$result');
        }),
  ));
  print(result);
  return result;
}
