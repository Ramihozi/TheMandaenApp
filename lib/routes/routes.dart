import 'package:flutter/material.dart';
import 'package:the_mandean_app/screens/community_comment_screen.dart';
import 'package:the_mandean_app/screens/community_story_view_full_screen.dart';
import 'package:the_mandean_app/screens/login_screen.dart';
import 'package:the_mandean_app/screens/main_screen.dart';
import 'package:the_mandean_app/screens/onboarding_screen.dart';
import 'package:the_mandean_app/screens/register_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

// I'm using Getx for state management

List<GetPage<dynamic>> getPages() {
  return [
    GetPage(name: "/", page: ()=>  OnBoardingScreen()),
    GetPage(name: "/login_screen", page: ()=>  LoginScreen()),
    GetPage(name: "/register_screen", page: ()=>  RegisterScreen()),
    GetPage(name: "/main_screen", page: ()=>  MainScreen()),
    GetPage(name: "/comments_screen", page: ()=>  CommentsScreen()),
    GetPage(name: "/story_view_screen", page: ()=>  StoryViewFullScreen()),
  ];
}