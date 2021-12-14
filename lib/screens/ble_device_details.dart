import 'dart:async';

import '../era_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../components/time_data.dart';

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

class BleDeviceDetails extends StatefulWidget {
  BleDeviceDetails({Key? key, required this.device, required this.deviceState})
      : super(key: key);
  final BluetoothDevice device;
  static const knownServices = {
    "86b12865-4b70-4893-8ce6-9864fc00374d": "Time Service"
  };
  static const knownCharacteristics = {
    "Time": "38c15f3d-7b83-42b1-9275-0b10ea4baeaf"
  };
  BluetoothDeviceState deviceState;
  @override
  State<BleDeviceDetails> createState() => _BleDeviceDetailsState();
}

class _BleDeviceDetailsState extends State<BleDeviceDetails> {
  Map<String, BluetoothService> services = {};
  final serviceUUID = "86b12865-4b70-4893-8ce6-9864fc00374d";
  static const knownServices = {
    "86b12865-4b70-4893-8ce6-9864fc00374d": "Time Service"
  };
  static const knownCharacteristics = {
    "Time": "38c15f3d-7b83-42b1-9275-0b10ea4baeaf"
  };
  BluetoothService? service;
  StreamSubscription<List<BluetoothService>>? sub;

  void setServices(List<BluetoothService> bleServices) {
    setState(() {
      for (var element in bleServices) {
        if (!services.containsKey(element.uuid.toString()) &&
            knownServices.containsKey(element.uuid.toString())) {
          services[element.uuid.toString()] = element;
        }
      }
    });
  }

  void discover() async {
    final f = await widget.device.discoverServices();
    setServices(f);
  }

  @override
  void initState() {
    if (widget.deviceState == BluetoothDeviceState.connected) {
      discover();
      final s = widget.device.services.listen((event) {
        setServices(event);
      });
      setState(() {
        sub = s;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(title: Text("Device Settings")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/watchy_single.png"),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    widget.device.name,
                    style: EraTheme.textTheme.headline2,
                  ),
                )
              ],
            ),
          ),
          Expanded(child: _buildServiceList())
        ],
      ),
    ));
  }

  Widget _buildServiceList() {
    return (ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        String key = services.keys.elementAt(index);
        final service = services[key]!;
        return (_buildServiceCard(service));
      },
    ));
  }

  Widget _buildServiceCard(BluetoothService service) {
    final serviceName = knownServices[service.uuid.toString()]!;
    Widget? serviceWidget;
    switch (serviceName) {
      case "Time Service":
        {
          serviceWidget = TimeData(service: service);
          break;
        }
      default:
        {
          serviceWidget = null;
        }
    }
    return SizedBox(
      height: 150,
      child: (Card(
        elevation: 6.0,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: serviceWidget,
        ),
      )),
    );
  }
}
