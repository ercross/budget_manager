import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../widgets/middle_nav_bar.dart';

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
    switch (page) {
      case MiddleNavBarOn.expensePage:
        expensePageDateF = newMiddleNavBar.currentDate;
        emit(NewMiddleNavBar(newMiddleNavBar, MiddleNavBarOn.expensePage));
        break;
      case MiddleNavBarOn.incomePage:
        incomePageDateF = newMiddleNavBar.currentDate;
        emit(NewMiddleNavBar(newMiddleNavBar, MiddleNavBarOn.incomePage));
    }    
  }
}
