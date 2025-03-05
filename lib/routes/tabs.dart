import 'package:ai_tool/main.dart';
import 'package:ai_tool/routes/recipe_route.dart';
import 'package:ai_tool/service/db_operations.dart';
import 'package:flutter/material.dart';
// import 'package:ai_tool/routes/home_route.dart'; // 主页
import 'package:ai_tool/routes/input_route.dart'; // 添加食材页面
import 'package:ai_tool/routes/display_route.dart';
import 'package:fluttertoast/fluttertoast.dart'; // 显示食材页面

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    RecipeRoute(), // 食谱页
    InputRoute(), // 添加食材页面
    DisplayRoute(), // 显示食材页面
  ];

  final dbOperations = DbOperations();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(_pages[_selectedIndex].toString().split('(')[0]),
        backgroundColor: const Color.fromARGB(255, 255, 149, 83),
        actions: [
          if (_selectedIndex == 1) IconButton(onPressed: () { // 清除数据库数据
            dbOperations.deleteAll();
          },
              icon: Icon(Icons.delete)
          ),

          IconButton(onPressed: () {
            Fluttertoast.showToast(
              msg: '“你这个人，真的满脑子都是自己呢”',
            );
            Navigator.pushReplacementNamed(context, 'login');
          },
              icon: Icon(Icons.exit_to_app)
          ),


        ],
      ),

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "食谱"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "添加食材"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "显示食材"),
        ],
      ),

      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(onPressed: () => _showMenu(context),
        shape: CircleBorder(),
      child: Icon(Icons.add),
      )
          : null

    ,
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))
        ),
        builder: (BuildContext context) {
          return Container(
            height: 150,
            
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      // focusColor: Color(0xFFEEFFD1),
                      color: Color.fromARGB(255, 255, 149, 83),
                      onPressed: () {

                      },
                      icon: Icon(
                        Icons.camera_alt,
                      ),
                      style: IconButton.styleFrom(
                        // backgroundColor: Color(0xFFEEFFD1),
                        iconSize: 42
                      ),

                    ),
                    Text('拍摄')
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      focusColor: Color(0xFFEEFFD1),
                      color: Color.fromARGB(255, 255, 149, 83),
                      onPressed: () {

                      },
                      icon: Icon(
                        Icons.photo,
                      ),
                      style: IconButton.styleFrom(
                        // backgroundColor: Color(0xFFEEFFD1),
                          iconSize: 42
                      ),

                    ),
                    Text('从相册选择')
                  ],
                )
              ],
            ),
          );
        }
    );
  }
}
