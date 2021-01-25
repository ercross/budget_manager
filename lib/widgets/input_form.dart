import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:trackIt/screens/expenses_screen.dart';
import 'package:trackIt/screens/income_screen.dart';

import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../bloc/income/income_bloc.dart';
import '../cubit/budget/budget_cubit.dart';
import '../models/income.dart';
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
  final TextEditingController _selectedDateContr = TextEditingController(
    text: DateFormat("dd/MM/yyyy").format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
  DateTime _selectedDateF = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  
  @override
  Widget build(BuildContext context) {
    return _buildForm(context);
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 15,
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
                      onTap: () => _showDatePicker(context)),
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
    final ctx = widget.pageNumber == 0 ? ExpensesPageBody.ctx : IncomePage.ctx;
    final String title = _titleController.text;
    final double amount = double.parse(_amountController.text, 
    //double.parse.onError
    (value){
      Navigator.of(context).pop();
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ));
      return null;
    });
    
    if (title == null || amount == null ) {
      return;
    }

    switch (widget.pageNumber) {
      case 0:
        Expense expense = Expense(
          title: title,
          amount: amount,
          date: _selectedDateF,
        );
        Repository.repository.insert(ExpenseTable.tableName, expense.toMap());
        widget.chartBloc.add( ModifyChart (ChartName.expense, expense));
        widget.expenseBloc.add(AddExpense (expense));
        break;
      
      case 1: 
        Income income = Income(
          source: title,
          amount: amount,
          date: _selectedDateF,
        );
        Repository.repository.insert(IncomeTable.tableName, income.toMap());
        widget.chartBloc.add( ModifyChart (ChartName.income, null, income: income));
        widget.incomeBloc.add(AddIncome(income));
        break;
    } 
    Navigator.of(context).pop();
  }

  void _showDatePicker(BuildContext context) {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        currentTime: DateTime.now(),
        minTime: DateTime.now(), 
        maxTime: DateTime.now(),
        onConfirm: (selectedDateF) {
      selectedDateF = DateTime(selectedDateF.year, selectedDateF.month, selectedDateF.day);
      _selectedDateF = selectedDateF;
      _selectedDateContr.text = DateFormat("dd/MM/yyyy").format(_selectedDateF);
    });
  }
}
