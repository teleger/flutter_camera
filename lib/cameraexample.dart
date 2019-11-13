import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'displaypic.dart';

class CameraExampleHome extends StatefulWidget{
  final CameraDescription camera;

  const CameraExampleHome({Key key,
  @required this.camera,}) : super(key : key);


  @override
  State createState() {
    return _CameraExampleHome();
  }

}


void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHome extends State<CameraExampleHome> with WidgetsBindingObserver {

  AppLifecycleState state;

  CameraController _controller;
  Future<void> _initializeControlerFuture;

  VoidCallback videoPlayerListener;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
//    if(state == AppLifecycleState.paused){//不可见并不能响应用户的输入，但是在后台继续活动中
//      print("--------------------paused");
//      _controller.pauseVideoRecording();
//    }
//    if(state == AppLifecycleState.inactive){//处在并不活动状态，无法处理用户响应
//      print("--------------------inactive");
//      _controller.stopVideoRecording();
//    }
//    if(state == AppLifecycleState.resumed){//可见并能响应用户的输入
//      print("--------------------resumed");
//      _controller.resumeVideoRecording();
//    }

  }


  @override
  void didChangeDependencies() {
    print('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(CameraExampleHome oldWidget) {
    print('组件状态改变：didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    print('移除时：deactivate');
    super.deactivate();
  }


  @override
  Widget build(BuildContext context) {

    Future<bool> _onWillPop() {
      return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('Are you sure?'),
          content: new Text('Do you want to exit an App'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('No'),
            ),
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                _controller.dispose();//在选择 为yes 时,释放相机资源
                },
              child: new Text('Yes'),
            ),
          ],
        ),
      ) ?? false;
    }

    return new WillPopScope(
        child: new Scaffold(
            appBar: AppBar(title: Text('Take a picture')),
            body: FutureBuilder<void>(
            future: _initializeControlerFuture,
            builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              return CameraPreview(_controller);
            }else{
              return Center(child: CircularProgressIndicator());
            }
          }
        ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.camera_alt),
            onPressed: () async {
              try{
                await _initializeControlerFuture;
                final path = join((await getTemporaryDirectory()).path,
                  '${DateTime.now()}.png',);

                await _controller.takePicture(path);

                Navigator.push(
                    context,
                    MaterialPageRoute(builder:
                        (context)=> DisplayPictureScreen(imagePath: path),));
              }catch(e){
                print(e);
              }
            },
        ),
    ),
    onWillPop: _onWillPop);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    print('初始化：initState');
     _controller =  CameraController(widget.camera,
                  ResolutionPreset.medium,);

     _initializeControlerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

}