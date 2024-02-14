List<int> totalToHMS(int totalSeconds) {
  var hours = totalSeconds ~/ 3600;
  var minutes = (totalSeconds % 3600) ~/ 60;
  var seconds = totalSeconds % 60;
  return [hours, minutes, seconds];
}

int HMSToTotal(int hours, int minutes, int seconds) {
  var totalSeconds = hours * 3600 + minutes * 60 + seconds;
  return totalSeconds;
}