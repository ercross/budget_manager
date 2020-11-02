import '../vanilla_bloc/expense_bloc.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import './expense_card.dart';
import '../expense.dart';

class ExpenseList extends StatefulWidget {
  final ExpenseBloc expenseBloc;

  ExpenseList({Key key, this.expenseBloc}) : super(key: key);

  @override
  _ExpenseList createState() => _ExpenseList(expenseBloc);
}

class _ExpenseList extends State<ExpenseList> {
  final ExpenseBloc expenseBloc;

  _ExpenseList(this.expenseBloc);

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder(
      stream: expenseBloc.stateStreamOutput,
      initialData: expenseBloc.expenses,
      builder: (BuildContext buildContext, AsyncSnapshot<List<Expense>> snapshot) {
        return Container(
          height: 300,
          child: ListView.builder(
                  itemBuilder: (buildContext, index) {
                    return ExpenseCard(snapshot.data[index]);
                  },
                  itemCount: snapshot.data.length,
          ),
        );
      }
    );
  }
}