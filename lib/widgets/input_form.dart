import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:trackIt/bloc/income/income_bloc.dart';
import 'package:trackIt/cubit/budget/budget_cubit.dart';
import 'package:trackIt/models/budget.dart';
import 'package:trackIt/models/income.dart';

import '../repository/repository.dart';
import '../screens/expenses_screen.dart';
import '../bloc/chart/chart_bloc.dart';
import '../bloc/expense/expense_bloc.dart';
import '../models/expense.dart';

class InputFields extends StatefulWidget {
  final ExpenseBloc expenseBloc;
  final IncomeBloc incomeBloc;
  final ChartBloc chartBloc;
  final BudgetCubit budgetCubit;
  final int pageNumber;


  const InputFields({
    @required this.expenseBloc,
    @required this.incomeBloc,
    @required this.chartBloc,
    @required this.pageNumber,
    @required this.budgetCubit});

  @override
  _InputFieldsState createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _selectedDateContr = TextEditingController();
  DateTime _selectedDateF;
  
  @override
  Widget build(BuildContext context) {
    return _decideBasedOnPage();
  }

  Widget _decideBasedOnPage() {
    //code for cases 2 and 3 are contained in the expensePage widget 
    switch(widget.pageNumber) {
      case 0: 
        return _buildForm(context);
        break;
      case 1 :
        return _buildForm(context);
        break; 
      default:
        return Center(child: Text("Error building input form"));
    }
  }

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

  Widget _buildForm(BuildContext context) {
    String okButtonText;
    String upperBoxLabel;

    switch (widget.pageNumber) {
      case 0: 
        upperBoxLabel = "title" ;
        okButtonText = "Add Expense";
        break;
      case 1: 
         upperBoxLabel = "source";
         okButtonText = "Add Income";
         break;
    }
    return Container(
        padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 15,//start: 10,
            ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildTextField(upperBoxLabel, _titleController),
              buildTextField("amount", _amountController),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      child: 
                          Text("Date",
                              style: TextStyle( fontSize: 14,
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
                  child: Text(okButtonText),
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    addNewTrackitItem(context);
                  } 
                ),
              )
            ]));
  }

  void addNewTrackitItem(BuildContext context) {
    final String title = _titleController.text;
    final double amount = double.parse(_amountController.text, 
    //double.parse.onError
    (value){
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        duration: Duration(seconds: 4),
      ));
      return null;
    });
    
    if (title == null || amount == null || _selectedDateF == null) {
      return;
    }

    switch (widget.pageNumber) {
      case 0:
        if (_selectedDateF.isBefore(Repository.repository.oldestExpenseDate)) {
          Repository.repository.setOldestExpenseDate(_selectedDateF);
        }

        widget.expenseBloc.add(AddExpense (new Expense(
          title: title,
          amount: amount,
          date: _selectedDateF,
        )));
        widget.chartBloc.add( ModifyChart (ChartName.expense, new Expense(
          title: title,
          amount: amount,
          date: _selectedDateF,
        )));
        break;
      
      case 1: 
        if (_selectedDateF.isBefore(Repository.repository.oldestIncomeDate)) {
          Repository.repository.setOldestIncomeDate(_selectedDateF);
        }

        widget.incomeBloc.add(AddIncome( Income(
          source: title,
          amount: amount,
          date: _selectedDateF,
        )));
        widget.chartBloc.add( ModifyChart (ChartName.income, null, income: Income(
          source: title,
          amount: amount,
          date: _selectedDateF,
        )));
        break;
    } 
    Navigator.of(context).pop();
  }
}
