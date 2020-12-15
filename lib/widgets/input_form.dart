import 'package:budget_manager/bloc/chart/chart_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import '../bloc/chart/chart_bloc.dart';
import '../bloc/expense/expense_bloc.dart';
import '../models/expense.dart';

class InputFields extends StatefulWidget {
  final ExpenseBloc expenseBloc;
  final ChartBloc chartBloc;

  const InputFields(this.expenseBloc, this.chartBloc);

  @override
  _InputFieldsState createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            top: 10,
            //start: 10,
            end: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                controller: _titleController,
                onSubmitted: (inputValue) {
                  _titleController.text = inputValue;
                },
              ),
              TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: "Amount"),
                controller: _amountController,
                keyboardType: TextInputType.number,
                onSubmitted: (inputAmount) {
                  _amountController.text = inputAmount;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                      child: _selectedDate == null
                          ? Text("Date",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600))
                          : Align( alignment: Alignment.centerLeft,
                                                      child: Text(DateFormat("dd/MM/yyyy").format(_selectedDate),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15)),
                          ),
                      onPressed: showDatePicker),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  elevation: 8,
                  child: Text("Add Expense"),
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () => addNewExpense(context),
                ),
              )
            ]));
  }

  void addNewExpense(BuildContext context) {
    final String title = _titleController.text;
    final double amount = double.parse(_amountController.text);
    
    if (title.isEmpty && amount < 0 && _selectedDate == null) {
      return;
    }
    widget.expenseBloc.add(AddExpense (new Expense(
      title: title,
      amount: amount,
      date: _selectedDate,
    )));
    widget.chartBloc.add( AddNewExpenseToChart (new Expense(
      title: title,
      amount: amount,
      date: _selectedDate,
    )));
    Navigator.of(context).pop();
  }

  void showDatePicker() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        currentTime: DateTime.now(), onChanged: (selectedDate) {
      _selectedDate = selectedDate;
    }, onConfirm: (selectedDate) {
      _selectedDate = selectedDate;
    });
  }
}
