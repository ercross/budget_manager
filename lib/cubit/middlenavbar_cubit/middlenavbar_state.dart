part of 'middlenavbar_cubit.dart';

abstract class MiddleNavBarState extends Equatable {
  const MiddleNavBarState();

  @override
  List<Object> get props => [];
}

class MiddleNavBarInitial extends MiddleNavBarState {
  
  final MiddleNavBar middleNavBar;

  MiddleNavBarInitial () 
    :middleNavBar = MiddleNavBar(
      enableOldestDateButton: true,
      enablePreviousDayButton: false,
      enableNextDayButton: false,
      enableTodayButton: false,
      currentDate: DateTime.now(),
    );
}

class NewMiddleNavBar extends MiddleNavBarState {
  final MiddleNavBarOn page;  
  final MiddleNavBar newMiddleNavBar;

  const NewMiddleNavBar(this.newMiddleNavBar, this.page);

  @override
  List<Object> get props => [newMiddleNavBar, page];
}
