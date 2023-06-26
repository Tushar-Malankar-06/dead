import 'package:intl/intl.dart';
import 'package:worldtime/worldtime.dart';

class getTime {
  Future<String> setup(bool dt) async {
    final _worldtimePlugin = Worldtime();
    final String myFormatter;
    if (dt == true) {
      myFormatter = '\\D/\\M/\\Y';
    } else {
      myFormatter = '\\h:\\m';
    }

    final DateTime timeAmsterdamTZ =
        await _worldtimePlugin.timeByCity('Asia/Calcutta');

    final DateTime timeAmsterdamGeo = await _worldtimePlugin.timeByLocation(
        latitude: 52.3676, longitude: 4.9041);

    final String resultTZ = _worldtimePlugin.format(
        dateTime: timeAmsterdamTZ, formatter: myFormatter);

    final String resultGeo = _worldtimePlugin.format(
        dateTime: timeAmsterdamGeo, formatter: myFormatter);

    return resultTZ;
  }

  String convertToDateTimeFormat(String date) {
    final List<String> dateParts = date.split('/');
    final String year = dateParts[2];
    final String month = dateParts[1].padLeft(2, '0');
    final String day = dateParts[0].padLeft(2, '0');
    return '$year-$month-$day';
  }
}
