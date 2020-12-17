import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final Widget _title = Container(
    alignment: Alignment.bottomCenter,
    padding: EdgeInsets.all(15),
    height: 100,
    width: double.infinity,
    decoration: BoxDecoration(color: Color.fromRGBO(171, 39, 79, 1)),
    child: Text(
      "Menu",
      style: TextStyle(
          fontSize: 25, color: Colors.white, fontWeight: FontWeight.w900),
    ),
  );

  Widget _buildDrawerItem(String itemName, Icon icon, Function onTap) {
    return ListTile(
      onTap: onTap,
      leading: icon,
      title: Text(
        itemName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _title,
          SizedBox(height: 10),
          _buildDrawerItem("search", Icon(Icons.search), (){}),
          _buildDrawerItem("make budget", Icon(Icons.money), (){}),
          _buildDrawerItem("load chart", Icon(Icons.bar_chart), (){}),
          _buildDrawerItem("statistics", Icon(Icons.report), (){}),
          _buildDrawerItem("select currency", Icon(Icons.money_off_csred_sharp), (){}),
          _buildDrawerItem("about", Icon(Icons.not_interested), (){}),
          Expanded(child: Container(decoration: BoxDecoration(color: Theme.of(context).primaryColor)))
        ],
      ),
    );
  }
}
