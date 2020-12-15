
import 'package:equatable/equatable.dart';

///ChartDataDateRange takes two dates which must not be more than 6 days apart from each other
///where day1 is the farthest day from DateTime.now() and represented by fromDate
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