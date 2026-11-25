import 'package:flutter/material.dart';

const Color dashboardLightBackground = Color(0xFFF6FBF8);
const Color dashboardDarkBackground = Color(0xFF06110D);

Color dashboardBackgroundColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? dashboardDarkBackground
    : dashboardLightBackground;
