
import 'package:equatable/equatable.dart';

///ChartDateRange was extracted out of ChartData so that ChartData can contain the data it contains now
///and also that date range may be separated from the chartData
class ChartDataDateRange extends Equatable{
  final DateTime fromDate;
  final DateTime toDate;

  ///if values are not passed for ChartDataDateRange.fromDate and ChartDataDateRange.toDate, then the default values are used
  ///toDate = today's date
  ///fromDate = last six day's date
  ChartDataDateRange ({this.fromDate, this.toDate});

  @override
  String toString() {
    return "fromDate: $fromDate \ntoDate: $toDate";
  }

  @override
  List<Object> get props => [fromDate, toDate];
}