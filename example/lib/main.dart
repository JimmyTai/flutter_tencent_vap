import 'package:flutter/material.dart';

import 'package:flutter_tencent_vap/flutter_tencent_vap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VapController _controller01 = VapController();
  final VapController _controller02 = VapController();

  void _vapListener01() {
    setState(() {});
  }

  void _onTapPlay01() {
    _controller01.play(
      resource: AssetVapVideoResource("assets/anim/halloween.mp4"),
      alignment: VapViewAlignment.top,
      contentMode: VapViewContentMode.cover,
    );
  }

  void _onTapStop01() {
    _controller01.stop();
  }

  void _vapListener02() {
    setState(() {});
  }

  void _onTapPlay02() {
    _controller02.play(
      resource: AssetVapVideoResource("assets/anim/halloween.mp4"),
      contentMode: VapViewContentMode.contain,
      repeat: 2,
    );
  }

  void _onTapStop02() {
    _controller02.stop();
  }

  @override
  void initState() {
    _controller01.addListener(_vapListener01);
    _controller02.addListener(_vapListener02);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Tencent VAP'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: VapView(controller: _controller01)),
                  Positioned(
                    right: 20,
                    top: 0,
                    child: Text('${_controller01.status}'),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 50,
                    child: TextButton(onPressed: _onTapPlay01, child: Text('Play')),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 50,
                    child: TextButton(onPressed: _onTapStop01, child: Text('Stop')),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: VapView(controller: _controller02)),
                  Positioned(
                    right: 20,
                    top: 0,
                    child: Text('${_controller02.status}'),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 50,
                    child: TextButton(onPressed: _onTapPlay02, child: Text('Play')),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 50,
                    child: TextButton(onPressed: _onTapStop02, child: Text('Stop')),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller01.dispose();
    _controller02.dispose();
    super.dispose();
  }
}
