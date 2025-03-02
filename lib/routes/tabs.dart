import 'package:ai_tool/main.dart';
import 'package:flutter/material.dart';
// import 'package:ai_tool/routes/home_route.dart'; // 主页
import 'package:ai_tool/routes/input_route.dart'; // 添加食材页面
import 'package:ai_tool/routes/display_route.dart'; // 显示食材页面

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MyHomePage(title: '主页'), // 主页
    InputRoute(), // 添加食材页面
    DisplayRoute(), // 显示食材页面
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_pages[_selectedIndex].toString().split('(')[0]),
      //   backgroundColor: const Color.fromARGB(255, 255, 149, 83),
      // ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "主页"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "添加食材"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "显示食材"),
        ],
      ),
    );
  }
}
