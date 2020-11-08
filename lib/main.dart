import 'package:flutter/material.dart';

import './theme.dart';

import './models/expense.dart';
import './widgets/chart.dart';
import './widgets/expense_list.dart';
import './vanilla_bloc/expense_bloc.dart';
import './vanilla_bloc/expense_event.dart';

/*  */
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Manager',
      home: MyHomePage(),
      theme: BudgetManagerTheme().makeTheme(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    final HomePageBody _homepageBody = new HomePageBody();

    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter'),
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                color: Colors.white,
                onPressed: () {
                  _homepageBody.showInputFieldBoxes(context);
                })
          ],
        ),
        body: _homepageBody,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).accentColor,
            onPressed: () {
              _homepageBody.showInputFieldBoxes(context);
            }));
  }
}

class HomePageBody extends StatelessWidget {
  final ExpenseBloc _expenseBloc = ExpenseBloc();

  HomePageBody();

  @override
  Widget build(BuildContext context) {

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight = mediaQuery.size.height - statusBarHeight - appBarHeight;
    
    return SafeArea(
      child: Column(children: <Widget>[
        Container(
            height: displayAreaHeight * 0.35,
            child: ExpenseManagerBarChart(displayAreaHeight)),
        Expanded(
          child: Container(
              height: displayAreaHeight * 0.7,
              child: ExpenseList(expenseBloc: _expenseBloc)),
        ),
      ]),
    );
  }

  void showInputFieldBoxes(BuildContext buildContext) {
    showModalBottomSheet(
        context: buildContext,
        builder: (_) {
          return SingleChildScrollView (child: InputFields(_expenseBloc));
        });
  }
}

class InputFields extends StatefulWidget {
  final ExpenseBloc expenseBloc;

  InputFields(this.expenseBloc);

  @override
  _InputFieldsState createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {

  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: EdgeInsetsDirectional.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10, top: 10, start: 10, end: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Title", 
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold)
                ),
            controller: titleController,
            onSubmitted: (inputValue) {
              titleController.text = inputValue;
            },
          ),
          TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: "Amount"),
            controller: amountController,
            keyboardType: TextInputType.number,
            onSubmitted: (inputAmount) {
              amountController.text = inputAmount;
            },
          ),
          RaisedButton(
            elevation: 8,
            child: Text("Add Expense"),
            textColor: Colors.purple,
            onPressed: addNewExpense,
          )
        ],
      ),
    );
  }

  void addNewExpense() {
    final String title = titleController.text;
    final double amount = double.parse(amountController.text);

    if (title.isEmpty || amount < 0) {
      return;
    }
    widget.expenseBloc.eventInput.add(AddExpense(new Expense(
      title: title,
      amount: amount,
      date: DateTime.now(),
      id: 2,
    )));
    
    Navigator.of(context).pop();
  }
}
