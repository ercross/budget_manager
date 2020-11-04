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

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: 300,
      child: StreamBuilder(
        stream: widget.expenseBloc.stateStreamOutput,
        initialData: widget.expenseBloc.expenses,
        builder: (BuildContext buildContext, AsyncSnapshot<List<Expense>> snapshot) {
            return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (buildContext, index) {
                      return ExpenseCard(snapshot.data[index]);
                    },
            );
        }
      ),
    );
  }
}