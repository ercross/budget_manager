import './vanilla_bloc/expense_bloc.dart';
import 'package:flutter/material.dart';
import './widgets/expense_list.dart';
import './expense.dart';
import './vanilla_bloc/expense_event.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My play App',
      home: MyHomePage(),
      theme: ThemeData(
        //primaryColor: Color.fromRGBO(140, 54, 49, 0.8),
        //accentColor: Color.fromRGBO(150, 64, 59, 0.9),
        //brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey
      ), 
    );
  }
}

class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter'),
      ),
      body: HomePageBody(),
    );
  }
}

class HomePageBody extends StatelessWidget {
  final ExpenseBloc _expenseBloc = ExpenseBloc();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Chart(),
            InputFields(_expenseBloc),
            ExpenseList(expenseBloc: _expenseBloc)
          ],
        )
      );
  }
}

class Chart extends StatelessWidget {
  @override
  Widget build (BuildContext buildContext) {
    return Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Color.fromRGBO(140, 54, 49, 0.8),
                border:Border.symmetric(vertical: BorderSide(width: 2))
              ),
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              child: Card(
                elevation: 6,
                child: Center(
                  child: Text("chart"),
                ),
              ),
            );
  }
}

class InputFields extends StatelessWidget {
  final ExpenseBloc expenseBloc;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  InputFields(this.expenseBloc);

  @override
  Widget build(BuildContext context) {
    return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 5,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextField(autofocus: true, decoration: InputDecoration(labelText: "Title"), controller: titleController,),
                    TextField(autofocus: true, decoration: InputDecoration(labelText: "Amount"), controller: amountController),
                    RaisedButton(
                      elevation: 8,
                      child: Text("Add Expense"),
                      textColor: Colors.purple,
                      onPressed: () {
                        expenseBloc.eventInput.add(AddExpense(
                        Expense(
                          title: titleController.text,
                          amount: double.parse(amountController.text),
                          date: DateTime.now(),
                          id: 2,
                        )
                      ));
                      },
                      )
                  ],
                ),
              )
    );
  }
}