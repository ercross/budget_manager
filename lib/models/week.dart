import 'package:flutter/material.dart';


class Year {
  final int value;
  final bool isLeapYear;
  final int numberOfDays;

  const Year (this.value)
    : isLeapYear = value % 4 == 0, 
      numberOfDays = value % 4 == 0 ? 366 : 365;
}


class Week{

  ///@number is the week number
  final int number; 

  ///starts denotes the date on which this week starts.
  ///starts is formatted as DateTime(year, month, day), devoid of minutes, hours and the likes
  ///each week must start on Monday
  final DateTime starts; 

  ///ends represents the date on which this week ends.
  ///ends is formatted as DateTime(year, month, day), devoid of minutes, hours and the likes
  ///each week must end on Sunday
  final DateTime ends;

  const Week({this.number, this.starts, this.ends});

  String toString() => "week number: $number \nstarts on: $starts \n ends on: $ends\n";
}

class Weeks {
  final Year inYear;
  final int totalNumberOfWeeks;
  Weeks({@required this.inYear})

          //Number of weeks in a year could be 52 or 53, depending on some factors.
          //Most years have 52 weeks, but if the year starts on a Thursday or is a leap year that starts on a Wednesday, 
          //that particular year will have 53 weeks. 
          : totalNumberOfWeeks = 
            (DateTime(inYear.value, 1, 1).weekday == 4 || inYear.isLeapYear && DateTime(inYear.value, 1, 1).weekday == 4) 
              ? 53 
              : 52;

  ///The first week of the year is the year that contains the first Thursday in the year
  ///the return value.weekday must be == 1
  DateTime _calcFirstWeekStartDate() {
    final DateTime firstDayOfTheYear = DateTime(inYear.value, 1, 1);
    final int fdNum = firstDayOfTheYear.weekday;

    //if first day of the year is monday, then firstDayOfTheYear denotes this.year firstWeekStartDate
    if (fdNum == 1) return firstDayOfTheYear;

    //if first day of the year is after Thursday, count 8-fdNum days forward to get the first Monday of the year
    //And this first monday of the year denotes the start of the first week of this.year
    if (fdNum > 4) return firstDayOfTheYear.add(Duration(days: 8-fdNum));

    //if first day of the year is before Thursday, count fdNum-1 days backwards to get the last Monday of the previous year
    //And this last monday of the previous year denotes the start of the first week of this.year
    if (fdNum > 1 && fdNum < 4) return DateTime(this.inYear.value-1, 1, 1).subtract(Duration(days: fdNum - 1));

    //if firstDayOfTheYear is Thursday, then counting three days backwards yields the last Monday in the previous year
    //And this last Monday of the previous year denotes the start of the first week of this.year
    return firstDayOfTheYear.subtract(Duration(days: 3));
  }

  List<Week> calculateWeeks () {
    List<Week> weeks = List<Week>();
    DateTime weekStarts = _calcFirstWeekStartDate();
    DateTime weekEnds;
    for(int i = 0; i<totalNumberOfWeeks; i++) {
       weekEnds = weekStarts.add(Duration(days: 6));
       weeks.add(Week(number: i+1, starts: weekStarts, ends: weekEnds));
       weekStarts = weekEnds.add(Duration(days:1));
    }
    return weeks;
  }

  ///getWeekByNumber returns the Week data type whose week.number == @weekNumber
  Week getWeekByNumber(int weekNumber) {
    final List<Week> weeks = calculateWeeks();
    return weeks[weekNumber-1];
  }

  ///getWeek returns the Week within which @date is found @inYear.
  ///returns null if the @date isn't found @inYear
  Week getWeekByDate(DateTime date) {
    Week w;
    date = DateTime(date.year, date.month, date.day);
    final List<Week> weeks = calculateWeeks();
    weeks.forEach((week) {
      if(week.starts.isAtSameMomentAs(date) || week.ends.isAtSameMomentAs(date) 
          || (week.starts.isBefore(date) && date.isBefore(week.ends))) {
            w = week;
          }
    });
    return w;
  }
}