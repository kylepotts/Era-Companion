import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../screens/ble_device_details.dart';

class BleDeviceCard extends StatefulWidget {
  const BleDeviceCard(
      {Key? key,
      required this.device,
      required this.onConnect,
      required this.onDisconnect})
      : super(key: key);

  final BluetoothDevice device;
  final Future<void> Function(BluetoothDevice device) onConnect;
  final Future<void> Function(BluetoothDevice device) onDisconnect;
  @override
  State<BleDeviceCard> createState() => _BleDeviceCardState();
}

class _BleDeviceCardState extends State<BleDeviceCard> {
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  late StreamSubscription sub;

  setDeviceState(BluetoothDeviceState state) {
    setState(() {
      deviceState = state;
    });
  }

  String deviceStateText(BluetoothDeviceState state) {
    switch (state) {
      case BluetoothDeviceState.connected:
        {
          return "Connected";
        }
      case BluetoothDeviceState.disconnected:
        {
          return "Disconnected";
        }
      default:
        {
          return "Unknown State";
        }
    }
  }

  @override
  void initState() {
    sub = widget.device.state.listen((event) {
      setDeviceState(event);
    });
    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return BleDeviceDetails(
                      device: widget.device,
                      deviceState: deviceState,
                    );
                  },
                ));
              },
              child: Column(
                children: <Widget>[
                  Text(widget.device.name == ''
                      ? '(unknown device)'
                      : widget.device.name),
                  Text(widget.device.id.toString()),
                ],
              ),
            ),
          ),
          Text(deviceStateText(deviceState)),
          TextButton(
            child: Text(
              deviceState == BluetoothDeviceState.disconnected
                  ? 'Connect'
                  : 'Disconnect',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () async {
              if (deviceState == BluetoothDeviceState.connected) {
                await widget.onDisconnect(widget.device);
              } else if (deviceState == BluetoothDeviceState.disconnected) {
                await widget.onConnect(widget.device);
              }
            },
          ),
        ],
      ),
    );
  }
}
