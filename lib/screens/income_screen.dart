import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/income_bar_chart.dart';
import '../widgets/income_tiles.dart';
import '../cubit/middlenavbar_cubit/middlenavbar_cubit.dart';

class IncomePage extends StatelessWidget {
  static const String routeName = "/income";

  const IncomePage();

  static BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    ctx = context;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight =
        mediaQuery.size.height - statusBarHeight - appBarHeight;

    return Scaffold(
      body: BlocProvider<MiddleNavBarCubit>(
        create: (context) => MiddleNavBarCubit(),
        child: SafeArea(
          child: Column(
            children: [
              Container(
          height: displayAreaHeight * 0.33,
          child: IncomeBarChart(displayAreaHeight)),
        Container(
        height: displayAreaHeight * 0.1,
        margin: EdgeInsets.only(bottom: 1, right: 4, left: 4),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).accentColor),
            borderRadius: BorderRadius.all(Radius.circular(6))),
        child: BlocBuilder<MiddleNavBarCubit, MiddleNavBarState>(
          builder: (_, state) {
            if (state is MiddleNavBarInitial) return state.middleNavBar;

            if (state is NewMiddleNavBar && state.page == MiddleNavBarOn.incomePage) {
              return state.newMiddleNavBar;
            }
            
            return Text("This is an error you shouldn't see"); //would never be reached, anyways
          },
        ),
        ),
        Expanded(child: IncomeTiles()),
            ],),),
      ),
      
    );
  }
}