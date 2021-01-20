import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:trackIt/cubit/budget/budget_cubit.dart';
import 'package:trackIt/cubit/report/report_cubit.dart';
import 'package:trackIt/models/income.dart';
import 'package:trackIt/widgets/income_card.dart';

import '../bloc/income/income_bloc.dart' as income;
import '../providers/current_page_index.dart';
import '../repository/db_tables.dart';
import '../screens/expenses_screen.dart';
import '../screens/search_result_screen.dart';
import '../models/chart_data_date_range.dart';
import '../models/expense.dart';
import '../utils/searcher.dart';
import '../repository/repository.dart';
import '../bloc/chart/chart_bloc.dart';
import '../bloc/expense/expense_bloc.dart' as expense; 
import '../repository/contexts_keys.dart';
import '../utils/currency.dart';
import 'expense_card.dart';

class TrackItDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Provider.of<CurrentPageIndex>(context, listen: false);

    return Consumer<CurrentPageIndex>(
      builder: (_, indexProvider, __) => Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _title,

              SizedBox(height: 10),

              ..._buildDrawerItems(indexProvider.value, context),

              _buildDrawerItem(
                  "change currency",
                  Icon(Icons.money_off_csred_sharp,
                      color: Theme.of(context).accentColor), () {
                _changeCurrency(ScaffGlobalKey.key.scaffold.currentContext);
              }),

              _buildDrawerItem(
                  "about",
                  Icon(Icons.cloud_circle_rounded,
                      color: Theme.of(context).accentColor), () {
                _showAboutDialog(ScaffGlobalKey.key.scaffold.currentContext);
              }),

              Expanded(
                  child: Container(
                      decoration:
                          BoxDecoration(color: Theme.of(context).primaryColor)))
            ],
          ),
      ),
    );
  }

  final Widget _title = Container(
    alignment: Alignment.bottomCenter,
    padding: EdgeInsets.all(15),
    height: 120,
    width: double.infinity,
    decoration: BoxDecoration(color: Color(0xFF520160)),
    child: Text(
      "Menu",
      style: TextStyle(
          fontSize: 25, color: Colors.white, fontWeight: FontWeight.w900),
    ),
  );

  ///using PageView has prevented me from building custom drawer for each page.
  ///_buildDrawerItems tracks the currentPageIndex and output different items on the drawer based on this.
  List<Widget> _buildDrawerItems(int currentPageIndex, BuildContext context) {
    switch (currentPageIndex) {
      case 0: 
        return _buildExpensePageDrawerItems(context);
        break;
      case 1: 
        return _buildIncomePageDrawerItems(context);
        break;
      case 2: 
        return _buildBudgetPageDrawerItems(context);
        break;
      case 3:
        return _buildReportPageDraweritems(context);
        break;
      default:
        return [Text("This \nshould \nnever \nbe \ndisplayed")];
        break;
    }
  }

  List<Widget> _buildExpensePageDrawerItems(BuildContext context) {
    return [
    _buildDrawerItem("search", 
                  Icon(Icons.search, color: Theme.of(context).accentColor), 
                  () {Searcher().searchExpense(ScaffGlobalKey.key.scaffold.currentContext); }),

    _buildDrawerItem("all expenses",
                  Icon(Icons.all_inbox, color: Theme.of(context).accentColor), 
                  () {_fetchAllExpenses(ScaffGlobalKey.key.scaffold.currentContext);}),

    _buildDrawerItem("chart date",
                  Icon(Icons.bar_chart, color: Theme.of(context).accentColor), 
                  () {_chooseDateRange(ScaffGlobalKey.key.scaffold.currentContext);}),
    ];
  }

  List<Widget> _buildIncomePageDrawerItems(BuildContext context) {
    return [
      _buildDrawerItem("search", 
                  Icon(Icons.search, color: Theme.of(context).accentColor), 
                  () {Searcher().searchIncome(ScaffGlobalKey.key.scaffold.currentContext); }),

      _buildDrawerItem("all incomes",
                  Icon(Icons.bar_chart, color: Theme.of(context).accentColor), 
                  () {_fetchAllIncomes(ScaffGlobalKey.key.scaffold.currentContext);}),
    ];
  }

  List<Widget> _buildBudgetPageDrawerItems(BuildContext context) {
    return [
      _buildDrawerItem("daily budgets", 
                  Icon(Icons.calendar_view_day, color: Theme.of(context).accentColor), 
                  () {
                    Navigator.of(context).pop();
                    BlocProvider.of<BudgetCubit>(context).getDailyBudgets();}),

      _buildDrawerItem("weekly budgets", 
                  Icon(Icons.view_week, color: Theme.of(context).accentColor), 
                  () {
                    Navigator.of(context).pop();
                    BlocProvider.of<BudgetCubit>(context).getWeeklyBudgets();}),

      _buildDrawerItem("monthly budgets", 
                  Icon(Icons.monitor, color: Theme.of(context).accentColor), 
                  () {
                    Navigator.of(context).pop();
                    BlocProvider.of<BudgetCubit>(context).getMonthlyBudgets();}),

      _buildDrawerItem("${DateTime.now().year} budget", 
                  Icon(Icons.merge_type, color: Theme.of(context).accentColor), 
                  () {
                    Navigator.of(context).pop();
                    BlocProvider.of<BudgetCubit>(context).getThisYearBudget();}),
    ];
  }

  List<Widget> _buildReportPageDraweritems(BuildContext context) {
    return [
      _buildDrawerItem("daily reports", 
                  Icon(Icons.calendar_view_day, color: Theme.of(context).accentColor), 
                  () {
                    Navigator.of(context).pop();
                    BlocProvider.of<ReportCubit>(context).getDailyReports();
                  }),      

      _buildDrawerItem("weekly reports", 
                  Icon(Icons.view_week, color: Theme.of(context).accentColor), 
                  () {
                    Navigator.of(context).pop();
                    BlocProvider.of<ReportCubit>(context).getWeeklyReports();
                  }),

      _buildDrawerItem("monthly reports", 
                  Icon(Icons.monitor, color: Theme.of(context).accentColor), 
                  () {
                    Navigator.of(context).pop();
                    BlocProvider.of<ReportCubit>(context).getMonthlyReports();
                  }),

      _buildDrawerItem("${DateTime.now().year-1} report", 
                  Icon(Icons.merge_type, color: Theme.of(context).accentColor), 
                  () {
                    Navigator.of(context).pop();
                    BlocProvider.of<ReportCubit>(context).getYearlyReports();})
    ];
  }

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
    if (Navigator.of(ctx).canPop())
          Navigator.of(ctx).pop();
    final List<Map<String, dynamic>> maps = await Repository.repository.fetch(ExpenseTable.tableName);
    Navigator.of(ctx).pushNamed(SearchResultPage.routeName, arguments: {
      SearchResultPage.pageTitleKey: "all expenses",
      SearchResultPage.listViewKey: _buildExpensesListView(Expense.fromMaps(maps))
    });
  }

  void _fetchAllIncomes (BuildContext ctx) async {
    if (Navigator.of(ctx).canPop())
          Navigator.of(ctx).pop();
    final List<Map<String, dynamic>> maps = await Repository.repository.fetch(IncomeTable.tableName);
    Navigator.of(ctx).pushNamed(SearchResultPage.routeName, arguments: {
      SearchResultPage.pageTitleKey: "all incomes",
      SearchResultPage.listViewKey: _buildIncomesListView(Income.fromMaps(maps))
    });
  }

  Widget _buildIncomesListView(List<Income> incomes) => 
    (incomes == null || incomes.isEmpty)
          ? const Center(
              child: Text(
                "No incomes found",
                style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(171, 39, 79, 0.4),
                    fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: incomes.length,
              itemBuilder: (buildContext, index) {
                return IncomeCard(
                  income: incomes[index],
                  delete: (income) {
                    incomes.remove(incomes[index]);
                    Repository.repository.delete(
                        tableName: IncomeTable.tableName,
                        where: "${IncomeTable.columnId}=?",
                        targetValues: [incomes[index].id]);
                  },
                );
              });

  Widget _buildExpensesListView(List<Expense> expenses) =>
      (expenses == null || expenses.isEmpty)
          ? const Center(
              child: Text(
                "No Expenses Found",
                style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(171, 39, 79, 0.4),
                    fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (buildContext, index) {
                return ExpenseCard(
                  expense: expenses[index],
                  deleteExpense: (expense) {
                    expenses.remove(expenses[index]);
                    Repository.repository.delete(
                        tableName: ExpenseTable.tableName,
                        where: "${ExpenseTable.columnId}=?",
                        targetValues: [expenses[index].id]);
                  },
                );
              });

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
          Repository.repository.setNewCurrency(newCurrency);
          BlocProvider.of<expense.ExpenseBloc>(ctx).add(expense.ChangeCurrency(newCurrency));
          BlocProvider.of<ChartBloc>(ctx).add(ChangeCurrency(newCurrency));
          BlocProvider.of<income.IncomeBloc>(ctx).add(income.ChangeCurrency(newCurrency));
          Navigator.of(ctx).pop();
        },
      ),
    ).show();
  }

  void _showAboutDialog(BuildContext ctx) {
    Navigator.of(ctx).pop();
    Alert(
        style: AlertStyle(
          alertPadding: EdgeInsets.all(5),
          titleStyle: TextStyle(fontSize: 28, color: Theme.of(ctx).primaryColor, fontWeight: FontWeight.bold, 
                fontStyle: FontStyle.italic)
        ),
        context: ctx,
        title: "Trackit", desc: "",
        buttons: [],
        closeIcon: Icon(Icons.close, color: Theme.of(ctx).accentColor),
        content: Center(child: Text("Trackit is a fully-featured expense tracker \n\nDeveloped: Ercross Labs \nv1.0",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic, 
                                      color: Theme.of(ctx).accentColor, 
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
    ).show();
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

    if (startDate.difference(endDate) > Duration(days: 6) ||
        startDate.difference(endDate) < Duration(days: 6)) {
      Navigator.of(ctx).pop();
      Scaffold.of(ExpensesPageBody.expensesScreenContext).showSnackBar(SnackBar(
        content: Text("Date range must be 7 days apart"),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    final ChartDataDateRange dateRange = ChartDataDateRange(fromDate: startDate, toDate: endDate);
    BlocProvider.of<ChartBloc>(ctx).add(GenerateNewData(ChartName.expense, dateRange));
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
                  currentTime: DateTime.now(),
                  maxTime: DateTime.now(), 
                  onConfirm: (selectedDateF) {
                    selectedDateF = DateTime(selectedDateF.year, selectedDateF.month, selectedDateF.day);
                    datePosition = selectedDateF;
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
