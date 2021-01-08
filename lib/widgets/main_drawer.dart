import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../repository/db_tables.dart';
import '../screens/expenses_screen.dart';
import '../screens/search_result_screen.dart';
import '../models/chart_data_date_range.dart';
import '../models/expense.dart';
import '../widgets/search.dart';
import '../repository/repository.dart';
import '../bloc/chart/chart_bloc.dart';
import '../bloc/chart/chart_event.dart';
import '../bloc/expense/expense_bloc.dart';
import '../repository/contexts_keys.dart';
import '../currency.dart';
import 'expense_card.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _title,
          SizedBox(height: 10),
          _buildDrawerItem("all expenses",
              Icon(Icons.bar_chart, color: Theme.of(context).primaryColor), () {
            _fetchAllExpenses(ScaffGlobalKey.key.scaffold.currentContext);
          }),
          _buildDrawerItem(
              "search expense",
              Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ), () {
            Search().searchExpense(ScaffGlobalKey.key.scaffold.currentContext);
          }),
          _buildDrawerItem("statistics",
              Icon(Icons.bar_chart, color: Theme.of(context).primaryColor), () {
            _chooseDateRange(ScaffGlobalKey.key.scaffold.currentContext);
          }),
          _buildDrawerItem(
              "change currency",
              Icon(Icons.money_off_csred_sharp,
                  color: Theme.of(context).primaryColor), () {
            _changeCurrency(ScaffGlobalKey.key.scaffold.currentContext);
          }),
          _buildDrawerItem(
              "about",
              Icon(Icons.cloud_circle_rounded,
                  color: Theme.of(context).primaryColor), () {
            _showAboutDialog(ScaffGlobalKey.key.scaffold.currentContext);
          }),
          Expanded(
              child: Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor)))
        ],
      ),
    );
  }

  final Widget _title = Container(
    alignment: Alignment.bottomCenter,
    padding: EdgeInsets.all(15),
    height: 120,
    width: double.infinity,
    decoration: BoxDecoration(color: Color.fromRGBO(171, 39, 79, 1)),
    child: Text(
      "Menu",
      style: TextStyle(
          fontSize: 25, color: Colors.white, fontWeight: FontWeight.w900),
    ),
  );

  Widget _buildDrawerItem(String itemName, Icon icon, Function onTap) {
    return ListTile(
      onTap: onTap,
      leading: icon,
      title: Text(
        itemName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  void _fetchAllExpenses(BuildContext ctx) async {
    Navigator.of(ctx).pop();
    final List<Expense> expenses =
        await Repository.repository.getAll(ExpenseTable.tableName);
    Navigator.of(ctx).pushNamed(SearchResultPage.routeName, 
        arguments: {
          SearchResultPage.pageTitleKey: "all expenses",
          SearchResultPage.listViewKey: _buildExpensesListView(expenses, Repository.repository.currencySymbol)
        });
  }

  Widget _buildExpensesListView (List<Expense> expenses, String currency) {
    return ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (buildContext, index) {
          return ExpenseCard(
            expense: expenses[index],
            currencySymbol: currency,
            deleteExpense: (expense) {
              expenses.remove(expenses[index]);
              Repository.repository.delete(
                tableName: ExpenseTable.tableName, where: "${ExpenseTable.columnId}=?", targetValues: [expenses[index].id]);
            },
          );
        });
  }

  void _changeCurrency(BuildContext ctx) {
    Navigator.of(ctx).pop();
    Alert(
      context: ctx,
      title: "select currency",
      buttons: [],
      closeIcon: Icon(Icons.close),
      content: DropdownButton(
        items: Currency.currencies,
        autofocus: true,
        iconSize: 24,
        underline: Container(
          height: 2,
          color: Theme.of(ctx).primaryColor,
        ),
        hint: Text("currency"),
        elevation: 16,
        style: TextStyle(color: Theme.of(ctx).primaryColor),
        icon: Icon(Icons.arrow_drop_down, color: Theme.of(ctx).primaryColor),
        onChanged: (newCurrency) {
          Repository.repository.setCurrencySymbol(newCurrency);
          BlocProvider.of<ExpenseBloc>(ctx)
              .add(ChangeCurrencySymbol(newCurrency));
          BlocProvider.of<ChartBloc>(ctx)
              .add(ChangeChartCurrencySymbol(newCurrency));
          Navigator.of(ctx).pop();
        },
      ),
    ).show();
  }

  void _showAboutDialog(BuildContext ctx) {
    Navigator.of(ctx).pop();
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Trackeet"),
            actions: [
              Center(
                child: RaisedButton(
                    child: Text("OK",
                        style: TextStyle(
                            color: Theme.of(ctx).accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 25)),
                    onPressed: () => Navigator.of(ctx).pop()),
              )
            ],
            contentPadding: EdgeInsets.all(20),
            scrollable: true,
            actionsPadding: EdgeInsets.all(15),
            content: SingleChildScrollView(
              child: Column(children: <Widget>[
                Text(
                  "Trackeet is an expense manager application. \nMore exciting features will be rolled out with the soon to be released version v2.0.0",
                  style: TextStyle(fontSize: 14),
                ),
                Text("\n\ncurrent version: v1.0.0",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Center(
                    child: Text("\nBuilt: Ercross Labs",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
              ]),
            ),
          );
        });
  }

  void _chooseDateRange(BuildContext ctx) {
    DateTime startDate;
    DateTime endDate;
    final TextEditingController _startDateContr = TextEditingController();
    final TextEditingController _endDateContr = TextEditingController();

    Navigator.of(ctx).pop();
    Alert(
        context: ctx,
        title: "statistics date range",
        closeIcon: Icon(
          Icons.close,
          color: Theme.of(ctx).accentColor,
          size: 13,
        ),
        buttons: [
          DialogButton(
            child: Text("OK",
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(ctx).primaryColor,
                    fontWeight: FontWeight.bold)),
            onPressed: () {
              _onDateRangeOkButtonPressed(
                  ctx: ctx, endDate: endDate, startDate: startDate);
            },
          )
        ],
        content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateCollector(
                  ctx: ctx,
                  buttonText: "start date:",
                  datePosition: startDate,
                  controller: _startDateContr),
              _buildDateCollector(
                  ctx: ctx,
                  buttonText: "end date:",
                  datePosition: endDate,
                  controller: _endDateContr),
            ])).show();
  }

  void _onDateRangeOkButtonPressed(
      {@required DateTime startDate,
      @required DateTime endDate,
      @required BuildContext ctx}) async {

    if (startDate.isAfter(endDate)) {
      Navigator.of(ctx).pop();
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("start date must be earlier than end date"),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    if (startDate.difference(endDate) > Duration(days: 6) || startDate.difference(endDate) < Duration(days: 6)) {
      Navigator.of(ctx).pop();
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("Date range must be 7 days apart"),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    final ChartDataDateRange dateRange =
        ChartDataDateRange(fromDate: startDate, toDate: endDate);
    BlocProvider.of<ChartBloc>(ctx).add(GetNewChartData(dateRange));
  }

  //@param datePosition can either be startDate or endDate
  Widget _buildDateCollector(
      {@required BuildContext ctx,
      @required String buttonText,
      @required DateTime datePosition,
      @required TextEditingController controller}) {
        
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Align(
        alignment: Alignment.bottomLeft,
        child: FlatButton(
            child: Text(buttonText,
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600)),
            onPressed: () {
              DatePicker.showDatePicker(ctx,
                  showTitleActions: true,
                  currentTime: DateTime.now(), onConfirm: (selectedDate) {
                datePosition = selectedDate;
                
                controller.text = DateFormat("dd/MM/yyyy").format(datePosition);
              });
            }),
      ),
      SizedBox(
          width: 100,
          height: 70,
          child: TextField(
              controller: controller,
              readOnly: true,
              style: TextStyle(fontSize: 13, color: Colors.grey)))
    ]);
  }
}
