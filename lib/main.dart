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
  final HomePageBody homepageBody = new HomePageBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter'),
        actions: [IconButton(
          icon: Icon(Icons.add), 
          color: Colors.white,
          onPressed: () {homepageBody.showInputFieldBoxes(context);})],
      ),
      body: homepageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {homepageBody.showInputFieldBoxes(context);})
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
            //InputFields(_expenseBloc),
            ExpenseList(expenseBloc: _expenseBloc),
          ],
        )
      );
  }

  void showInputFieldBoxes (BuildContext buildContext) {
    showModalBottomSheet(
      context: buildContext, 
      builder: (_) {
        return InputFields(_expenseBloc);
      });
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
    return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 5,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextField(
                      autofocus: true, 
                      decoration: InputDecoration(labelText: "Title"), 
                      controller: titleController,
                      onSubmitted: (inputValue) {titleController.text = inputValue;},),
                    TextField(
                      autofocus: true, 
                      decoration: InputDecoration(labelText: "Amount"), 
                      controller: amountController, 
                      keyboardType: TextInputType.number,
                      onSubmitted: (inputAmount) {amountController.text = inputAmount;},),
                    RaisedButton(
                      elevation: 8,
                      child: Text("Add Expense"),
                      textColor: Colors.purple,
                      onPressed: addNewExpense,
                      )
                  ],
                ),
              )
    );
  }

  void addNewExpense() {
    final String title = titleController.text;
    final double amount = double.parse(amountController.text);

    if (title.isEmpty|| amount < 0) {
      return;
    }
    widget.expenseBloc.eventInput.add(AddExpense(
                        Expense(
                          title: title,
                          amount: amount,
                          date: DateTime.now(),
                          id: 2,
                        )
                      ));
  }
}