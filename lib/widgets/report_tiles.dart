import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/report/report_cubit.dart';
import '../widgets/report_card.dart';
import '../models/report.dart';

class ReportTiles extends StatelessWidget {
  final double pageHeight;

  ReportTiles(this.pageHeight);
  

  BuildContext ctx;
  @override
  Widget build(BuildContext context) {
    ctx = context;

    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {

        if (state is DailyReports) {
          return Column(
            children: [
              _buildPageTitle(ReportType.daily),
              Expanded(child: _buildList(context, state.dailyReports))
            ],
          );
        }

        if (state is WeeklyReports) {
          return Column(
            children: [
              _buildPageTitle(ReportType.weekly),
              Expanded(child: _buildList(context, state.weeklyReports)),
            ],
          );
        }

        if (state is MonthlyReports) {
          return Column(
            children: [
              _buildPageTitle(ReportType.monthly),
              Expanded(child: _buildList(context, state.monthlyReports)),
            ],
          );
        }

        if (state is LastYearReport) {
          if (state.lastYearReport == null) {
            return Column(
              children: [
                _buildPageTitle(ReportType.yearly),
                Expanded(
                  child: _buildList(context, null),
                )
              ],
            );
          }
          else return Column(
            children: [
              _buildPageTitle(ReportType.yearly),
              Expanded(
                child: _buildList(context, [state.lastYearReport]),
              )
            ],
          );
        }

        if (state is ReportInitial) {
          return Column(
          children: [
            _buildPageTitle(ReportType.daily),
            Expanded(
              child: _buildList(context, state.dailyReports),
            )
          ],
        );
        }
        return Center(child: Text("This is an error page you shouldn't see"));
      },
    );
  }

  Widget _buildEmptyList(BuildContext context) {
    return Center(
        child: Text("Report Not Ready. Please check back",
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).accentColor.withOpacity(0.5),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold)));
  }

  Widget _buildPageTitle(ReportType reportType) {
    switch (reportType) {
      case ReportType.daily:
        return _buildTitleText("Daily Reports");
        break;
      case ReportType.weekly:
        return _buildTitleText("Weekly Reports");
        break;
      case ReportType.monthly:
        return _buildTitleText("Monthly Reports");
        break;
      case ReportType.yearly:
        return _buildTitleText("Last Year Report");
        break;
      default:
        return Text("This is an error you shouldn't see");
    }
  }

  Widget _buildTitleText(String titleText) {
    return Container(
        height: pageHeight * 0.1,
        color: Theme.of(ctx).primaryColor,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        margin: EdgeInsets.only(bottom: 8),
        child: Center(
            child: Text(
          titleText,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        )));
  }

  Widget _buildList(BuildContext context, List<Report> reports) {
    if (reports == null || reports.isEmpty) {
      return _buildEmptyList(context);
    }
    Set<Report> temp = Set<Report>();
    temp = reports.toSet();
    reports = temp.toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return ReportCard(reports[index]);
        },
      ),
    );
  }
}
