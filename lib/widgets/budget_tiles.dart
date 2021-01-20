import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/budget/budget_cubit.dart';
import '../models/budget.dart';
import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../widgets/budget_card.dart';

class BudgetTiles extends StatefulWidget {
  final double pageHeight;

  BudgetTiles(this.pageHeight);

  @override
  _BudgetTilesState createState() => _BudgetTilesState();
}

class _BudgetTilesState extends State<BudgetTiles> {

  List<Budget> dailyBudgets = List<Budget>();
  List<Budget> weeklyBudgets = List<Budget>();
  List<Budget> monthlyBudgets = List<Budget>();
  Budget thisYearBudget;

  void initState() { 
    super.initState();
    Repository.repository.fetch(BudgetTable.tableName).then((maps){
      List<Budget> allBudgets = Budget.fromMaps(maps);
      setState(() {    
        allBudgets.forEach((budget) {
          switch (budget.type) {
            case BudgetType.daily:
              dailyBudgets.add(budget);
              break;
            case BudgetType.weekly:
              weeklyBudgets.add(budget);
              break;
            case BudgetType.monthly:
              monthlyBudgets.add(budget);
              break;
            case BudgetType.yearly:
              thisYearBudget = budget;
              break;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {

        if (state is WeeklyBudgets) 
          return Column(
            children: [
              _buildPageTitle(context, BudgetType.weekly),
              _buildBudgetTiles(context, weeklyBudgets)
            ],
          );

        if (state is MonthlyBudgets) 
          return Column(
            children: [
              _buildPageTitle(context, BudgetType.monthly),
              _buildBudgetTiles(context, monthlyBudgets)
            ],
          );

        if (state is ThisYearBudget)
          if (thisYearBudget == null) {
            return Column(
              children: [
                _buildPageTitle(context, BudgetType.yearly),
                _buildBudgetTiles(context, null)
              ],
            );  
          }
          else return Column(
            children: [
              _buildPageTitle(context, BudgetType.yearly),
              _buildBudgetTiles(context, [thisYearBudget])
            ],
          );

        if (state is BudgetAdded) 
          return _addNewBudget(context, state);
        
        return Column(
            children: [
              _buildPageTitle(context, BudgetType.daily),
              _buildBudgetTiles(context, dailyBudgets)
            ],
          );
      }
    );
  }

  Widget _addNewBudget(BuildContext ctx, BudgetAdded state) {
    switch (state.budget.type) {
            case BudgetType.daily:
              dailyBudgets.add(state.budget);
              return Column(
                children: [
                  _buildPageTitle(ctx, BudgetType.daily),
                  _buildBudgetTiles(ctx, dailyBudgets)
                ],
              );
              break;

            case BudgetType.weekly:
              weeklyBudgets.add(state.budget);
              return Column(
                children: [
                  _buildPageTitle(ctx, BudgetType.weekly),
                  _buildBudgetTiles(ctx, weeklyBudgets)
                ],
              );
              break;

            case BudgetType.monthly:
              monthlyBudgets.add(state.budget);
              return Column(
                children: [
                  _buildPageTitle(ctx, BudgetType.monthly),
                  _buildBudgetTiles(ctx, monthlyBudgets)
                ],
              );
              break;

            case BudgetType.yearly:
              thisYearBudget= state.budget;
              return Column(
                children: [
                  _buildPageTitle(ctx, BudgetType.yearly),
                  _buildBudgetTiles(ctx, [thisYearBudget])
                ],
              );
              break;

            default: 
              return Text("This is an error page you shouldn't see");
          }
  }

  Widget _buildBudgetTiles(BuildContext ctx, List<Budget> budgets) {
    if (budgets == null || budgets.isEmpty) {
      return Expanded(
        child: Center (child: Text("No budgets Added", style: TextStyle(
    color:Theme.of(ctx).accentColor.withOpacity(0.5), fontStyle: FontStyle.italic, fontSize: 20,
    fontWeight: FontWeight.bold)),),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: budgets.length,
          itemBuilder: (_, index) => BudgetCard(
            budget: budgets[index],
            delete: (budget) => _delete(ctx, budgets[index]),
          )
        ),
      ),
    );
  }

  Widget _buildPageTitle (BuildContext ctx, BudgetType type) {
    switch (type) {
      case BudgetType.daily:
        return _buildTitleText(ctx, "daily budgets");
        break;
      case BudgetType.weekly:
        return _buildTitleText(ctx, "weekly budgets");
        break;
      case BudgetType.monthly:
        return _buildTitleText(ctx, "monthly budgets");
        break;
      case BudgetType.yearly:
        return _buildTitleText(ctx, "${DateTime.now().year} budget");
        break;
      default: 
        return Text("This is an error you shouldn't see");
    }
  }

  Widget _buildTitleText (BuildContext context, String titleText) {
    return Container(
      height: widget.pageHeight * 0.1,
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Center(child: Text(titleText, style: TextStyle(fontSize: 20, 
                                          color:Colors.white, fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),))
    );
  }

  void _delete(BuildContext ctx, Budget budget) {
    switch(budget.type) {
      case BudgetType.daily:
        setState(() {dailyBudgets.remove(budget);});
        break;
      case BudgetType.weekly:
        setState(() {weeklyBudgets.remove(budget);});
        break;
      case BudgetType.monthly:
        setState(() {monthlyBudgets.remove(budget);});
        break;
      case BudgetType.yearly:
        setState(() {thisYearBudget = null;});
        break;
    }
    BlocProvider.of<BudgetCubit>(ctx).deleteBudget(budget.id);
  }
}