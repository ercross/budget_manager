import 'package:flutter/material.dart';


class Year {
  final int value;
  final bool isLeapYear;

  const Year (this.value): isLeapYear = value % 4 == 0;
}


class Week{
  final int number; ///@number is the week number
  final DateTime starts; //each week must start on Monday according to ISO-180
  final DateTime ends; //each week must end on Sunday

  const Week({this.number, this.starts, this.ends});

  String toString() => "week number: $number \nstarts on: $starts \n ends on: $ends\n";
}

class Weeks {
  final Year year;
  final int totalNumberOfWeeks;
  Weeks({@required this.year})

          //Number of weeks in a year could be 52 or 53, depending on some factors.
          //Most years have 52 weeks, but if the year starts on a Thursday or is a leap year that starts on a Wednesday, 
          //that particular year will have 53 weeks. 
          : totalNumberOfWeeks = 
            (DateTime(year.value, 1, 1).weekday == 4 || year.isLeapYear && DateTime(year.value, 1, 1).weekday == 4) 
              ? 53 
              : 52;

  ///The first week of the year is the year that contains the first Thursday in the year
  ///the return value.weekday must be == 1
  DateTime _calcFirstWeekStartDate() {
    final DateTime firstDayOfTheYear = DateTime(this.year.value, 1, 1);
    final int fdNum = firstDayOfTheYear.weekday;

    //if first day of the year is monday, then firstDayOfTheYear denotes this.year firstWeekStartDate
    if (fdNum == 1) return firstDayOfTheYear;

    //if first day of the year is after Thursday, count 8-fdNum days forward to get the first Monday of the year
    //And this first monday of the year denotes the start of the first week of this.year
    if (fdNum > 4) return firstDayOfTheYear.add(Duration(days: 8-fdNum));

    //if first day of the year is before Thursday, count fdNum-1 days backwards to get the last Monday of the previous year
    //And this last monday of the previous year denotes the start of the first week of this.year
    if (fdNum > 1 && fdNum < 4) return DateTime(this.year.value-1, 1, 1).subtract(Duration(days: fdNum - 1));

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
}