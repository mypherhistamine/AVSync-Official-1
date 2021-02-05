import 'dart:async';

import 'package:VideoSync/controllers/betterController.dart';
import 'package:VideoSync/controllers/chat.dart';
import 'package:VideoSync/controllers/funLogic.dart';
import 'package:VideoSync/controllers/roomLogic.dart';
import 'package:VideoSync/views/YTPlayer.dart';
import 'package:VideoSync/views/chat.dart';
import 'package:VideoSync/views/createRoom.dart';
// import 'package:VideoSync/views/videoPlayer.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
// import 'package:VideoSync/views/createRoom.dart';

class WelcomScreen extends StatefulWidget {
  @override
  _WelcomScreenState createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> {
  bool ytPlayerclicked = false;
  bool localPlayerClicked = false;
  TextEditingController yturl = TextEditingController();
  RoomLogicController roomLogicController = Get.put(RoomLogicController());
  RishabhController rishabhController = Get.put(RishabhController());
  ChatController chatController = Get.put(ChatController());
  FunLogic funLogic = Get.put(FunLogic());

  final double heightRatio = Get.height / 823;
  final double widthRatio = Get.width / 411;
  bool isLoading = false;
  bool picking;

  // StreamController<List<dynamic>> _userController;
  // Timer timer;

  @override
  void initState() {
    super.initState();
    chatController
        .message(firebaseId: roomLogicController.roomFireBaseId)
        .listen((event) {
      List<M> check = [];

      event.snapshot.value.forEach((key, value) {
        check.add(M(
            id: DateTime.parse(value["messageId"]),
            mesage: value["message"],
            userId: value["userId"],
            username: value["username"]));
      });

      check.sort((a, b) => (a.id).compareTo(b.id));

      Get.snackbar(
          check[check.length - 1].username, check[check.length - 1].mesage);
    });
    //   _userController = new StreamController();

    //   timer = Timer.periodic(Duration(seconds: 3), (_) async {
    //     var data = await roomLogicController.loadDetails();
    //     _userController.add(data);
    //   });
    //
  }

  // @override
  // void dispose() {
  //   _userController.close();
  //   // _userController.done;
  //   timer.cancel();
  //   super.dispose();
  // }

  // Future<void> filePick() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   FilePickerResult result = await FilePicker.platform.pickFiles(
  //       // type: FileType.media,
  //       // allowMultiple: false,
  //       // allowedExtensions: ['.mp4'],
  //       withData: false,
  //       // allowCompression: true,
  //       withReadStream: true,
  //       onFileLoading: (status) {
  //         if (status.toString() == "FilePickerStatus.picking") {
  //           setState(() {
  //             picking = true;
  //           });
  //         } else {
  //           setState(() {
  //             picking = false;
  //           });
  //         }
  //       });

  //   // roomLogicController.bytes.obs.value = result.files[0];
  //   roomLogicController.localUrl = result.files[0].path;

  //   // print('testUrl: $testUrl');
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // void bottomSheet() {
  //   Get.bottomSheet(Container(
  //     color: Colors.white,
  //     height: 200,
  //     width: 200,
  //     child: isLoading
  //         ? RaisedButton(
  //             onPressed: () async {
  //               await filePick();
  //               Get.to(NiceVideoPlayer());
  //             },
  //             child: Text("Pick Video"),
  //           )
  //         : Center(
  //             child: Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //           ),
  //   ));
  // }
  void snackbar(String name, String message) {
    Get.snackbar(name, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: !(roomLogicController.adminKaNaam.obs.value ==
                  roomLogicController.userName.obs.value)
              ? Icon(Icons.exit_to_app_rounded)
              : Icon(Icons.delete),
          onPressed: () {
            Get.defaultDialog(
                title: !(roomLogicController.adminKaNaam.obs.value ==
                        roomLogicController.userName.obs.value)
                    ? 'Leave Room'
                    : 'Delete Room',
                confirm: RaisedButton(
                    child: Text('Yes'),
                    onPressed: () {
                      if (!(roomLogicController.adminKaNaam.obs.value ==
                          roomLogicController.userName.obs.value)) {
                        rishabhController.userLeaveRoom(
                          firebaseId: roomLogicController.roomFireBaseId,
                          userId: roomLogicController.userId,
                        );
                      } else {
                        roomLogicController.adminDeleteRoom(
                            firebaseId: roomLogicController.roomFireBaseId);
                      }

                      Get.off(CreateRoomScreen());
                    }),
                cancel: RaisedButton(
                    child: Text('No'),
                    onPressed: () {
                      Get.back();
                    }),
                content: !(roomLogicController.adminKaNaam.obs.value ==
                        roomLogicController.userName.obs.value)
                    ? Text('Do you want to leave the room ? ')
                    : Text('Do you want to delete the room ? '));
          },
        ),
        backgroundColor: Color(0xff292727),
      ),
      // appBar: AppBar(),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        //width: 380 * widthRatio,
        child: Drawer(
          child: ChattingPlace(snackbar: snackbar),
        ),
      ),
      backgroundColor: Color(0xff292727),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Text('Users: '),
            // SizedBox(height: 40),
            Text(
              'Room',
              style: TextStyle(color: Colors.white, fontSize: 50),
            ),
            // StreamBuilder(
            //   stream: rishabhController.tester(
            //       firebaseId: roomLogicController.roomFireBaseId),
            //   builder: (context, snapshot) {
            //     return Container(
            //       height: 100,
            //       child: ListView.builder(
            //         itemBuilder: (ctx, i) {
            //           return Text('Rishabh');
            //         },
            //         itemCount:
            //             snapshot.data.snapshot.value.values.toList().length,
            //       ),
            //     );

            //     // return RaisedButton(onPressed: () {
            //     //   print(snapshot.data.snapshot.value.values.toList());

            //     //   rishabhController.userLeaveRoom(
            //     //       firebaseId: '-MScDAopj96DypuMqyNh', userId: '2312312');
            //   },
            // ),
            SizedBox(
              height: 40 * heightRatio,
            ),
            Container(
              height: 320 * heightRatio,
              width: 300 * widthRatio,
              // decoration:
              //     BoxDecoration(border: Border.all(color: Colors.black)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 250 * heightRatio,
                      width: 280 * widthRatio,
                      child: Card(
                        color: Color.fromARGB(200, 60, 60, 60),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25 * widthRatio),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 30),
                              child: InkWell(
                                onTap: () {
                                  // Get.defaultDialog(title: 'Rishabn',content: Text('Enter '));
                                  Get.bottomSheet(
                                    Container(
                                      color: Colors.white,
                                      width: double.infinity,
                                      height: heightRatio * 250,
                                      child: Card(
                                        elevation: 10,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 20),
                                            Text('Enter the Youtube Link',
                                                style: TextStyle(fontSize: 20)),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: heightRatio * 20),
                                              height: heightRatio * 80,
                                              width: widthRatio * 300,
                                              child: TextField(
                                                controller: yturl,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: heightRatio * 10),
                                              child: RaisedButton(
                                                shape: StadiumBorder(),
                                                onPressed: () {
                                                  roomLogicController
                                                      .ytURL.value = yturl.text;
                                                  Get.to(YTPlayer());
                                                },
                                                child: Text('Play'),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'lib/assets/svgs/youtubeplayer.svg',
                                      width: 70 * heightRatio,
                                      height: 70 * widthRatio,
                                    ),
                                    SizedBox(width: 10 * widthRatio),
                                    Text(
                                      'Youtube',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 42.5),
                              child: InkWell(
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'lib/assets/svgs/localplayer.svg',
                                      width: 40 * widthRatio,
                                      height: 40 * heightRatio,
                                    ),
                                    SizedBox(width: 25 * widthRatio),
                                    Text(
                                      'Local Media',
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20 * heightRatio),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                children: [
                                  StreamBuilder(
                                      stream:
                                          roomLogicController.adminBsdkKaNaam(
                                              firebaseId: roomLogicController
                                                  .roomFireBaseId),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Text(
                                            '${snapshot.data.snapshot.value}',
                                            style: TextStyle(fontSize: 30),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text('Error');
                                        }
                                        return Text('');
                                      }),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 0),
                                    child: SvgPicture.asset(
                                      'lib/assets/svgs/crown.svg',
                                      height: 25 * heightRatio,
                                      width: 25 * widthRatio,
                                      color: Colors.orange,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10 * heightRatio),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: GetX<RoomLogicController>(
                                  builder: (controller) {
                                return Text(
                                    'Room no: ${controller.roomId.obs.value} ',
                                    style: TextStyle(fontSize: 20));
                              }),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SvgPicture.asset('lib/assets/svgs/movie.svg',
                        width: 120 * widthRatio, height: 120 * heightRatio),
                  )
                ],
              ),
            ),
            SizedBox(height: 40 * heightRatio),
            Expanded(
              child: StreamBuilder(
                stream: rishabhController.tester(
                    firebaseId: roomLogicController.roomFireBaseId),
                builder: (ctx, event) {
                  if (event.hasData) {
                    // Future.delayed(
                    //     Duration(seconds: 2),
                    //     () => {
                    //           Get.snackbar(
                    //               "",
                    //               event.data.snapshot.value[
                    //                       event.data.snapshot.value.length -
                    //                           1]['name'] +
                    //                   "joined!")
                    //         });

                    return Container(
                      // height: 100,
                      width: 300 * widthRatio,
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowGlow();
                        },
                        child: ListView.separated(
                          separatorBuilder: (ctx, i) {
                            return SizedBox(
                              height: 20 * heightRatio,
                            );
                          },
                          itemBuilder: (ctx, i) {
                            print('chut: ${event.data.snapshot.value}');

                            return CustomNameBar(
                              event: event,
                              index: i,
                              widthRatio: widthRatio,
                              heightRatio: heightRatio,
                              controller: funLogic,
                            );
                          },
                          itemCount:
                              event.data.snapshot.value.values.toList().length,
                        ),
                      ),
                    );
                  }

                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNameBar extends StatelessWidget {
  final AsyncSnapshot event;
  final int index;
  final double heightRatio;
  final double widthRatio;
  final FunLogic controller;
  CustomNameBar({
    this.event,
    this.index,
    this.heightRatio,
    this.widthRatio,
    this.controller,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Card(
        color: Color.fromARGB(200, 60, 60, 60),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        // width: 20,
        // height: 70,
        // color: Colors.white,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(25), color: Colors.white),

        child: Center(
          child: Text(
            '${event.data.snapshot.value.values.toList()[index]['name']}',
            style: TextStyle(fontSize: 30, color: controller.randomColorPick),
          ),

          // InkWell(
          //   onTap: () {
          //     Get.showSnackbar(GetBar(
          //       title: 'Rishabh',
          //       message: 'Hi I am Rishabh',
          //       duration: Duration(seconds: 2),
          //     ));
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 30),
          //     child: SvgPicture.asset(
          //       'lib/assets/svgs/emoji.svg',
          //       width: 30 * widthRatio,
          //       height: 30 * heightRatio,
          //       color: Color(0xffF15757),
          //     ),
          //   ),
          //)
        ),
      ),
    );
  }
}
