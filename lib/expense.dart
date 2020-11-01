import 'package:flutter/foundation.dart';
//import 'package:equatable/equatable.dart';

class Expense {
  final int id;
  final String title;
  final double amount;
  final DateTime date;

  Expense ({
    @required this.id,
    this.title,
    this.amount,
    this.date
  });

  //@override
  //List<Object> get props => [id, title, amount, date];
}