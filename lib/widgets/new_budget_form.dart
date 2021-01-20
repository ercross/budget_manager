import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../cubit/budget/budget_cubit.dart';
import '../models/budget.dart';
import '../screens/expenses_screen.dart';

class NewBudgetForm {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _selectedDateContr = TextEditingController(text: "${DateTime.now()}");
  DateTime _selectedDateF;
  static final DateFormat dateFormat = DateFormat('MMM d, y');


  Future<void> buildBudgetForm(BuildContext context) async {
    switch (await showDialog<BudgetType>(
        context: context,
        builder: (bCtx) => SimpleDialog(
              title: const Text("budget type"),
              contentPadding: EdgeInsets.all(10),
              children: [
                SimpleDialogOption(
                    child: const Text("daily",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13)),
                    onPressed: () => Navigator.pop(context, BudgetType.daily)),
                SimpleDialogOption(
                    child: const Text("weekly",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13)),
                    onPressed: () => Navigator.pop(context, BudgetType.weekly)),
                SimpleDialogOption(
                    child: const Text("monthly",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13)),
                    onPressed: () =>
                        Navigator.pop(context, BudgetType.monthly)),
                SimpleDialogOption(
                    child: const Text("this year",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13)),
                    onPressed: () => Navigator.pop(context, BudgetType.yearly)),
              ],
            ))) {
      case BudgetType.daily:
        _addDailyBudget(context);
        break;
      case BudgetType.weekly:
        _addWeeklyBudget(context);
        break;
      case BudgetType.monthly:
        _addMonthlyBudget(context);
        break;
      case BudgetType.yearly:
        _addThisYearBudget(context);
        break;
    }
  }

  Widget _buildTextField(String labelText, TextEditingController _contr) {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontWeight: FontWeight.bold)),
      controller: _contr,
      onSubmitted: (inputValue) {
        _contr.text = inputValue;
      },
    );
  }

  DialogButton _buildAddButton(BuildContext context, Function onPressed) {
    return DialogButton(
        onPressed: () => onPressed(context),
        child: Text("Add Budget",
            style: TextStyle(
              color: Colors.white,
            )));
  }

  void _onPressedYearly(BuildContext context) {
    final double amount =
        double.parse(_amountController.text, //double.parse.onError
            (value) {
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        duration: Duration(seconds: 4),
      ));
      return null;
    });
    if (amount == null) return;
    BlocProvider.of<BudgetCubit>(context).add(Budget(
      startDate: DateTime(DateTime.now().year, 1, 1),
      endDate: DateTime(DateTime.now().year, 12, 31),
      amount: amount,
      type: BudgetType.yearly,
    ));
    Navigator.of(context).pop();
  }

  ///buildDateText builds a row containing a leading widget, usually a text Widget at the far left 
  ///and a non-responsive TextField at the far right. 
  ///@controller controls the text that would be displayed within the non-responsive textField
  ///Note that controller.text must hold an instance of DateTime as toString at any point in time, else an error will be thrown
  Widget _buildDateText(
      {@required Widget leading, @required TextEditingController controller}) {
        final String formattedDate = dateFormat.format(DateTime.parse(controller.text));
        final TextEditingController fCtr = TextEditingController(text: formattedDate); 
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(height: 25),
            leading,
          ],
        ),
        SizedBox(
          width: 40,
        ),
        Flexible(
          child: TextField(
            controller: fCtr,
            enableInteractiveSelection: false,
            readOnly: false,
            enabled: false,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContainer({BuildContext context, List<Widget> children}) {
    return Container(
        padding: EdgeInsetsDirectional.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 15, //start: 10,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children));
  }

  void _addThisYearBudget(BuildContext context) {
    final List<DropdownMenuItem<int>> months = [
      DropdownMenuItem(child: Text("January", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.january),
      DropdownMenuItem(child: Text("February", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.february),
      DropdownMenuItem(child: Text("March", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.march),
      DropdownMenuItem(child: Text("April", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.april),
      DropdownMenuItem(child: Text("May", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.may),
      DropdownMenuItem(child: Text("June", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.june),
      DropdownMenuItem(child: Text("July", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.july),
      DropdownMenuItem(child: Text("August", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.august),
      DropdownMenuItem(child: Text("September", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.september),
      DropdownMenuItem(child: Text("October", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.october),
      DropdownMenuItem(child: Text("November", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.november),
      DropdownMenuItem(child: Text("December", style: TextStyle(fontSize: 14, color: Colors.black)), value: DateTime.december),
    ];

    int chosenMonth = 1;
    DateTime date = DateTime(DateTime.now().year, chosenMonth,);

    Alert(
        title: "This year budget",
        context: context,
        closeIcon: Icon(Icons.close, color: Theme.of(context).accentColor),
        buttons: [_buildAddButton(context, _onPressedYearly)],
        content: _buildFormContainer(
          context: context, 
          children: [
            _buildTextField("amount", _amountController),

            DropdownButton(
              items: months,
              hint: Text("choose month"),
              autofocus: true,
              iconSize: 24,
              underline: Container(height: 2, color: Theme.of(context).primaryColor,),
              elevation: 16,
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).accentColor), 
              onChanged: (month) {

              },
            ),
        ])).show();
  }

  Widget _buildDateButton(BuildContext context, String buttonText) {
    return GestureDetector(
                      child: Text(buttonText,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600)),
                      onTap: () => _showDatePicker(context));
  }

  void _addMonthlyBudget(BuildContext context) {

    DateTime endDate = DateTime.parse(_selectedDateContr.text);
    endDate = DateTime(endDate.year, endDate.month+1, endDate.day).subtract(Duration(days: 1));

    Alert(
      title: "New Monthly Budget",
      context: context,
      buttons: [_buildAddButton(context, _onPressedMonthlyBudget)],
      content: _buildFormContainer(context: context, 
        children: [
          _buildTextField("amount", _amountController),
          _buildDateText(
            controller: _selectedDateContr,
            leading: _buildDateButton(context, "start date"),
          ),
          _buildDateText(
            controller: TextEditingController(text: "$endDate"),
            leading: Text("end date", style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                                  fontWeight: FontWeight.w600))
          ),
      ]),
    ).show();
  }

  void _onPressedMonthlyBudget(BuildContext ctx) {
    final DateTime endDate = DateTime(
            _selectedDateF.year, _selectedDateF.month + 1, _selectedDateF.day)
        .subtract(Duration(days: 1));
    final double amount =
        double.parse(_amountController.text, //double.parse.onError
            (value) {
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        duration: Duration(seconds: 4),
      ));
      return null;
    });

    if (amount == null || _selectedDateF == null) return;

    if (_selectedDateF.day.compareTo(1) != 0) {
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("Month must start on the 1st"),
        duration: Duration(seconds: 7),
      ));
      return;
    }

    BlocProvider.of<BudgetCubit>(ctx).add(Budget(
        startDate: _selectedDateF,
        endDate: endDate,
        amount: amount,
        type: BudgetType.monthly));
    Navigator.of(ctx).pop();
  }

  Widget _addWeeklyBudget(BuildContext context) {
    return Container(
        padding: EdgeInsetsDirectional.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 15, //start: 10,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextField("amount", _amountController),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      child: Text("start date",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600)),
                      onTap: () => _showDatePicker(context)),
                  SizedBox(
                      width: 100,
                      height: 70,
                      child: TextField(
                          controller: _selectedDateContr,
                          readOnly: true,
                          style: TextStyle(fontSize: 13, color: Colors.grey)))
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                    elevation: 8,
                    child: Text("Add Budget"),
                    textColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      _onPressedWeeklyBudget(context);
                    }),
              )
            ]));
  }

  void _onPressedWeeklyBudget(BuildContext ctx) {
    final double amount =
        double.parse(_amountController.text, //double.parse.onError
            (value) {
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        duration: Duration(seconds: 4),
      ));
      return null;
    });

    if (amount == null || _selectedDateF == null) return;

    if (_selectedDateF.weekday.compareTo(DateTime.monday) != 0) {
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("Week must start on Monday"),
        duration: Duration(seconds: 7),
      ));
      return;
    }

    BlocProvider.of<BudgetCubit>(ctx).add(Budget(
        startDate: _selectedDateF,
        endDate: _selectedDateF.add(Duration(days: 6)),
        amount: amount,
        type: BudgetType.weekly));
    Navigator.of(ctx).pop();
  }

  void _addDailyBudget(BuildContext context) {
    Alert(
        title: "New Budget",
        context: context,
        content: Container(
            padding: EdgeInsetsDirectional.only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + 15, //start: 10,
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTextField("amount", _amountController),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          child: Text("Date",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600)),
                          onTap: () => _showDatePicker(context)),
                      SizedBox(
                          width: 100,
                          height: 70,
                          child: TextField(
                              controller: _selectedDateContr,
                              readOnly: true,
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey)))
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: RaisedButton(
                        elevation: 8,
                        child: Text("Add Budget"),
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          _onPressedDailyBudget(context);
                        }),
                  )
                ]))).show();
  }

  void _onPressedDailyBudget(BuildContext context) {
    final double amount =
        double.parse(_amountController.text, //double.parse.onError
            (value) {
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        duration: Duration(seconds: 4),
      ));
      return null;
    });

    if (amount == null || _selectedDateF == null) return;

    BlocProvider.of<BudgetCubit>(context).add(Budget(
        startDate: _selectedDateF,
        endDate: _selectedDateF,
        amount: amount,
        type: BudgetType.daily));
    Navigator.of(context).pop();
  }

  void _showDatePicker(BuildContext context) {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        currentTime: DateTime.now(),
        maxTime: DateTime.now(), onConfirm: (selectedDateF) {
      selectedDateF =
          DateTime(selectedDateF.year, selectedDateF.month, selectedDateF.day);
      _selectedDateF = selectedDateF;
      _selectedDateContr.text = DateFormat("dd/MM/yyyy").format(_selectedDateF);
    });
  }
}
