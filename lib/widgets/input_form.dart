import 'package:budget_manager/bloc/chart/chart_event.dart';
import 'package:budget_manager/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import '../bloc/chart/chart_bloc.dart';
import '../bloc/expense/expense_bloc.dart';
import '../main.dart';
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
  final TextEditingController _selectedDateContr = TextEditingController();
  DateTime _selectedDate;

  Widget buildTextField (String labelText, TextEditingController _contr) {
    return TextField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: labelText,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                controller: _contr,
                onSubmitted: (inputValue) {
                  _contr.text = inputValue;
                },
              );}
              
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 15,//start: 10,
            ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildTextField("title", _titleController),
              buildTextField("amount", _amountController),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      child: 
                          Text("Date",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600))
                          ,
                      onTap: showDatePicker),
                  SizedBox(width: 100, height: 70, child:
                  TextField(controller: _selectedDateContr, readOnly: true, style: TextStyle(fontSize: 13, color: Colors.grey)))
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
    final double amount = double.parse(_amountController.text, 
    //double.parse.onError
    (value){
      Scaffold.of(HomePageBody.scaffoldBodyContext).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        duration: Duration(seconds: 2),
      ));
      return null;
    });
    
    if (title == null || amount == null || _selectedDate == null) {
      return;
    }

    if (_selectedDate.isBefore(Repository.repository.oldestDate)) {
      Repository.repository.setNewOldestDate(_selectedDate);
    }

    widget.expenseBloc.add(AddExpense (new Expense(
      title: title,
      amount: amount,
      date: _selectedDate,
    )));
    widget.chartBloc.add( AddOrRemoveExpenseFromChart (new Expense(
      title: title,
      amount: amount,
      date: _selectedDate,
    )));
    Navigator.of(context).pop();
  }

  void showDatePicker() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        currentTime: DateTime.now(), 
        onConfirm: (selectedDate) {
      _selectedDate = selectedDate;
      _selectedDateContr.text = DateFormat("dd/MM/yyyy").format(_selectedDate);
    });
  }
}
