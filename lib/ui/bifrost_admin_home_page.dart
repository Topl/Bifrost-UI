import 'package:admin/constants.dart';
import 'package:admin/rpc_ops.dart';
import 'package:admin/state.dart';
import 'package:admin/ui/blockchain_state_viewer.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:topl_common/genus/services/node_grpc.dart';

class BifrostAdminHomePage extends StatefulWidget {
  const BifrostAdminHomePage({super.key, required this.title});

  final String title;

  @override
  State<BifrostAdminHomePage> createState() => _BifrostAdminHomePageState();
}

class _BifrostAdminHomePageState extends State<BifrostAdminHomePage> {
  String currentAddress = "";
  String _addressBuffer = "$rpcHost:$rpcPort";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: currentAddress.isEmpty ? _waitingForInput : _ready,
    );
  }

  Widget get _waitingForInput => Center(child: _addressBar);

  Widget get _ready {
    late String host;
    late int port;
    final portIndex = currentAddress.lastIndexOf(":");
    if (portIndex > 0) {
      host = currentAddress.substring(0, portIndex);
      port = int.parse(currentAddress.substring(portIndex + 1));
    } else {
      host = currentAddress;
      port = 9084;
    }
    final secure = host.startsWith("https");
    if (host.contains("://")) {
      host = host.substring(host.indexOf("://") + 3);
    }
    final client = NodeGRPCService(
        host: host,
        port: port,
        options: ChannelOptions(
            credentials: secure
                ? const ChannelCredentials.secure()
                : const ChannelCredentials.insecure(),
            connectionTimeout: const Duration(days: 365)));
    return SingleChildScrollView(
      child: Column(
        children: [
          _addressBar,
          StreamBuilder(
            stream: Stream.fromFuture(client.whenReady()).asyncExpand(
                (_) => BlockchainState.streamed(client, maxCacheSize, 100)),
            builder: (context, snapshot) => snapshot.hasData
                ? BlockchainStateViewer(state: snapshot.data!)
                : const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  Widget get _addressBar => SizedBox(
        height: 100,
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: TextFormField(
                decoration: const InputDecoration(
                    hintText: "host:port", border: OutlineInputBorder()),
                initialValue: _addressBuffer,
                onChanged: (text) => _addressBuffer = text,
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                currentAddress = _addressBuffer;
              }),
              icon: const Icon(Icons.send),
            )
          ],
        ),
      );
}
