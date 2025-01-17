// import 'dart:async';

import 'dart:async';
import 'dart:ui';
import 'package:VideoSync/controllers/betterController.dart';
import 'package:VideoSync/controllers/chat.dart';
// import 'package:VideoSync/controllers/funLogic.dart';
import 'package:VideoSync/controllers/roomLogic.dart';
import 'package:VideoSync/controllers/themeData.dart';
import 'package:VideoSync/controllers/ytPlayercontroller.dart';
import 'package:VideoSync/views/video%20players/anyPlayer.dart';
// import 'package:VideoSync/views/YTPlayerOne.dart';
import 'package:VideoSync/widgets/chat_list_view.dart';
import 'package:VideoSync/widgets/chat_send_.dart';
import 'package:VideoSync/widgets/custom_button.dart';
// import 'package:VideoSync/widgets/chat_widget.dart';
// import 'package:VideoSync/widgets/custom_button.dart';
import 'package:VideoSync/widgets/custom_namebar.dart';
import '../webShow.dart';
import 'package:clipboard/clipboard.dart';
//import 'package:VideoSync/widgets/custom_namebar.dart';
import 'package:VideoSync/widgets/custom_text.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:VideoSync/views/welcome_Screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import 'chat.dart';

class YTPlayer extends StatefulWidget {
  @override
  _YTPlayerState createState() => _YTPlayerState();
}

// String url;

RoomLogicController roomLogicController = Get.put(RoomLogicController());
ChatController chatController = Get.put(ChatController());
TextEditingController yturl = TextEditingController();
YTStateController ytStateController = Get.put(YTStateController());
RishabhController rishabhController = Get.put(RishabhController());

CustomThemeData themeController = Get.put(CustomThemeData());
ScrollController chatScrollController = ScrollController();
AnimationController animationController;
final double heightRatio = Get.height / 823;
final double widthRatio = Get.width / 411;
int buttonPressed = 1;

// int position = 0;

class _YTPlayerState extends State<YTPlayer> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController yturl = TextEditingController();
  YoutubePlayerController controller = YoutubePlayerController(
    initialVideoId:
        YoutubePlayer.convertUrlToId(roomLogicController.ytURL.value),
    flags: YoutubePlayerFlags(
        autoPlay: false,
        // hideControls: !(roomLogicController.adminKaNaam.obs.value ==
        //         roomLogicController.userName.obs.value)
        //     ? true
        //     : false,
        hideControls: true,
        mute: false,
        disableDragSeek: false,

        // hideControls: true,
        hideThumbnail: true),
  );
  int timestamp = 0;
  // bool dontHideControlsBool = true;
  bool hideUI = false;
  double animatedHeight = 30;
  bool shoSpeedWidget = false;
  bool playerIsUser = true;
  int selectedRadio;
  Duration videoLength;

  TextEditingController chatTextController = TextEditingController();
  // final GlobalKey globalKey = GlobalKey();

  //receiver side , the user is getting the sync info from the cloud
  @override
  void initState() {
    super.initState();
    roomLogicController
        .adminIdd(firebaseId: roomLogicController.roomFireBaseId)
        .listen((event) {
      print("adminId");
      roomLogicController.adminId.value = event.snapshot.value;
    });

    var firebaseDatabase = FirebaseDatabase.instance.reference();
    firebaseDatabase
        .child('Rooms')
        .child(roomLogicController.roomFireBaseId.obs.value)
        .child('timeStamp')
        .onValue
        .listen((event) {
      if (!(roomLogicController.adminId.value ==
          roomLogicController.userId.obs.value)) {
        if ((controller.value.position.inSeconds - event.snapshot.value)
                .abs() >=
            4) {
          controller.seekTo(Duration(seconds: event.snapshot.value));
        }
      }
    });


  //updtaes the ytlink to be played
    roomLogicController
        .ytlink(firebaseId: roomLogicController.roomFireBaseId)
        .listen((event) {
      roomLogicController.ytURL.value = event.snapshot.value;
      controller
          .load(YoutubePlayer.convertUrlToId(roomLogicController.ytURL.value));
    });


    //checks play/pause state and according plays and pauses the host's video
    firebaseDatabase
        .child('Rooms')
        .child(roomLogicController.roomFireBaseId.obs.value)
        .child('isPlayerPaused')
        .onValue
        .listen((event) {
      if (event.snapshot.value) {
        controller.pause();
        print(roomLogicController.adminId.value);
        // print(event.snapshot.value);
      } else {
        controller.play();
      }
    });

    //checks the playbackspeed from the server and changes for the host if changed on the server
    firebaseDatabase
        .child('Rooms')
        .child(roomLogicController.roomFireBaseId.obs.value)
        .child('playBackSpeed')
        .onValue
        .listen((event) {
      print('Speed ${event.snapshot.value}');
      if (!(roomLogicController.adminId.value ==
          roomLogicController.userId.obs.value)) {
        if (event.snapshot.value == 0.23)
          controller.setPlaybackRate(1.0);
        else if (event.snapshot.value == 2.45)
          controller.setPlaybackRate(2);
        else
          controller.setPlaybackRate(event.snapshot.value);
      }
    });


    //for chat ui updation 
    listenToTextInputStateChanges();
  }

  void listenToTextInputStateChanges() {
    chatTextController.addListener(() {
      print("TextState: ${chatTextController.text}");
      if (chatTextController.text == "") {
        chatController.isTextEmpty.value = true;
      } else {
        chatController.isTextEmpty.value = false;
      }
      print('TextState: ${chatController.isTextEmpty}');
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    chatTextController.dispose();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {
        controller.pause();
        Navigator.pop(context);
        // controller.seekTo(Duration(seconds: 0));
        Navigator.pop(context);
        return true;
      },
    );

    Widget cancel = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
        // controller.seekTo(Duration(seconds: timestamp));
        return false;
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Do you want to leave the screen"),
      actions: [okButton, cancel],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<dynamic> showSpeedAlertDialog() {
    return Get.defaultDialog(
      titleStyle: TextStyle(color: Colors.white, fontSize: 12),
      backgroundColor: Color(0xff292727),
      title: 'Speed',
      content: Obx(
        () => Container(
          width: 200,
          // height: 170,
          child: SliderTheme(
            data: SliderThemeData(
                activeTrackColor: Colors.greenAccent,
                activeTickMarkColor: Colors.green,
                showValueIndicator: ShowValueIndicator.always),
            child: Slider(
              min: 1.0,
              max: 2.0,
              divisions: 10,
              label: '${rishabhController.playBackSpeedValue.value}',
              value: rishabhController.playBackSpeedValue.value,
              onChanged: (value) {
                rishabhController.playBackSpeedValue.value = value;
                controller.setPlaybackRate(value);
                rishabhController.changePlayBackSpeed(
                    roomLogicController.roomFireBaseId,
                    rishabhController.playBackSpeedValue.value);
              },
            ),
          ),
        ),
      ),
      cancel: CustomButton(
        function: () {
          Get.back();
        },
        buttonColor: Colors.blueAccent,
        content: 'Back',
        contentSize: 10,
        cornerRadius: 10,
        height: 30,
        textColor: Colors.white,
        width: 100,
      ),
    );
  }

  youWebShe() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: WebShow());
        });
  }

  youBotShe() {
    // Get.bottomSheet(
    //   Container(
    //     width: double.infinity,
    //     height: heightRatio * 250,
    //     child: Container(
    //       color: Colors.white,
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           SizedBox(height: 20),
    //           Text('Enter the Youtube Link', style: TextStyle(fontSize: 20)),
    //           Container(
    //             margin: EdgeInsets.only(top: heightRatio * 20),
    //             height: heightRatio * 80,
    //             width: widthRatio * 300,
    //             child: TextField(
    //               controller: yturl,
    //               onChanged: (String value) {
    //                 setState(() {
    //                   ytStateController.checkYotutTubeUrl(ytURl: value);
    //                 });
    //               },
    //               cursorColor: Colors.red,
    //               decoration: InputDecoration(
    //                 border: OutlineInputBorder(
    //                   borderRadius: BorderRadius.circular(20),
    //                 ),
    //                 focusedBorder: OutlineInputBorder(
    //                     borderSide: new BorderSide(
    //                       color: Colors.red,
    //                       width: 1,
    //                     ),
    //                     borderRadius: BorderRadius.all(Radius.circular(20))),
    //               ),
    //             ),
    //           ),
    //           Container(
    //             margin: EdgeInsets.only(top: heightRatio * 10),
    //             child: Obx(() => ytStateController.linkValidity.value ==
    //                     LinkValidity.Valid
    //                 ? RaisedButton(
    //                     color: Colors.green,
    //                     shape: StadiumBorder(),
    //                     onPressed: () async {
    //                       yturl.text = roomLogicController.ytURL.value;

    //                       Navigator.pop(context);
    //                       await Future.delayed(Duration(seconds: 1));
    //                       //send the ytlink to the db
    //                       roomLogicController.sendYtLink(
    //                           ytlink: roomLogicController.ytURL.value);
    //                       roomLogicController.sendYtStatus(status: 'loaded');

    //                       controller.load(YoutubePlayer.convertUrlToId(
    //                           roomLogicController.ytURL.value));

    //                       //send the message of new youtube link added
    //                       chatController.sendMessageCloudFireStore(
    //                         message:
    //                             "${roomLogicController.userName} has started the video\n${roomLogicController.ytURL.value}",
    //                         roomId: roomLogicController.roomFireBaseId,
    //                         sentBy: "YT Link",
    //                         tag: "YTLINK",
    //                         userId: "696969",
    //                         status: "joined",
    //                       );
    //                       // Navigator.pop(
    //                       //     context);
    //                     },
    //                     child: Text(
    //                       'Play',
    //                       style: TextStyle(color: Colors.white),
    //                     ),
    //                   )
    //                 : Container(
    //                     child: Text(
    //                       "Link not Valid !",
    //                       style: TextStyle(color: Colors.red),
    //                     ),
    //                   )),
    //           )
    //         ],
    //       ),
    //     ),
    //     //),
    //   ),
    // );
    Get.bottomSheet(
      Container(
        width: double.infinity,
        height: heightRatio * 250,
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text('Enter the Link', style: TextStyle(fontSize: 20)),
              Container(
                margin: EdgeInsets.only(top: heightRatio * 20),
                height: heightRatio * 80,
                width: widthRatio * 300,
                child: TextField(
                  controller: yturl,
                  onChanged: (String value) {
                    ytStateController.checkLinkValidty(value);
                    roomLogicController.ytURL.value = value;
                  },
                  cursorColor: Colors.red,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
              ),
              Obx(
                () => Container(
                  margin: EdgeInsets.only(top: heightRatio * 10),
                  child: Row(
                    children: [
                      Spacer(),
                      //mp4 player
                      if (ytStateController.linkType.value ==
                              LinkType.BrowserLink &&
                          ytStateController.linkValidity.value ==
                              LinkValidity.Valid)
                        CustomButton(
                          function: () async {
                            //load the YT URL
                            controller.dispose();
                            await sendToBrowserPlayerPage();
                          },
                          buttonColor: Colors.blue,
                          content: 'MP4 Video',
                          contentSize: 10,
                          cornerRadius: 10,
                          height: 40,
                          textColor: Colors.white,
                          width: 100,
                        ),
                      SizedBox(width: 8),
                      //yt video button
                      if (ytStateController.linkType.value == LinkType.YTLink &&
                          ytStateController.linkValidity.value ==
                              LinkValidity.Valid)
                        CustomButton(
                          function: () async {
                            //load the YT URL
                            controller.load(roomLogicController.ytURL.value);
                            roomLogicController.sendYtLink(
                                ytlink: roomLogicController.ytURL.value);
                            roomLogicController.sendYtStatus(status: 'loaded');

                            Navigator.pop(context);
                          },
                          buttonColor: Colors.redAccent,
                          content: 'YouTube Video',
                          contentSize: 10,
                          cornerRadius: 10,
                          height: 40,
                          textColor: Colors.white,
                          // width: ,
                        ),
                      Spacer()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        //),
      ),
    );
  }

  Future<void> sendToBrowserPlayerPage() async {
    roomLogicController.ytURL.value = yturl.text;
    roomLogicController.sendYtLink(ytlink: roomLogicController.ytURL.value);
    roomLogicController.sendYtStatus(status: 'loaded');
    Navigator.pop(context);
    await Future.delayed(Duration(seconds: 1));
    Get.off(AnyPlayer());
  }

  getDialogBox() {
    Get.defaultDialog(
        title: 'Youtube',
        middleText: 'What is up Mumbai',
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              youBotShe();
            },
            child: Text('Link input'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              youBotShe();
              //await Get.to(WebShow());
              youWebShe();
              yturl.text = roomLogicController.ytURL.value;
              FlutterClipboard.paste().then((value) {
                print(value);
                yturl.text = value;
              });
            },
            child: Text('Get the link'),
          ),
        ]);
  }

  // final snackBar = SnackBar(
  //   content: Text('Yay! A SnackBar!'),
  //   action: SnackBarAction(
  //     label: 'Undo',
  //     onPressed: () {
  //       // Some code to undo the change.
  //     },
  //   ),
  // );

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    FocusNode currenFocus = FocusScope.of(context);

    //GetX Orientation doesn't work nicely so use this everywhere possible
    final Orientation phoneOrientation = MediaQuery.of(context).orientation;
    final Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // controller.pause();
        if (phoneOrientation == Orientation.landscape)
          controller.toggleFullScreenMode();

        // rishabhController.sendPlayerStatus(
        //     status: false, firebaseId: roomLogicController.roomFireBaseId);
        return showAlertDialog(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: phoneOrientation == Orientation.portrait
            ? AppBar(
                backgroundColor: Color(0xff292727),
                elevation: 0,
                leading: GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      //Expanded(
                      // margin: EdgeInsets.only(left: 20),
                      // color: Colors.blue.withOpacity(0.1),
                      // height: heightRatio * 300,
                      // width: widthRatio * 200,
                      // height: 500,

                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        color: Color.fromRGBO(10, 10, 10, 0.9),
                        width: double.infinity,
                        height: 300,
                        // color: Colors.red,
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: double.infinity,
                                child: Text(
                                  'All Users',
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.8),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 250,
                              child: FutureBuilder(
                                future: Future.delayed(Duration(seconds: 1)),
                                builder: (ctx, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return StreamBuilder(
                                      stream: rishabhController.tester(
                                          firebaseId: roomLogicController
                                              .roomFireBaseId),
                                      builder: (ctx, event) {
                                        if (event.hasData) {
                                          return NotificationListener<
                                              OverscrollIndicatorNotification>(
                                            onNotification: (overscroll) {
                                              overscroll.disallowGlow();
                                              return null;
                                            },
                                            child: ListView.separated(
                                              scrollDirection: Axis.vertical,
                                              separatorBuilder: (ctx, i) {
                                                return SizedBox(
                                                  width: 5,
                                                );
                                              },
                                              itemBuilder: (ctx, i) {
                                                print(
                                                    'chut: ${event.data.snapshot.value}');
                                                return Container(
                                                  width: 80,
                                                  height: 60,
                                                  child: CustomNameBar(
                                                    userName: event.data
                                                        .snapshot.value.values
                                                        .toList()[i]['name'],
                                                    roomController:
                                                        roomLogicController,
                                                    userID: event.data.snapshot
                                                        .value.values
                                                        .toList()[i]['id'],
                                                    event: event,
                                                    index: i,
                                                    widthRatio: widthRatio,
                                                    heightRatio: heightRatio,
                                                    imageSize: 35,
                                                    textSize: 17,
                                                  ),
                                                );
                                              },
                                              itemCount: event
                                                  .data.snapshot.value.values
                                                  .toList()
                                                  .length,
                                            ),
                                          );
                                        } else if (event.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                          Color>(
                                                      themeController
                                                          .drawerHead.value),
                                            ),
                                          );
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                          Color>(
                                                      themeController
                                                          .drawerHead.value),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      //),
                    );
                  },
                  child: Icon(Icons.people),
                ),
                centerTitle: true,
                title: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: GetX<RoomLogicController>(builder: (controller) {
                    return Text(
                      '${controller.roomId.obs.value} ',
                      style: TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 20,
                        // fontWeight: FontWeight.w100,
                      ),
                    );
                  }),
                ),
                actions: [
                  Container(
                    padding: EdgeInsets.only(right: 13),
                    child: Row(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.link),
                          onTap: () {
                            Get.snackbar(
                              '',
                              '',
                              snackPosition: SnackPosition.BOTTOM,
                              snackStyle: SnackStyle.GROUNDED,
                              duration: Duration(seconds: 4),
                              messageText: Text(
                                'Do you want to watch another video?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              titleText: Container(),
                              margin: const EdgeInsets.only(
                                  bottom: kBottomNavigationBarHeight,
                                  left: 8,
                                  right: 8),
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 10, left: 16, right: 16),
                              borderRadius: 20,
                              backgroundColor: Color.fromRGBO(20, 20, 20, 1),
                              colorText: Colors.white10,
                              mainButton: FlatButton(
                                child: Text(
                                  'Yes',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                                onPressed: () {
                                  getDialogBox();
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          child: buttonPressed == 0
                              ? Icon(Icons.message)
                              : Icon(Icons.fullscreen),
                          onTap: () {
                            if (buttonPressed == 1)
                              setState(() {
                                //Need comments here Manav
                                //what happens when it's zero and what happens when it's 1
                                buttonPressed = 0;
                              });
                            else
                              setState(() {
                                buttonPressed = 1;
                              });
                          },
                        ),
                      ],
                    ),
                  )
                ],
              )
            : null,
        // endDrawer: Container(
        //   width: 380 * widthRatio,
        //   child: Drawer(
        //     child: ChattingPlace(controller: controller),
        //   ),
        // ),
        backgroundColor: Color(0xff292727),
        body: Container(
          //padding: EdgeInsets.only(top: size.height * 0.02),
          child: Column(
            children: [
              SizedBox(
                  height: phoneOrientation == Orientation.portrait &&
                          buttonPressed == 0
                      ? 200
                      : 0),
              Container(
                height: phoneOrientation == Orientation.portrait
                    ? size.height * 0.3
                    : size.height * .98,
                // decoration:
                // BoxDecoration(border: Border.all(color: Colors.red)),
                child: Stack(
                  children: [
                    //The youtube player
                    Align(
                      // alignment: Alignment.center,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        // width: double.infinity,
                        child: YoutubePlayer(
                          // onEnded: (_) {
                          //   Get.off(WelcomScreen());
                          // },
                          aspectRatio: 16 / 9,
                          controller: controller,
                          // showVideoProgressIndicator: true,
                          progressColors: ProgressBarColors(
                              playedColor: Colors.amber,
                              handleColor: Colors.amberAccent),
                          onReady: () {
                            //Note : Working fine , do not change code
                            controller.addListener(
                              () {
                                roomLogicController.videoPosition.value =
                                    controller.value.position;
                                roomLogicController.playingStatus.value =
                                    controller.value.isPlaying;
                                ytStateController.videoPosition.value =
                                    controller.value.position.inSeconds
                                        .toDouble();
                                // print("adminId");
                                // print(roomLogicController.adminId.;value);
                                //admin
                                //will send timestamp and control video playback
                                if (roomLogicController.adminId.value ==
                                    roomLogicController.userId.obs.value) {
                                  rishabhController.sendTimeStamp(
                                      firebaseId:
                                          roomLogicController.roomFireBaseId,
                                      timeStamp:
                                          controller.value.position.inSeconds);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // ALL Control UIs

                    //seek back 10
                    // if (phoneOrientation == Orientation.portrait)
                    Container(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          // height: 150,
                          // decoration: BoxDecoration(),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //For hiding or displaying UI
                              Expanded(
                                // flex: 2,
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //     border: Border.all(color: Colors.red)),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(
                                        () {
                                          hideUI = !hideUI;
                                          shoSpeedWidget = false;
                                          // animatedHeight = 0;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Spacer(

                              //seekbar and time stamp UI
                              Obx(
                                () => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        // margin: EdgeInsets.only(left: 5),
                                        child: Text(
                                          '${roomLogicController.videoPosition.value.toString().substring(0, 7)}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Consolas"),
                                        ),
                                      ),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            activeTrackColor: Colors.indigo,
                                            inactiveTrackColor:
                                                Colors.indigo.shade200,
                                            trackShape:
                                                RoundedRectSliderTrackShape(),
                                            trackHeight: 2.0,
                                            thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius: 8.0),
                                            thumbColor: Colors.indigoAccent,
                                            overlayColor: Colors.indigo,
                                            overlayShape:
                                                RoundSliderOverlayShape(
                                                    overlayRadius: 10.0),
                                            tickMarkShape:
                                                RoundSliderTickMarkShape(),
                                            activeTickMarkColor: Colors.indigo,
                                            inactiveTickMarkColor:
                                                Colors.indigo,
                                            valueIndicatorShape:
                                                PaddleSliderValueIndicatorShape(),
                                            valueIndicatorColor: Colors.indigo,
                                          ),
                                          child: Slider(
                                            // activeColor:
                                            //     Color.fromRGBO(50, 60, 120, 0.5),

                                            value: roomLogicController
                                                .videoPosition.value.inSeconds
                                                .toDouble(),
                                            onChanged: (roomLogicController
                                                        .adminId.value ==
                                                    roomLogicController
                                                        .userId.obs.value)
                                                ? (value) {
                                                    roomLogicController
                                                            .videoPosition
                                                            .value =
                                                        Duration(
                                                            seconds:
                                                                value.toInt());
                                                    controller.seekTo(Duration(
                                                        seconds:
                                                            value.toInt()));
                                                  }
                                                : null,
                                            min: 0.0,
                                            max: controller
                                                    .metadata.duration.inSeconds
                                                    .toDouble() +
                                                5.0,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        // margin: EdgeInsets.only(right: 5),
                                        child: Text(
                                          '${controller.metadata.duration.toString().substring(0, 7)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Consolas",
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              //For all the controls
                              AnimatedContainer(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(25, 25, 25, 0.66),
                                  // border: Border.all(color: Colors.cyan)
                                ),
                                // color: Color.fromRGBO(25, 25, 25, 0.66),
                                // decoration: BoxDecoration(
                                //     color: Colors.grey,
                                //     border: Border.all(color: Colors.cyan)),
                                // padding: EdgeInsets.only(bottom: 20),
                                duration: Duration(milliseconds: 500),
                                height: hideUI ? 40 : 0,
                                // width: hideUI ? 0 : size.width,
                                // height: 0,
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 200),
                                  opacity: hideUI ? 1 : 0,
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //change speed
                                      SizedBox(width: 10),
                                      if (roomLogicController.adminId.value ==
                                          roomLogicController.userId)
                                        IconButton(
                                          icon: Icon(Icons.speed),
                                          color: Colors.white,
                                          onPressed: () {
                                            showSpeedAlertDialog();
                                          },
                                        ),

                                      //seek -10 seconds
                                      if (roomLogicController.adminId.value ==
                                          roomLogicController.userId.obs.value)
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.seekTo(Duration(
                                                  seconds: controller.value
                                                          .position.inSeconds -
                                                      10));
                                            },
                                            child: SvgPicture.asset(
                                                'lib/assets/svgs/back10.svg',
                                                width: 30 * widthRatio,
                                                height: 30 * heightRatio),
                                          ),
                                        ),

                                      //play pause icon
                                      Expanded(
                                        // width: Get.width * 0.4,
                                        // color: Colors.blue.shade100,
                                        child: GestureDetector(
                                          onTap: () {
                                            // hideControls();
                                            if (controller.value.isPlaying) {
                                              rishabhController
                                                  .sendPlayerStatus(
                                                      status: true,
                                                      firebaseId:
                                                          roomLogicController
                                                              .roomFireBaseId);
                                              controller.pause();
                                            } else {
                                              rishabhController
                                                  .sendPlayerStatus(
                                                      status: false,
                                                      firebaseId:
                                                          roomLogicController
                                                              .roomFireBaseId);
                                              controller.pause();
                                              controller.play();
                                            }
                                          },
                                          child: Obx(
                                            () => roomLogicController
                                                    .playingStatus.value
                                                ? Icon(
                                                    Icons.pause,
                                                    size: 40,
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    Icons.play_arrow,
                                                    size: 40,
                                                    color: Colors.white,
                                                  ),
                                          ),
                                        ),
                                      ),

                                      //seek forward 10
                                      if (roomLogicController.adminId.value ==
                                          roomLogicController.userId.obs.value)
                                        Expanded(
                                          // width: Get.width * 0.3,
                                          // color: Colors.yellow.shade100,
                                          child: GestureDetector(
                                            child: SvgPicture.asset(
                                                'lib/assets/svgs/go10.svg',
                                                width: 30 * widthRatio,
                                                height: 30 * heightRatio),
                                            onTap: () {
                                              controller.seekTo(Duration(
                                                  seconds: controller.value
                                                          .position.inSeconds +
                                                      10));
                                            },
                                          ),
                                        ),

                                      //Toggle fullscreen
                                      IconButton(
                                        icon: Icon(
                                          Icons.fullscreen,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            controller.toggleFullScreenMode();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (phoneOrientation == Orientation.portrait)
                SizedBox(height: 10),
              //this is the chat display part of code
              //so if the buttonPressed == 1 then thos these UIs ok got it Manav
              if (phoneOrientation == Orientation.portrait &&
                  buttonPressed == 1)
                Expanded(
                  child: ChatListViewWidget(
                      // chatWidth: 200,
                      ),
                ),
              //this is the sending part
              //send button
              //and textinput widget
              if (phoneOrientation == Orientation.portrait &&
                  buttonPressed == 1)
                ChatSend(
                    chatHeight: 50,
                    chatTextController: chatTextController,
                    currenFocus: currenFocus)
            ],
          ),
        ),

        //only show in landscape mode
      ),
    );
  }
}
