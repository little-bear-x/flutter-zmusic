import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_music_api/netease_music_api.dart';
import 'package:zmusic/app/home/z_api.dart';
import 'package:zmusic/app/login/z_api.dart';
import 'package:zmusic/common/res.dart';

class SplashMain extends StatefulWidget {
  @override
  _SplashMainState createState() => _SplashMainState();
}

class _SplashMainState extends State<SplashMain> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration(seconds: 2),
        () => {
              if (NeteaseMusicApi().usc.isLogined)
                {skipHomeMainSingleTask(context)}
              else
                {skipLoginMain(context)}
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 200,
              child: Image.asset(
                joinImageAssetPath('splash_decoration.png', 'splash'),
                width: 212,
              ),
            ),
            Positioned(
              child: Image.asset(
                  joinImageAssetPath('splash_decoration_2.png', 'splash')),
              width: 94,
              bottom: 20,
            )
          ],
        ),
      ),
    );
  }
}
