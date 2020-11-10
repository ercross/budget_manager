import '../vanilla_bloc/expense_bloc.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import './expense_card.dart';
import '../models/expense.dart';

class ExpenseList extends StatefulWidget {
  final ExpenseBloc expenseBloc;

  ExpenseList({Key key, this.expenseBloc}) : super(key: key);

  @override
  _ExpenseList createState() => _ExpenseList();
}

class _ExpenseList extends State<ExpenseList> {

  final Center noExpensesAdded = const Center(
      child: Text("No Expenses Added Yet", style: TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(171, 39, 79, 0.4),
        fontWeight: FontWeight.bold
      ),),
    );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.expenseBloc.stateStreamOutput,
        initialData: widget.expenseBloc.expenses,
        builder: (BuildContext buildContext, AsyncSnapshot<List<Expense>> snapshot) {

          if (widget.expenseBloc.expenses.isEmpty) { 
            return noExpensesAdded;
            }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (buildContext, index) {
              return ExpenseCard(snapshot.data[index], widget.expenseBloc);
            },
          );
        });
  }
}
