import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../screens/budget_screen.dart';
import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../models/week.dart';
import '../cubit/budget/budget_cubit.dart';
import '../models/budget.dart';

class NewBudgetForm {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _selectedDateContr = TextEditingController(
    text: DateFormat("dd/MM/yyyy").format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
  DateTime _selectedDateF = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  static final DateFormat dateFormat = DateFormat('MMM d, y');


  Future<void> buildBudgetForm(BuildContext context) async {
    switch (await showDialog<BudgetType>(
        context: context,
        builder: (bCtx) => SimpleDialog(
              title: const Text("budget type", style: TextStyle(fontFamily: "OleoScript"),),
              contentPadding: EdgeInsets.all(10),
              children: [
                SimpleDialogOption(
                    child: const Text("daily",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13, fontFamily:"OleoScript")),
                    onPressed: () => Navigator.pop(context, BudgetType.daily)),
                SimpleDialogOption(
                    child: const Text("weekly",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13, fontFamily:"OleoScript")),
                    onPressed: () => Navigator.pop(context, BudgetType.weekly)),
                SimpleDialogOption(
                    child: const Text("monthly",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13, fontFamily:"OleoScript")),
                    onPressed: () =>
                        Navigator.pop(context, BudgetType.monthly)),
                SimpleDialogOption(
                    child: const Text("yearly",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13, fontFamily:"OleoScript")),
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
        _addYearlyBudget(context);
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

  int yearChosen = DateTime.now().year;
  void _addYearlyBudget(BuildContext context) {
    Alert(
        title: "New Yearly Budget",
        context: context,
        closeIcon: Icon(Icons.close, color: Theme.of(context).accentColor),
        buttons: [_buildAddButton(context, _onPressedYearly)],
        content: _buildFormContainer(
          context: context, 
          children: [
            _buildTextField("amount", _amountController),

            Center(
              child: DropdownButton<int>(
                items: [
                  DropdownMenuItem(child: Text("${DateTime.now().year}", 
                                          style: TextStyle(fontSize: 14, color: Colors.black)), 
                                  value: DateTime.now().year),

                  DropdownMenuItem(child: Text("${DateTime.now().year+1}", 
                                          style: TextStyle(fontSize: 14, color: Colors.black)), 
                                  value: DateTime.now().year+1),
                ],
                hint: Text("choose year"),
                autofocus: true,
                iconSize: 24,
                isExpanded: true,
                value: yearChosen,
                underline: Container(height: 2, color: Theme.of(context).primaryColor,),
                elevation: 16,
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).accentColor), 
                onChanged: (_yearChosen) {
                  yearChosen = _yearChosen;
                },
              ),
            ),
        ])).show();
  }

  void _onPressedYearly(BuildContext context) async {

    final List<Map<String, dynamic>> map = await Repository.repository.fetch(BudgetTable.tableName, 
      where: "${BudgetTable.columnTypeDate}=?", whereArgs: [yearChosen.toDouble()]);
    if (map.isNotEmpty) {
      Navigator.of(context).pop();
      Scaffold.of(BudgetsPage.ctx).showSnackBar(SnackBar(
        content: Text("budget already added for year $yearChosen"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ));
      return;
    }

    final double amount =
        double.parse(_amountController.text, //double.parse.onError
            (value) {
              Navigator.of(context).pop();
      Scaffold.of(BudgetsPage.ctx).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ));
      return null;
    });
    if (amount == null || yearChosen == null ) return;
    BlocProvider.of<BudgetCubit>(context).add(Budget(
      dateNumber: 0,
      typeDate: yearChosen.toDouble(),
      amount: amount,
      type: BudgetType.yearly,
    ));
    Navigator.of(context).pop();
  }

  int monthChosen = DateTime.now().month;
  void _addMonthlyBudget(BuildContext context) {

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

    Alert(
      title: "New Monthly Budget",
      context: context,
      buttons: [_buildAddButton(context, _onPressedMonthlyBudget)],
      content: _buildFormContainer(context: context, 
        children: [
          _buildTextField("amount", _amountController),
          Center(
            child: DropdownButton<int>(
                items: months.sublist(DateTime.now().month-1),
                hint: Text("choose month"),
                autofocus: true,
                iconSize: 24,
                isExpanded: true,
                value: monthChosen,
                underline: Container(height: 2, color: Theme.of(context).primaryColor,),
                elevation: 16,
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).accentColor), 
                onChanged: (_chosenMonth) {
                  monthChosen = _chosenMonth;
                },
              ),
          ),
      ]),
    ).show();
  }

  void _onPressedMonthlyBudget(BuildContext ctx) async {

    final List<Map<String, dynamic>> map = await Repository.repository.fetch(BudgetTable.tableName, 
      where: "${BudgetTable.columnTypeDate}=?", whereArgs: [double.parse("${DateTime.now().year}.$monthChosen")]);
    if (map.isNotEmpty) {
      Navigator.of(ctx).pop();
      Scaffold.of(BudgetsPage.ctx).showSnackBar(SnackBar(
        content: Text("budget already added for "
            + "${DateFormat("MMMM yyyy").format(DateTime(DateTime.now().year, monthChosen))}"),
        backgroundColor: Theme.of(ctx).primaryColor.withOpacity(0.5),
      ));
      return;
    }

    final double amount =
        double.parse(_amountController.text, //double.parse.onError
            (value) {
              Navigator.of(ctx).pop();
      Scaffold.of(BudgetsPage.ctx).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        backgroundColor: Theme.of(ctx).primaryColor.withOpacity(0.5),
      ));
      return null;
    });

    if (amount == null || monthChosen == null) return;

    BlocProvider.of<BudgetCubit>(ctx).add(Budget(
        typeDate: double.parse("${DateTime.now().year}.$monthChosen"),
        dateNumber: 0,
        amount: amount,
        type: BudgetType.monthly));
    Navigator.of(ctx).pop();
  }

  Week weekChosen;
  void _addWeeklyBudget(BuildContext context) {
    final DateFormat f = DateFormat("EEE d MMM, yyyy");
    final List<Week> weeks = Weeks(inYear: Year(DateTime.now().year)).calculateWeeks();
    final Week currentWeek = Weeks(inYear: Year(DateTime.now().year)).getWeekByDate(DateTime.now());
    weekChosen = currentWeek;
    final List<DropdownMenuItem<Week>> buttonWeeks = List<DropdownMenuItem<Week>>();
    weeks.forEach((week) => buttonWeeks.add(DropdownMenuItem(
      child: Text("Week ${week.number} starts on: ${f.format(week.starts)}", 
        style: TextStyle(fontSize: 14, color: Colors.black),),
      value: week,)));

    Alert(
      title: "New Weekly Budget",
      context: context,
      buttons: [_buildAddButton(context, _onPressedWeeklyBudget)],
      content: _buildFormContainer(context: context,
        children: [
          _buildTextField("amount", _amountController),
          Center(child: DropdownButton<Week>(
            items: buttonWeeks.sublist(currentWeek.number-1),
            hint: Text("choose week"),
                autofocus: true,
                iconSize: 24,
                underline: Container(height: 2, color: Theme.of(context).primaryColor,),
                elevation: 16,
                isExpanded: true,
                value: weeks[weekChosen.number-1],
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).accentColor), 
                onChanged: (_chosenWeek) {
                  weekChosen = _chosenWeek;
                },
          ))
        ])
    ).show();
  }

  void _onPressedWeeklyBudget(BuildContext ctx) async {

    final List<Map<String, dynamic>> map = await Repository.repository.fetch(BudgetTable.tableName, 
      where: "${BudgetTable.columnTypeDate}=?", 
      whereArgs: [double.parse("${DateTime.now().year}.${DateTime.now().month}${weekChosen.number}")]);
    if (map.isNotEmpty) {
      Navigator.of(ctx).pop();
      Scaffold.of(BudgetsPage.ctx).showSnackBar(SnackBar(
        content: Text("budget already added for week $weekChosen"),
        backgroundColor: Theme.of(ctx).primaryColor.withOpacity(0.5),
      ));
      return;
    }

    final double amount =
        double.parse(_amountController.text, //double.parse.onError
            (value) {
              Navigator.of(ctx).pop();
      Scaffold.of(BudgetsPage.ctx).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        backgroundColor: Theme.of(ctx).primaryColor.withOpacity(0.5),
      ));
      return null;
    });

    if (amount == null || weekChosen == null) return;

    BlocProvider.of<BudgetCubit>(ctx).add(Budget(
        dateNumber: weekChosen.number,
        typeDate: double.parse("${DateTime.now().year}.${DateTime.now().month}$weekChosen"),
        amount: amount,
        type: BudgetType.weekly));
    Navigator.of(ctx).pop();
  }

  void _addDailyBudget(BuildContext context) {
    Alert(
        title: "New Budget",
        context: context,
        buttons: [_buildAddButton(context, _onPressedDailyBudget)],
        content: _buildFormContainer(context: context, 
          children: [
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
          ]),
        ).show();
  }

  void _onPressedDailyBudget(BuildContext context) async {
    final List<Map<String, dynamic>> map = await Repository.repository.fetch(BudgetTable.tableName, 
      where: "${BudgetTable.columnDateNumber}=?", whereArgs: [_selectedDateF.millisecondsSinceEpoch]);
    if (map.isNotEmpty) {
      Navigator.of(context).pop();
      Scaffold.of(BudgetsPage.ctx).showSnackBar(SnackBar(
        content: Text("budget already added for ${DateFormat("dd/MM/yyyy").format(_selectedDateF)}"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ));
      return;
    }
    final double amount =
        double.parse(_amountController.text, //double.parse.onError
            (value) {
              Navigator.of(context).pop();
      Scaffold.of(BudgetsPage.ctx).showSnackBar(SnackBar(
        content: Text("$value is not a valid amount"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ));
      return null;
    });

    if (amount == null || _selectedDateF == null) return;

    BlocProvider.of<BudgetCubit>(context).add(Budget(
        dateNumber: _selectedDateF.millisecondsSinceEpoch,
        typeDate: 0,
        amount: amount,
        type: BudgetType.daily));
    Navigator.of(context).pop();
  }

  void _showDatePicker(BuildContext context) {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        currentTime: DateTime.now(),
        minTime: DateTime.now(), 
        onConfirm: (selectedDateF) {
      selectedDateF =
          DateTime(selectedDateF.year, selectedDateF.month, selectedDateF.day);
      _selectedDateF = selectedDateF;
      _selectedDateContr.text = DateFormat("dd/MM/yyyy").format(_selectedDateF);
    });
  }
}
