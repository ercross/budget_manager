import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trackIt/repository/repository.dart';
import 'package:trackIt/widgets/middle_nav_bar.dart';

part 'middlenavbar_state.dart';

enum MiddleNavBarOn {expensePage, incomePage} ///must align with the ordering of ExpensePage PageView children

class MiddleNavBarCubit extends Cubit<MiddleNavBarState> {
  MiddleNavBarCubit() : super(MiddleNavBarInitial());

  //provides access to the date on the navBar
  static DateTime expensePageDateF = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  static DateTime incomePageDateF = DateTime(DateTime.now().year, DateTime.now().month);

  
  void emitInitial(MiddleNavBarOn page) {
    expensePageDateF = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    incomePageDateF = DateTime(DateTime.now().year, DateTime.now().month);
    emit(MiddleNavBarInitial());
  }

  void emitNew (MiddleNavBar newMiddleNavBar, MiddleNavBarOn page) async {
    if (page == MiddleNavBarOn.expensePage) {
      expensePageDateF = newMiddleNavBar.currentDate;
      newMiddleNavBar.oldestDate = Repository.repository.oldestExpenseDate;
    }
    if (page == MiddleNavBarOn.incomePage) {
      incomePageDateF = newMiddleNavBar.currentDate;
      newMiddleNavBar.oldestDate = Repository.repository.oldestIncomeDate;
    }
    emit(NewMiddleNavBar(newMiddleNavBar, page));
  }
}
