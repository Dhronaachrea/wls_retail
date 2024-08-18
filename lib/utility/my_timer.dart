import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/utility/widgets/race_container.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class MyTimer extends StatefulWidget {
  final createdAt;
  final updatedAt;
  final String? pick4;

  const MyTimer({Key? key, this.createdAt, this.updatedAt, this.pick4})
      : super(key: key);

  @override
  State<MyTimer> createState() => _MyTimerState();
}

class _MyTimerState extends State<MyTimer> {
  static const duration = Duration(seconds: 1);
  DateTime drawDate = DateTime(0);
  int timeDiff = 0;
  Timer timer = Timer(duration, () {});

  DateTime? drawDateTime;
  DateTime? currentDate;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  _initTimer() async {
    try {
      timeDiff = DateTime.parse(widget.createdAt+"Z")
          .difference(DateTime.parse(DateTime.now().toUtc().toString()))
          .inSeconds;
    } catch (e) {
      log("Exception Draw Date time @ initState : $e");
    }
    // timer.cancel();
    timer = Timer.periodic(duration, (Timer t) {
      _handleTick();
    });
  }

  _handleTick() {
    if (!mounted) return;
    setState(() {
      if (timeDiff > 0) {
        if (drawDate != currentDate) {
          timeDiff = timeDiff - 1;
        }
      } else {
        timer.cancel();
        print('Times up!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int days = timeDiff ~/ (24 * 60 * 60);
    int hours = timeDiff ~/ (60 * 60) % 24;
    int minutes = (timeDiff ~/ 60) % 60;
    int seconds = timeDiff % 60;

    String strDays;
    String strHours;
    String strMinutes;
    String strSeconds;

      strDays = (days == 0) ? '' : '${days.toString().padLeft(2, '0')} ${'D'} : ';
      strHours =
          (hours == 0) ? '' : '${hours.toString().padLeft(2, '0')} ${'H'} : ';
      strMinutes = '${minutes.toString().padLeft(2, '0')} ${'M'} : ';
      strSeconds = '${seconds.toString().padLeft(2, '0')} ${'S'}';

    // strDays = (days == 0) ? '' : '${days.toString().padLeft(2, '0')} : ';
    // strHours = (hours == 0) ? '' : '${hours.toString().padLeft(2, '0')} : ';
    // strMinutes = '${minutes.toString().padLeft(2, '0')} : ';
    // strSeconds = '${seconds.toString().padLeft(2, '0')} ';

    List<String> dayTimeList = [];
    dayTimeList.add(strDays);
    dayTimeList.add(strHours);
    dayTimeList.add(strMinutes);
    dayTimeList.add(strSeconds);
    List<String> dateType = ['D', 'H', 'M', 'S'];
    return widget.pick4 != "pick"
        ? Text(
             '$strDays$strHours$strMinutes$strSeconds',
            //'$strHours$strMinutes$strSeconds',
            // "04 D : 05 H : 44 M : 22S",
            style: const TextStyle(
                color: WlsPosColor.black,
                fontWeight: FontWeight.w700,
                fontSize: 12
            ),
          ).pOnly(top: 6, bottom: 8)
        : Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: dayTimeList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return RaceContainer(dayTimeList[index], dateType[index]);
                }),
          );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
