import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/map/component/timer/convert.dart';

class countDownTimer extends StatefulWidget {
  final totalSeconds;
  final VoidCallback showStopDialog;

  const countDownTimer({
    super.key,
    required this.totalSeconds,
    required this.showStopDialog,
  });

  @override
  _countDownTimerState createState() => _countDownTimerState();
}

class _countDownTimerState extends State<countDownTimer> {
  late Duration duration;
  late int hour;
  late int minute;
  late int second;
  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    initTimer();
    totalToHMS(widget.totalSeconds);
  }

  void initTimer() {
    duration = Duration(hours: hour, minutes: minute, seconds: second);
  }

  void startTimer() {
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (duration.inSeconds > 0) {
          setState(() {
            duration = duration - Duration(seconds: 1);
            isRunning = true;
          });
        } else {
          timer?.cancel();
          setState(() {
            isRunning = false;
          });
        }
      });
    }
  }

  void pauseTimer() {
    if (timer != null && timer!.isActive) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
    }
  }

  void resetTimer() {
    if (timer != null) {
      timer?.cancel();
    }
    setState(() {
      duration = Duration(
          hours: hour, minutes: minute, seconds: second); // 초기 시간으로 재설정
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(
            child: Container(
              child: Column(
                children: [
                  Align(
                    child: Text('소요 시간'),
                    alignment: Alignment.topLeft,
                  ),
                  Card(
                    child: Center(
                      child: Text('$hours:$minutes:$seconds',
                          style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              (isRunning)
                  ? IconButton(
                      onPressed: pauseTimer,
                      icon: Icon(Icons.pause),
                    )
                  : IconButton(
                      onPressed: startTimer,
                      icon: Icon(Icons.play_arrow),
                    ),
              IconButton(
                onPressed: widget.showStopDialog,
                icon: Icon(Icons.stop),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
