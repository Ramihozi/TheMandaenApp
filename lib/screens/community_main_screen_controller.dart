import 'package:the_mandean_app/screens/community_chat_screen.dart';
import 'package:the_mandean_app/screens/community_home_screen.dart';
import 'package:the_mandean_app/screens/community_profile.dart';
import 'package:the_mandean_app/screens/community_add_post_screen.dart';
import 'package:get/get.dart';


class MainScreenController extends GetxController{

  RxInt selectedIndex = 0.obs;

  final widgetOptions =  [
    HomeScreen(),
    AddPostScreen(),
    const ChatScreen(),
    ProfileScreen()
  ];

  void onItemTapped(int index) {
    selectedIndex.value = index;
    //log(selectedIndex.string);
  }

}