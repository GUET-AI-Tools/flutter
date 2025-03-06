import 'dart:io';

import 'package:ai_tool/global/static.dart';
import 'package:ai_tool/routes/recipe_route.dart';
import 'package:ai_tool/service/ai_and_image_operations.dart';
import 'package:ai_tool/service/db_operations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:ai_tool/routes/home_route.dart'; // 主页
import 'package:ai_tool/routes/input_route.dart'; // 添加食材页面
import 'package:ai_tool/routes/display_route.dart'; // 显示食材页面
import 'package:fluttertoast/fluttertoast.dart';
import 'package:openai_dart/openai_dart.dart' as openai;

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  bool _isLoading = false;

  final List<Widget> _pages = [
    RecipeRoute(), // 食谱页
    InputRoute(), // 添加食材页面
    DisplayRoute(), // 显示食材页面
  ];

  final dbOperations = DbOperations();
  final op = OtherOperations();

  // 豆包
  final client = openai.OpenAIClient(
      apiKey: Global.doubaoApiKey,
      baseUrl: Global.doubaoBaseUrl
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut
      );
    });
  }

  void _onPageChanged(int index) {
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

      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "食谱"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "添加食材"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "显示食材"),
        ],
      ),

      floatingActionButton: _selectedIndex == 1 // 在第二个页面则出现这个按钮
          ? FloatingActionButton(
        onPressed: _isLoading
            ? () {
          // 添加时就不能再打开菜单
          Fluttertoast.showToast(msg: '正在添加……');
        }
        // 打开菜单
            : () => _showMenu(context),
        shape: CircleBorder(),

      child: _isLoading 
          ? Icon(Icons.loop) // 加载时的图标
          : Icon(Icons.add), // 可以添加食材时的图标
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
                      onPressed: () async {

                        File? image;
                        image = await op.captureImageFromCamera();

                        if (image != null) {
                          Navigator.pop(context);
                          
                          setState(() {
                            _isLoading = true;
                          });
                          
                          await op.updateFood(client, image);
                          Fluttertoast.showToast(msg: '添加完成');

                          setState(() {
                            _isLoading = false;
                          });
                        }

                        else {
                          Fluttertoast.showToast(msg: '未选择照片');
                        }


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
                      onPressed: () async {
                        File? image;
                        image = await op.pickImageFromGallery();

                        if (image != null) {
                          Navigator.pop(context);

                          setState(() {
                            _isLoading = true;
                          });

                          await op.updateFood(client, image);
                          Fluttertoast.showToast(msg: '添加完成');

                          setState(() {
                            _isLoading = false;
                          });
                        }

                        else {
                          Fluttertoast.showToast(msg: '未选择照片');
                        }

                        
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
