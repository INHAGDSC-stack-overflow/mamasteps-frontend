void totalToHMS(int hours, int minutes, int seconds, int totalSeconds) {
  hours = totalSeconds ~/ 3600;
  minutes = (totalSeconds % 3600) ~/ 60;
  seconds = totalSeconds % 60;
}

void HMSToTotal(int hours, int minutes, int seconds, int totalSeconds) {
  var totalSeconds = hours * 3600 + minutes * 60 + seconds;
  totalSeconds = totalSeconds;
}