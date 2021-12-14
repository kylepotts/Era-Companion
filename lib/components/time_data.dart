import 'dart:async';

import '../era_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../screens/ble_device_details.dart';

class TimeData extends StatefulWidget {
  const TimeData({Key? key, required this.service}) : super(key: key);
  final BluetoothService service;
  @override
  State<TimeData> createState() => _TimeDataState();
}

class _TimeDataState extends State<TimeData> {
  String serviceName = "";
  BluetoothCharacteristic? timeCharacteristic;
  String time = "";
  String date = "";
  late StreamSubscription<List<int>>? sub;

  Map<String, String> parseDateTime(String dateTimeStr) {
    final split = dateTimeStr.split(":");
    final timeStr = split.getRange(split.length - 3, split.length).join(":");
    final dateStr = split.getRange(0, 3).join("/");

    return {"date": dateStr, "time": timeStr};
  }

  void getTime() async {
    final timeChars = await timeCharacteristic?.read() ?? [];
    final parsed = parseDateTime(String.fromCharCodes(timeChars));
    setState(() {
      time = parsed["time"] ?? "";
      date = parsed["date"] ?? "";
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    serviceName =
        BleDeviceDetails.knownServices[widget.service.uuid.toString()]!;
    timeCharacteristic = widget.service.characteristics.firstWhere((s) =>
        s.uuid.toString() == BleDeviceDetails.knownCharacteristics["Time"]);
    getTime();
    sub = timeCharacteristic?.value.listen((event) {
      final parsed = parseDateTime(String.fromCharCodes(event));
      setState(() {
        time = parsed["time"] ?? "";
        date = parsed["date"] ?? "";
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (InkWell(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Icon(Icons.access_time),
            ),
            Text(
              "Time and Date",
              style: EraTheme.textTheme.headline3,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(time)]),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      final timeOfDay = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (timeOfDay != null) {
                        final dateTime =
                            "${date.replaceAll("/", ":")}:${timeOfDay.hour}:${timeOfDay.minute}:00";
                        await timeCharacteristic?.write(dateTime.codeUnits);
                        getTime();
                      }
                    },
                    child: Text("Set"),
                  )
                ],
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(date)]),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final dateTime = await showDatePicker(
                          context: context,
                          initialDate: now,
                          currentDate: now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 10));
                      if (dateTime != null) {
                        final dt =
                            "${dateTime.year}:${dateTime.month}:${dateTime.day}:${time}";
                        await timeCharacteristic?.write(dt.codeUnits);
                        getTime();
                      }
                    },
                    child: Text("Set"),
                  )
                ],
              ),
            )
          ],
        ),
      ],
    )));
  }
}
