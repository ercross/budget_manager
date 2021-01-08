import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/current_page_index.dart';


class BottomNavBar extends StatelessWidget {
  final PageController pageController;
  
  const BottomNavBar(this.pageController);

  @override
  Widget build(BuildContext context) {
    final _currentIndex = Provider.of<CurrentPageIndex>(context);

    return BottomNavigationBar(
      currentIndex: _currentIndex.value,
      onTap: (tappedIndex) {
        pageController.jumpToPage(tappedIndex);
        _currentIndex.changeValue(tappedIndex);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).primaryColor,
      iconSize: 30,
      selectedFontSize: 15,
      unselectedFontSize: 13,
      elevation: 16,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.money_off,),
          label: "expenses",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wallet_travel, ),
          label: "income",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet, ),
          label: "budgets",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search,),
          label: "search",
        )
      ],
    );
  }
}