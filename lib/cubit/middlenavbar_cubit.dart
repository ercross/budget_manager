import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trackIt/widgets/middle_nav_bar.dart';

part 'middlenavbar_state.dart';

class MiddleNavBarCubit extends Cubit<MiddleNavBarState> {
  MiddleNavBarCubit() : super(MiddleNavBarInitial());

  //provides access to the date on the navBar
  static DateTime currentDate = DateTime.now();

  Future<void> emitNew (MiddleNavBar newMiddleNavBar) async {
    currentDate = newMiddleNavBar.currentDate;
    emit(NewMiddleNavBar(newMiddleNavBar));
  }
}
