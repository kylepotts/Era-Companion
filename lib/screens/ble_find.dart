import 'dart:async';

import '../era_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../components/ble_device_card.dart';
import 'package:async/async.dart' show StreamGroup;

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

class BleFind extends StatefulWidget {
  @override
  State<BleFind> createState() => _BleFindState();
}

class _BleFindState extends State<BleFind> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final String BLE_DEVICE_NAME = "Fetty BLE";
  List<BluetoothDevice> devices = <BluetoothDevice>[];
  late StreamSubscription<List<ScanResult>>? sub;
  late StreamSubscription<bool>? isScanningSub;

  bool connectedLoaded = false;
  bool isScanning = false;

  void setDevices(List<BluetoothDevice> bl_devices) {
    setState(() {
      devices.addAll(bl_devices);
      devices = devices
          .where((element) => element.name == BLE_DEVICE_NAME)
          .toList()
          .unique((e) => e.id);
    });
  }

  void loadConnected() async {
    setState(() {
      connectedLoaded = false;
    });
    final devices = await flutterBlue.connectedDevices;
    setState(() {
      connectedLoaded = true;
    });
    setDevices(devices);
  }

  @override
  void initState() {
    super.initState();
    loadConnected();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 10));
    final s = flutterBlue.scanResults.listen((event) {
      setDevices(event.map((e) => e.device).toList());
    });
    final s2 = flutterBlue.isScanning.listen((event) {
      setState(() {
        isScanning = event;
      });
    });
    setState(() {
      sub = s;
      isScanningSub = s2;
    });
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    sub?.cancel();
    isScanningSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                await flutterBlue.stopScan();
                startScan();
                loadConnected();
                setState(() {
                  devices = [];
                });
              },
              icon: Icon(Icons.refresh),
            )
          ],
          title: Text("Devices"),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isScanning)
                Text(
                  "Scanning for your watch...",
                  style: EraTheme.textTheme.headline2,
                ),
              SizedBox(height: 20),
              Expanded(child: _buildListViewOfDevices())
            ],
          ),
        ));
  }

  Widget _buildListViewOfDevices() {
    if (devices.isEmpty && (!isScanning)) {
      return (Center(
        child: Text("No devices found, try scanning again."),
      ));
    } else {
      return ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return (BleDeviceCard(
            device: devices[index],
            onDisconnect: (device) async {
              flutterBlue.stopScan();
              await device.disconnect();
            },
            onConnect: (device) async {
              flutterBlue.stopScan();
              try {
                print("connecting to device");
                await device.connect();
                print("connected to device");
              } catch (e) {
                if (e is PlatformException && e.code != 'already_connected') {
                  rethrow;
                }
              } finally {}
            },
          ));
        },
      );
    }
  }
}
