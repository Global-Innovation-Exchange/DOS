import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dos/utils.dart';
import '../models/emotion_log.dart';
import 'package:flutter/material.dart';

class EmotionChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final DateTime from;
  final DateTime to;

  EmotionChart(this.seriesList, {this.from, this.to, this.animate});

  // Assuming the list only contains only emotion
  factory EmotionChart.fromLogs(List<EmotionLog> logs, int year, int month,
      {bool animate = false}) {
    final dateTimes = getDateTimesOfMonth(year, month);
    return new EmotionChart(
      _createSeriesData(logs),
      // Disable animations for image tests.
      from: dateTimes[0],
      to: dateTimes[1],
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      behaviors: [
        // Set the range of the y-axis
        charts.RangeAnnotation([
          charts.RangeAnnotationSegment(
            from,
            to,
            charts.RangeAnnotationAxisType.domain,
          ),
        ]),
      ],
      // Create fixed number of y tick
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.StaticNumericTickProviderSpec([
          charts.TickSpec(1),
          charts.TickSpec(2),
          charts.TickSpec(3),
          charts.TickSpec(4),
          charts.TickSpec(5),
        ]),
      ),

      // Set x ticks to display every 2 days
      domainAxis: charts.DateTimeAxisSpec(
        tickProviderSpec: charts.DayTickProviderSpec(increments: [2]),
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<EmotionLog, DateTime>> _createSeriesData(
      List<EmotionLog> logs) {
    return [
      new charts.Series<EmotionLog, DateTime>(
        id: 'Emotion',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (EmotionLog emotion, _) => emotion.dateTime,
        measureFn: (EmotionLog emotion, _) => emotion.scale,
        data: logs,
      ),
    ];
  }
}
