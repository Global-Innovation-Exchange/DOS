import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/emotion_log.dart';
import '../utils.dart';

class EmotionChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final DateTime from;
  final DateTime to;

  EmotionChart(this.seriesList, {this.from, this.to, this.animate});

  // Assuming the list only contains only emotion
  factory EmotionChart.fromLogs(List<EmotionLog> logs, int year, int month,
      {bool animate = true}) {
    final dateTimes = getDateTimesOfMonth(year, month);
    return new EmotionChart(
      _createSeriesData(logs),
      // Disable animations for image tests.
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(seriesList,
        animate: animate,
        vertical: false,
        primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec: charts.StaticNumericTickProviderSpec([
            charts.TickSpec(0),
            charts.TickSpec(1),
            charts.TickSpec(2),
            charts.TickSpec(3),
            charts.TickSpec(4),
            charts.TickSpec(5),
          ]),
        ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<EmotionLog, String>> _createSeriesData(
      List<EmotionLog> logs) {
    return [
      new charts.Series<EmotionLog, String>(
        id: 'Emotion',
        colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
        domainFn: (EmotionLog emotion, _) =>
            DateFormat('dd (KK:mm a)').format(emotion.dateTime).toString(),
        measureFn: (EmotionLog emotion, _) => emotion.scale,
        data: logs,
      ),
    ];
  }
}
