import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:un_ios_app/Screen/audio_call.dart';
import 'package:un_ios_app/Screen/pa_profile.dart';
import 'package:un_ios_app/Screen/video_call.dart';
import 'package:un_ios_app/Widget/buble_chat_personal.dart';
import 'package:un_ios_app/Widget/forward_chat.dart';
import 'package:un_ios_app/Widget/map_picker.dart';
import 'package:un_ios_app/Widget/widget_Image_Download.dart';
import 'package:un_ios_app/api.dart';
import 'package:un_ios_app/home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatPage extends StatelessWidget {
  final String fullName;
  final String image;
  final String identifier;
  final String connectivity;
  final bool refresh;

  ChatPage(this.fullName, this.image,
      {this.identifier, this.refresh = false, this.connectivity});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListMessage()),
        ChangeNotifierProvider(create: (_) => SelectedChat()),
        ChangeNotifierProvider(create: (_) => Attachment()),
      ],
      child: Consumer<SelectedChat>(
        builder: (context, selectChat, _) => Consumer<Attachment>(
          builder: (context, attachment, _) => Consumer<ListMessage>(
              builder: (context, select, _) => ChatPages(
                    fullName,
                    image,
                    attachment,
                    selectChat,
                    select,
                    identifier: identifier,
                    refresh: refresh,
                    connectivity: connectivity,
                  )),
        ),
      ),
    );
  }
}

class ChatPages extends StatefulWidget {
  final String fullName;
  final String image;
  final SelectedChat selectChat;
  final Attachment attachment;
  final ListMessage select;
  final String identifier;
  final String connectivity;
  final bool refresh;

  ChatPages(
      this.fullName, this.image, this.attachment, this.selectChat, this.select,
      {this.identifier, this.refresh, this.connectivity});

  @override
  _ChatPagesState createState() => _ChatPagesState();
}

class _ChatPagesState extends State<ChatPages> {
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _positionListener = ItemPositionsListener.create();
  TextEditingController _controllerEditor = TextEditingController();
  Timer _timer;

  Widget _textComposerWidget(Attachment attachment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width > 400
              ? MediaQuery.of(context).size.width * 0.85
              : MediaQuery.of(context).size.width * 0.83,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey[500],
              offset: Offset(0.0, 1.5),
              blurRadius: 1.5,
            ),
          ], color: Colors.white),
          margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              attachment.getReplyContent != null
                  ? Stack(
                      children: <Widget>[
                        Container(
                          color: Color(0xFFECF0F1),
                          constraints:
                              BoxConstraints(minHeight: 30, maxHeight: 80),
                          margin: EdgeInsets.all(5.0),
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(attachment.getReplyContent["fromName"],
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold)),
                                    Wrap(
                                      children: <Widget>[
                                        Text(
                                          attachment.getReplyContent["attachment_type"] == "1" &&
                                                  attachment
                                                      .getReplyContent["text"]
                                                      .isEmpty
                                              ? "Melampirkan gambar"
                                              : attachment.getReplyContent["attachment_type"] ==
                                                          "2" &&
                                                      attachment
                                                          .getReplyContent[
                                                              "text"]
                                                          .isEmpty
                                                  ? "Melampirkan video"
                                                  : attachment.getReplyContent["attachment_type"] ==
                                                              "6" &&
                                                          attachment
                                                              .getReplyContent[
                                                                  "text"]
                                                              .isEmpty
                                                      ? "Melampirkan dokumen"
                                                      : attachment.getReplyContent["attachment_type"] ==
                                                                  "-1" &&
                                                              attachment
                                                                  .getReplyContent[
                                                                      "text"]
                                                                  .isEmpty
                                                          ? "Melampirkan suara"
                                                          : attachment.getReplyContent["attachment_type"] ==
                                                                      "3" &&
                                                                  attachment
                                                                      .getReplyContent["text"]
                                                                      .isEmpty
                                                              ? "Melampirkan lokasi"
                                                              : attachment.getReplyContent["text"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              attachment.getReplyContent["attachment_type"] !=
                                      "0"
                                  ? Container(
                                      margin: EdgeInsets.only(left: 10.0),
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          image: attachment.getReplyContent[
                                                          "attachment_type"] ==
                                                      "-1" ||
                                                  attachment.getReplyContent[
                                                          "attachment_type"] ==
                                                      "6"
                                              ? null
                                              : DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: attachment.getReplyContent[
                                                              "attachment_type"] ==
                                                          "3"
                                                      ? NetworkImage(attachment
                                                          .getReplyContent["thumb_location"])
                                                      : FileImage(File(attachment.getReplyContent["thumb_id"])))),
                                      child: attachment.getReplyContent["attachment_type"] == "-1"
                                          ? Icon(
                                              Icons.volume_up,
                                              color: Colors.grey,
                                              size: 60,
                                            )
                                          : attachment.getReplyContent["attachment_type"] == "6" ? Icon(Icons.insert_drive_file, color: Colors.green, size: 60) : Container())
                                  : Container(height: 0.0, width: 0.0)
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(top: 8, right: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  widget.attachment.replyContent = null;
                                },
                                child: Icon(Icons.cancel, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
              TextField(
                minLines: 1,
                maxLines: 6,
                cursorColor: Color(0xFF364656),
                controller: _controllerEditor,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(20),
                    hintText: translate("hintEditor"),
                    border: InputBorder.none),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
          decoration: BoxDecoration(
              color: Colors.blueGrey, borderRadius: BorderRadius.circular(5.0)),
          width: 45,
          height: 45,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (attachment.getListImage.length > 0) {
                  for (var j = 0; j < attachment.getListImage.length; j++) {
                    attachment.getListImage[j].copy(
                        "${attachment.path.path}/${path.basename(attachment.getListImage[j].path)}");
                    API.sendMessage(
                        lPin: widget.identifier,
                        messageScopeId: "3",
                        status: "2",
                        messageText: j == 0 ? _controllerEditor.text : "",
                        imageId: path.basename(attachment.getListImage[j].path),
                        reffId: attachment.getReplyContent != null
                            ? attachment.getReplyContent["message_id"]
                            : "",
                        credential:
                            widget.attachment.getConfidentialActive ? "1" : "0",
                        thumbId: path.basename(attachment.getListImage[j].path),
                        attachmentFlag: "1");
                    var formatTime = new DateFormat('Hm');
                    String refId,
                        refName,
                        refText,
                        refType,
                        refThumbId,
                        refThumbLoc;
                    if (attachment.getReplyContent != null) {
                      refId = attachment.getReplyContent["message_id"];
                      refName = attachment.getReplyContent["fromName"];
                      refText = attachment.getReplyContent["attachment_type"] ==
                                  "3" ||
                              attachment.getReplyContent["attachment_type"] ==
                                  "-1"
                          ? ""
                          : attachment.getReplyContent["text"];
                      refType = attachment.getReplyContent["attachment_type"];
                      refThumbId = attachment.getReplyContent["thumb_id"];
                      refThumbLoc =
                          attachment.getReplyContent["thumb_location"];
                    }
                    int countCredential;
                    String credential;
//                    if(widget.attachment.getConfidentialActive){
//                      credential = "1";
//                      countCredential = 60;
//                      SharedPreferences prefs = await SharedPreferences.getInstance();
//                      prefs.setInt(
//                          "", DateTime.now().toUtc().millisecondsSinceEpoch);
//                    }
                    widget.select.addChat = Chat(
                        isOriginator: true,
                        text: _controllerEditor.text,
                        statusRead: "2",
                        fileName: attachment.getListImage[j].path,
                        thumbName:
                            path.basename(attachment.getListImage[j].path),
                        refFrom: refName,
//                        credential: credential,
                        refType: refType,
                        refText: refText,
                        refThumbLoc: refThumbLoc,
                        refId: refId,
                        refThumbId: refThumbId,
                        attachmentType: "1",
                        time: formatTime.format(DateTime.now()),
                        date: DateTime.now());
                  }
                  _controllerEditor.clear();
                  attachment.clearListImage = true;
                  attachment.refresh = true;
                  attachment.replyContent = null;
                  Future.delayed(Duration(milliseconds: 50), () {
                    _scrollController.scrollTo(
                        index: widget.select.getChat.length - 1,
                        duration: Duration(milliseconds: 50));
                  });
                } else if (attachment.getVideo != null) {
                  attachment.getVideo.copy(
                      "${attachment.path.path}/${path.basename(attachment.getVideo.path)}");
                  API.sendMessage(
                      lPin: widget.identifier,
                      messageScopeId: "3",
                      status: "2",
                      reffId: attachment.getReplyContent != null
                          ? attachment.getReplyContent["message_id"]
                          : "",
                      credential:
                          widget.attachment.getConfidentialActive ? "1" : "0",
                      messageText: _controllerEditor.text,
                      videoId: path.basename(attachment.getVideo.path),
                      thumbId: path.basename(attachment.getThumbnailVideo.path),
                      attachmentFlag: "2");
                  var formatTime = new DateFormat('Hm');
                  String refId,
                      refName,
                      refText,
                      refType,
                      refThumbId,
                      refThumbLoc;
                  if (attachment.getReplyContent != null) {
                    refId = attachment.getReplyContent["message_id"];
                    refName = attachment.getReplyContent["fromName"];
                    refText =
                        attachment.getReplyContent["attachment_type"] == "3" ||
                                attachment.getReplyContent["attachment_type"] ==
                                    "-1"
                            ? ""
                            : attachment.getReplyContent["text"];
                    refType = attachment.getReplyContent["attachment_type"];
                    refThumbId = attachment.getReplyContent["thumb_id"];
                    refThumbLoc = attachment.getReplyContent["thumb_location"];
                  }
                  widget.select.addChat = Chat(
                      isOriginator: true,
                      text: _controllerEditor.text,
                      statusRead: "1",
                      fileName: attachment.getVideo.path,
                      thumbName: attachment.getThumbnailVideo.path,
                      attachmentType: "2",
                      refFrom: refName,
                      refType: refType,
                      refText: refText,
                      refThumbLoc: refThumbLoc,
                      refId: refId,
                      refThumbId: refThumbId,
                      time: formatTime.format(DateTime.now()),
                      date: DateTime.now());
                  _controllerEditor.clear();
                  attachment.video = null;
                  attachment.refresh = true;
                  attachment.replyContent = null;
                  Future.delayed(Duration(milliseconds: 50), () {
                    _scrollController.scrollTo(
                        index: widget.select.getChat.length - 1,
                        duration: Duration(milliseconds: 50));
                  });
                } else if (attachment.getFile != null) {
                  attachment.getFile.copy(
                      "${attachment.path.path}/${path.basename(attachment.getFile.path)}");
                  API.sendMessage(
                      lPin: widget.identifier,
                      messageScopeId: "3",
                      status: "2",
                      reffId: attachment.getReplyContent != null
                          ? attachment.getReplyContent["message_id"]
                          : "",
                      credential:
                          widget.attachment.getConfidentialActive ? "1" : "0",
                      messageText: _controllerEditor.text,
                      fileId: path.basename(attachment.getFile.path),
                      attachmentFlag: "6");
                  var formatTime = new DateFormat('Hm');
                  String refId,
                      refName,
                      refText,
                      refType,
                      refThumbId,
                      refThumbLoc;
                  if (attachment.getReplyContent != null) {
                    refId = attachment.getReplyContent["message_id"];
                    refName = attachment.getReplyContent["fromName"];
                    refText =
                        attachment.getReplyContent["attachment_type"] == "3" ||
                                attachment.getReplyContent["attachment_type"] ==
                                    "-1"
                            ? ""
                            : attachment.getReplyContent["text"];
                    refType = attachment.getReplyContent["attachment_type"];
                    refThumbId = attachment.getReplyContent["thumb_id"];
                    refThumbLoc = attachment.getReplyContent["thumb_location"];
                  }
                  widget.select.addChat = Chat(
                      isOriginator: true,
                      text: _controllerEditor.text,
                      statusRead: "2",
                      fileName: attachment.getFile.path,
                      attachmentType: "6",
                      refFrom: refName,
                      refType: refType,
                      refText: refText,
                      refThumbLoc: refThumbLoc,
                      refId: refId,
                      refThumbId: refThumbId,
                      time: formatTime.format(DateTime.now()),
                      date: DateTime.now());
                  _controllerEditor.clear();
                  attachment.file = null;
                  attachment.refresh = true;
                  attachment.replyContent = null;
                  Future.delayed(Duration(milliseconds: 50), () {
                    _scrollController.scrollTo(
                        index: widget.select.getChat.length - 1,
                        duration: Duration(milliseconds: 50));
                  });
                } else if (_controllerEditor.text.trim().isNotEmpty) {
                  API.sendMessage(
                      lPin: widget.identifier,
                      messageScopeId: "3",
                      status: "2",
                      reffId: attachment.getReplyContent != null
                          ? attachment.getReplyContent["message_id"]
                          : "",
                      credential:
                          widget.attachment.getConfidentialActive ? "1" : "0",
                      messageText: _controllerEditor.text);
                  var formatTime = new DateFormat('Hm');
                  String refId,
                      refName,
                      refText,
                      refType,
                      refThumbId,
                      refThumbLoc;
                  if (attachment.getReplyContent != null) {
                    refId = attachment.getReplyContent["message_id"];
                    refName = attachment.getReplyContent["fromName"];
                    refText =
                        attachment.getReplyContent["attachment_type"] == "3" ||
                                attachment.getReplyContent["attachment_type"] ==
                                    "-1"
                            ? ""
                            : attachment.getReplyContent["text"];
                    refType = attachment.getReplyContent["attachment_type"];
                    refThumbId = attachment.getReplyContent["thumb_id"];
                    refThumbLoc = attachment.getReplyContent["thumb_location"];
                  }
                  widget.select.addChat = Chat(
                      isOriginator: true,
                      text: _controllerEditor.text,
                      statusRead: "1",
                      attachmentType: "0",
                      refFrom: refName,
                      refType: refType,
                      refText: refText,
                      refThumbLoc: refThumbLoc,
                      refId: refId,
                      refThumbId: refThumbId,
                      time: formatTime.format(DateTime.now()),
                      date: DateTime.now());
                  _controllerEditor.clear();
                  attachment.refresh = true;
                  attachment.replyContent = null;
                  Future.delayed(Duration(milliseconds: 50), () {
                    _scrollController.scrollTo(
                        index: widget.select.getChat.length - 1,
                        duration: Duration(milliseconds: 50));
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: translate("hintEditor"),
                      toastLength: Toast.LENGTH_SHORT);
                }
              },
              splashColor: Colors.yellow,
              child: Icon(
                Icons.send,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget clip(Attachment attachment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 5.0),
              width: 40,
              height: 40,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (FocusScope.of(context).hasFocus) {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(Duration(milliseconds: 100));
                    }
                    dialogAckConfidential(attachment);
                  },
                  splashColor: Colors.blueGrey,
                  child: attachment.getConfidentialActive
                      ? Image.asset("assets/images/od_guard_color.png")
                      : Image.asset("assets/images/od_guard_grey.png"),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.0),
              width: 40,
              height: 40,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (FocusScope.of(context).hasFocus) {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(Duration(milliseconds: 100));
                    }
                    dialogAckConfidential(attachment);
                  },
                  splashColor: Colors.blueGrey,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      attachment.getAckActive
                          ? Image.asset(
                              "assets/images/twsn_menulist_ack_12.png")
                          : Image.asset(
                              "assets/images/twsn_menulist_ack_11.png"),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.0),
              width: 40,
              height: 40,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {},
                  splashColor: Colors.blueGrey,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Image.asset("assets/images/od_hex_base.png"),
                      Icon(
                        Icons.mood,
                        size: 20,
                        color: Colors.grey[300],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            attachment.getFile != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints:
                            BoxConstraints(maxWidth: 120, minWidth: 60),
                        child: Text(
                          path
                              .basename(attachment.getFile.absolute.path)
                              .split(".")[0],
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        ".${path.basename(attachment.getFile.absolute.path).split(".")[1]}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                : Container(),
            SizedBox(width: 5),
            Container(
              margin: EdgeInsets.only(top: 5.0, right: 5.0),
              width: 40,
              height: 40,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (FocusScope.of(context).hasFocus) {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(Duration(milliseconds: 100));
                    }
                    dialogAttachment(attachment);
                  },
                  splashColor: Colors.blueGrey,
                  child: attachment.getVideo != null
                      ? Image.asset("assets/images/od_video.png")
                      : attachment.getListImage.length > 0
                          ? Image.asset("assets/images/od_images.png")
                          : attachment.getFile != null
                              ? Image.asset("assets/images/od_file.png")
                              : Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                        "assets/images/od_hex_base.png"),
                                    Image.asset(
                                        "assets/images/od_icon_attach.png")
                                  ],
                                ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget screenImageList(Attachment attachment) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, right: 10),
      child: SizedBox(
        height: 70,
        child: ListView.builder(
            shrinkWrap: true,
            reverse: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: attachment.getListImage.length,
            itemBuilder: (_, i) {
              return Container(
                margin: EdgeInsets.only(right: 20),
                width: 100,
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.grey,
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: PhotoView(
                                              imageProvider: FileImage(
                                                  attachment.getListImage[i]),
                                              backgroundDecoration:
                                                  BoxDecoration(
                                                      color: Colors.blueGrey)),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: GestureDetector(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(Icons.arrow_back_ios,
                                                        color: Colors.white),
                                                    Text(translate("back"),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18))
                                                  ],
                                                ),
                                                onTap: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ),
                                            margin: EdgeInsets.only(
                                                top: 40.0, left: 5.0),
                                          ),
                                        )
                                      ],
                                    )));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        FileImage(attachment.getListImage[i]))),
                          ),
                        ),
                      ),
                      ClipOval(
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.grey,
                            onTap: () {
                              attachment.removeListImage = i;
                            },
                            child: Container(
                              width: 25,
                              height: 25,
                              child: Icon(
                                Icons.close,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget screenVideo(Attachment attachment) {
    return Align(
      alignment: Alignment.centerRight,
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                OpenFile.open(attachment.getVideo.absolute.path);
              },
              child: Container(
                margin: EdgeInsets.only(right: 5.0),
                height: 90,
                width: 80,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(attachment.getThumbnailVideo))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: ClipOval(
              child: Material(
                color: Colors.white,
                child: InkWell(
                  splashColor: Colors.grey,
                  onTap: () {
                    attachment.video = null;
                    attachment.thumbnailVideo = null;
                  },
                  child: Container(
                    width: 25,
                    height: 25,
                    child: Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void dialogAckConfidential(Attachment attachment) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 180,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.0),
                  color: Colors.black54),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: Text(translate("messageMode"),
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                        "${translate("choose")} ${translate("messageMode")}",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (attachment.getAckActive) {
                            attachment.ackActive = !attachment.getAckActive;
                          }
                          attachment.confidentialActive =
                              !attachment.getConfidentialActive;
                          Navigator.pop(context);
                        },
                        splashColor: Colors.blueAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              child: Image.asset(
                                  "assets/images/od_guard_color.png"),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(translate("confidentialMessage"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              400
                                          ? MediaQuery.of(context).size.width *
                                              0.65
                                          : MediaQuery.of(context).size.width *
                                              0.6),
                                  child: Wrap(
                                    children: <Widget>[
                                      Text(translate('descConfidentialMessage'),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9)),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (attachment.getConfidentialActive) {
                            attachment.confidentialActive =
                                !attachment.getConfidentialActive;
                          }
                          attachment.ackActive = !attachment.getAckActive;
                          Navigator.pop(context);
                        },
                        splashColor: Colors.blueAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              child: Image.asset(
                                  "assets/images/twsn_menulist_ack_12.png"),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(translate("confirmationMessage"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              400
                                          ? MediaQuery.of(context).size.width *
                                              0.65
                                          : MediaQuery.of(context).size.width *
                                              0.6),
                                  child: Wrap(
                                    children: <Widget>[
                                      Text(translate("descConfirmationMessage"),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9)),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  void dialogAttachment(Attachment attachment) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 270,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.0),
                  color: Colors.black54),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: Text(translate("attachment"),
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    margin: EdgeInsets.only(left: 25),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (attachment.getListImage.length < 5) {
                            Navigator.pop(context);
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    child: CupertinoAlertDialog(
                                      content: Material(
                                        color: Colors.transparent,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            ListTile(
                                              title:
                                                  Text(translate("takePhoto")),
                                              onTap: () {
                                                Navigator.pop(context);
                                                takePhoto(attachment);
                                              },
                                            ),
                                            ListTile(
                                              title: Text(
                                                  translate("selectGallery")),
                                              onTap: () {
                                                Navigator.pop(context);
                                                pickImages(attachment);
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            Fluttertoast.showToast(
                                msg: translate("max5"),
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        },
                        splashColor: Colors.blueAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/images/od_images.png"),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(translate("image"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Text(translate("descImage"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    margin: EdgeInsets.only(left: 25),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  child: CupertinoAlertDialog(
                                    content: Material(
                                      color: Colors.transparent,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          ListTile(
                                            title: Text(translate("takeVideo")),
                                            onTap: () {
                                              Navigator.pop(context);
                                              takePickVideo(
                                                  "camera", attachment);
                                            },
                                          ),
                                          ListTile(
                                            title: Text(
                                                translate("selectGallery")),
                                            onTap: () {
                                              Navigator.pop(context);
                                              takePickVideo(
                                                  "gallery", attachment);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        splashColor: Colors.blueAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/images/od_video.png"),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(translate("video"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Text(translate("descVideo"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    margin: EdgeInsets.only(left: 25),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          pickLocation();
                        },
                        splashColor: Colors.blueAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              child:
                                  Image.asset("assets/images/od_location.png"),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(translate("location"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Text(translate("descLocation"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    margin: EdgeInsets.only(left: 25),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          pickFile(attachment);
                        },
                        splashColor: Colors.blueAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/images/od_file.png"),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(translate("document"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Text(translate("descDoc"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 9))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void takePhoto(Attachment attachment) async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxHeight: 720,
      maxWidth: 1280,
    );
    if (image == null) {
      return;
    } else {
      if (attachment.getVideo != null) {
        attachment.video = null;
        attachment.thumbnailVideo = null;
      }
      attachment.addListImage = image;
    }
  }

  void pickImages(Attachment attachment) async {
    List<Asset> image = await MultiImagePicker.pickImages(
        maxImages: 5 - attachment.getListImage.length, enableCamera: false);
    if (image == null) {
      return;
    } else {
      if (attachment.getVideo != null) {
        attachment.video = null;
        attachment.thumbnailVideo = null;
      } else if (attachment.getFile != null) {
        attachment.file = null;
      }
      List<File> listImage = List();
      for (var i = 0; i < image.length; i++) {
        var path =
            await FlutterAbsolutePath.getAbsolutePath(image[i].identifier);
        listImage.add(File(path));
      }
      attachment.listImage = listImage;
    }
  }

  void takePickVideo(String from, Attachment attachment) async {
    File pickVideo = await ImagePicker.pickVideo(
      source: from == "camera" ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickVideo == null) {
      return;
    } else {
      if (attachment.getListImage.length > 0) {
        attachment.clearListImage = true;
      } else if (attachment.getFile != null) {
        attachment.file = null;
      }
      var myPath = await getTemporaryDirectory();
      String thumbPath = myPath.path;
      var videoThumb = await VideoThumbnail.thumbnailFile(
        video: pickVideo.path,
        thumbnailPath: thumbPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 720,
        maxWidth: 1280,
        quality: 80,
      );
      attachment.thumbnailVideo = File(videoThumb);
      attachment.video = pickVideo;
    }
  }

  void pickLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (position == null) {
      Fluttertoast.showToast(
          msg: "Check your connection/turn on your gps",
          toastLength: Toast.LENGTH_SHORT);
    } else {
      var result = await Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: MapPicker(
                "AIzaSyB3RM2rmLCsLzuymu6IU_0kx-GNmoAaY6g",
                LatLng(position.latitude, position.longitude),
              )));
      if (result != null) {
        Position position = result["latlng"];
        API.sendMessage(
            lPin: "020d64b868",
            messageScopeId: "3",
            status: "2",
            attachmentFlag: "3",
            messageText:
                "Share location ${result["namePlace"]} lat/lng: (${position.latitude},${position.longitude})");
        var formatTime = new DateFormat('Hm');
        widget.select.addChat = Chat(
            isOriginator: true,
            text: Uri.encodeQueryComponent(Uri.encodeFull(
                "Share location ${result["namePlace"]} lat/lng: (${position.latitude},${position.longitude})")),
            statusRead: "1",
            attachmentType: "3",
            time: formatTime.format(DateTime.now()),
            date: DateTime.now());
      }
    }
  }

  void pickFile(Attachment attachment) async {
    File pickFile = await FilePicker.getFile(type: FileType.any);
    if (pickFile == null) {
      return;
    } else {
      if (attachment.getVideo != null) {
        attachment.video = null;
        attachment.thumbnailVideo = null;
      } else if (attachment.getListImage.length > 0) {
        attachment.clearListImage = true;
      }
      attachment.file = pickFile;
    }
  }

  void onMessageReceiver(ListMessage listMessage, Attachment attachment) {
    API.onReceiveMessage = (dynamic result) async {
      if (mounted) {
        if (result["A00"] == widget.identifier) {
          String fileName, thumbName, attachmentFlag;
          if (result["A57"] != null) {
            fileName = result["A57"];
            thumbName = "${attachment.path.path}/${result["A74"]}";
            attachmentFlag = "1";
          } else if (result["A47"] != null) {
            fileName = result["A47"];
            thumbName = "${attachment.path.path}/${result["A74"]}";
            attachmentFlag = "2";
          } else if (result["BN"] != null) {
            fileName = result["BN"];
            attachmentFlag = "6";
          } else if (result["A63"] != null) {
            fileName = result["A63"];
            attachmentFlag = "-1";
          } else if (result["A07"].contains("Share%2Blocation%2B")) {
            attachmentFlag = "3";
          } else {
            attachmentFlag = "0";
          }
          String refId, refName, refText, refType, refThumbId, refThumbLoc;
          if (result["A121"] != null) {
            int idx =
                listMessage.getChat.indexOf(Chat(messageId: result["A121"]));
            String imageLocation;
            String textDecode = Uri.decodeQueryComponent(
                Uri.decodeFull(listMessage.getChat[idx].text));
            if (listMessage.getChat[idx].attachmentType == "3") {
              int idx = textDecode.indexOf("(");
              var textLatLng = textDecode
                  .substring(idx + 1, textDecode.trim().length - 1)
                  .split(",");
              imageLocation =
                  "https://maps.googleapis.com/maps/api/staticmap?center=" +
                      textLatLng[0] +
                      "," +
                      textLatLng[1].trimLeft() +
                      "&zoom=15&size=" +
                      300.toString() +
                      "x" +
                      150.toString() +
                      "&maptype=normal&markers=color:red|" +
                      textLatLng[0] +
                      "," +
                      textLatLng[1].trimLeft() +
                      "&key=AIzaSyC79oNmadezP9O_4Q_Ud2bbuJ_L7M--y1s";
            }
            refId = result["A121"];
            refName =
                listMessage.getChat[idx].isOriginator ? "You" : widget.fullName;
            refText = listMessage.getChat[idx].attachmentType == "3" ||
                    listMessage.getChat[idx].attachmentType == "-1"
                ? ""
                : listMessage.getChat[idx].text;
            refType = listMessage.getChat[idx].attachmentType;
            refThumbId = listMessage.getChat[idx].thumbName;
            refThumbLoc = imageLocation;
          }
          int countCredential;
          if (result["A118"] == "1") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setInt(
                result["A18"], DateTime.now().toUtc().millisecondsSinceEpoch);
            countCredential = 60;
          }
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(int.parse(result["A19"]));
          var formatTime = new DateFormat('Hm');
          Chat message = Chat(
              text: result["A07"],
              messageId: result["A18"],
              time: formatTime.format(dateTime),
              attachmentType: attachmentFlag,
              statusRead: result["A15"],
              refThumbId: refThumbId,
              refId: refId,
              refThumbLoc: refThumbLoc,
              refText: refText,
              refType: refType,
              refFrom: refName,
              fileName: fileName,
              thumbName: thumbName,
              date: dateTime,
              countCredential: countCredential,
              runCount: false,
              credential: result["A118"],
              isOriginator: false);
          listMessage.addChat = message;
        }
      }
    };
  }

  void incomingCall() {
    API.incomingCall = (int state, String message) {
      if (mounted) {
        String deviceId = message.substring(0, message.indexOf(","));
        API
            .query(
                "SELECT first_name, last_name FROM BUDDY WHERE device_id = '$deviceId'")
            .then((result) {
          if (state == 21) {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: AudioCall(
                      name:
                          "${result[0]["first_name"]} ${result[0]["last_name"]}",
                      image: widget.image,
                      isInitiatior: 0,
                      deviceId: deviceId,
                    )));
          } else if (state == 31) {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: VideoCall(
                      name:
                          "${result[0]["first_name"]} ${result[0]["last_name"]}",
                      isInitiatior: 0,
                      deviceId: deviceId,
                      cameraId: "1",
                    )));
          }
        });
      }
    };
  }

  Future<bool> onWillPop() async {
    if (widget.attachment.refresh) {
      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(type: PageTransitionType.fade, child: Home(index: 2)),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pop();
    }
    return Future.value(false);
  }

  void getChat(ListMessage listMessage, Attachment attachment) async {
    await API.updateCounter(widget.identifier);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    attachment.path = await getApplicationDocumentsDirectory();
    String idMe = prefs.getString("hasLogin");
    List<dynamic> resultQuery = await API.query(
        "SELECT * FROM MESSAGE where (f_pin='${widget.identifier}' or l_pin='${widget.identifier}') order by server_date");
    List<Chat> temporaryChat = List();
    for (var i = 0; i < resultQuery.length; i++) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(resultQuery[i]["server_date"]));
      var formatTime = new DateFormat('Hm');
      String fileName, thumbName, attachmentFlag;
      double progress;
      if (resultQuery[i]["image_id"].trim().isNotEmpty) {
        fileName = resultQuery[i]["image_id"];
        thumbName = "${attachment.path.path}/${resultQuery[i]["thumb_id"]}";
        if (File("${attachment.path.path}/${resultQuery[i]["image_id"]}")
            .existsSync()) {
          progress = 100.0;
        }
        attachmentFlag = "1";
      } else if (resultQuery[i]["video_id"].trim().isNotEmpty) {
        fileName = resultQuery[i]["video_id"];
        thumbName = "${attachment.path.path}/${resultQuery[i]["thumb_id"]}";
        attachmentFlag = "2";
        if (File("${attachment.path.path}/${resultQuery[i]["video_id"]}")
            .existsSync()) {
          progress = 100.0;
        }
      } else if (resultQuery[i]["file_id"].trim().isNotEmpty) {
        fileName = resultQuery[i]["file_id"];
        attachmentFlag = "6";
        if (File("${attachment.path.path}/${resultQuery[i]["file_id"]}")
            .existsSync()) {
          progress = 100.0;
        }
      } else if (resultQuery[i]["audio_id"].trim().isNotEmpty) {
        fileName = resultQuery[i]["audio_id"];
        attachmentFlag = "-1";
        if (File("${attachment.path.path}/${resultQuery[i]["audio_id"]}")
            .existsSync()) {
          progress = 100.0;
        }
      } else if (resultQuery[i]["message_text"]
          .contains("Share%2Blocation%2B")) {
        attachmentFlag = "3";
      } else {
        attachmentFlag = "0";
      }
      String refId, refName, refText, refType, refThumbId, refThumbLoc;
      if (resultQuery[i]["reff_id"].isNotEmpty) {
        int idx =
            temporaryChat.indexOf(Chat(messageId: resultQuery[i]["reff_id"]));
        String imageLocation;
        String textDecode =
            Uri.decodeQueryComponent(Uri.decodeFull(temporaryChat[idx].text));
        if (temporaryChat[idx].attachmentType == "3") {
          int idx = textDecode.indexOf("(");
          var textLatLng = textDecode
              .substring(idx + 1, textDecode.trim().length - 1)
              .split(",");
          imageLocation =
              "https://maps.googleapis.com/maps/api/staticmap?center=" +
                  textLatLng[0] +
                  "," +
                  textLatLng[1].trimLeft() +
                  "&zoom=15&size=" +
                  300.toString() +
                  "x" +
                  150.toString() +
                  "&maptype=normal&markers=color:red|" +
                  textLatLng[0] +
                  "," +
                  textLatLng[1].trimLeft() +
                  "&key=AIzaSyC79oNmadezP9O_4Q_Ud2bbuJ_L7M--y1s";
        }
        refId = resultQuery[i]["reff_id"];
        refName = temporaryChat[idx].isOriginator ? "You" : widget.fullName;
        refText = temporaryChat[idx].attachmentType == "3" ||
                temporaryChat[idx].attachmentType == "-1"
            ? ""
            : temporaryChat[idx].text;
        refType = temporaryChat[idx].attachmentType;
        refThumbId = temporaryChat[idx].thumbName;
        refThumbLoc = imageLocation;
      }
      int countCredential;
      if (resultQuery[i]["credential"] == "1") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.getInt(resultQuery[i]["message_id"]) == null) {
          prefs.setInt(resultQuery[i]["message_id"],
              DateTime.now().toUtc().millisecondsSinceEpoch);
          countCredential = 60;
        } else {
          int timeCount = prefs.getInt(resultQuery[i]["message_id"]);
          int difSecond = DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(timeCount))
              .inSeconds;
          if (60 - difSecond > 0) {
            countCredential = 60 - difSecond;
          } else {
            countCredential = 0;
          }
        }
      }
      Chat message = Chat(
          text: resultQuery[i]["message_text"],
          messageId: resultQuery[i]["message_id"],
          refId: refId,
          refFrom: refName,
          refText: refText,
          refThumbId: refThumbId,
          refType: refType,
          refThumbLoc: refThumbLoc,
          time: formatTime.format(dateTime),
          attachmentType: attachmentFlag,
          statusRead: resultQuery[i]["status"],
          fileName: fileName,
          thumbName: thumbName,
          countCredential: countCredential,
          date: dateTime,
          runCount: false,
          progress: progress,
          credential: resultQuery[i]["credential"],
          isOriginator: resultQuery[i]["f_pin"] == idMe);
      temporaryChat.add(message);
    }
    temporaryChat.sort((a, b) => a.date.compareTo(b.date));
    listMessage.addChatAll = temporaryChat;
    attachment.loading = false;
    if (widget.refresh) {
      attachment.refresh = widget.refresh;
    }
  }

  void startTimer(int count, int idx) {
    widget.select.trueRunCount = idx;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (widget.select.getChat[idx].countCredential < 1) {
          timer.cancel();
//          SharedPreferences prefs = await SharedPreferences.getInstance();
//          prefs.remove(key);
        } else {
          if (mounted) {
            widget.select.countCredential = {
              "index": idx,
              "count": widget.select.getChat[idx].countCredential - 1
            };
          } else {
            timer.cancel();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    final listMessage = Provider.of<ListMessage>(context, listen: false);
    getChat(listMessage, widget.attachment);
    onMessageReceiver(listMessage, widget.attachment);
    incomingCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/batik.png"),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Color(0xFF364656),
            titleSpacing: 0.0,
            title: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  List<dynamic> resultQuery = await API.query(
                      "SELECT f_pin, first_name, official_account, email, image_id, cell, upline_pin, quote, connected, privacy_flag, web, offline_mode, muted, address, bidang_industri, visi, misi, company_lat, company_lng FROM BUDDY where f_pin='${widget.identifier}'");
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: PAProfile(
                            profileDet: {
                              'f_pin': widget.identifier,
                              'myProfile': false,
                              'name': resultQuery[0]["first_name"],
                              'follower': 0,
                              'official_flag': resultQuery[0]
                                          ["official_account"] ==
                                      "1"
                                  ? 1
                                  : resultQuery[0]["official_account"] == "2"
                                      ? 0
                                      : 2,
                              'isFriend': 0,
                              'post': 0,
                              'following': 0,
                              'isOffline': resultQuery[0]["offline_mode"],
                              'isMuted': resultQuery[0]["muted"],
                              'industry': resultQuery[0]["bidang_industri"],
                              'email_address': resultQuery[0]["email"],
                              'phone_number': resultQuery[0]["cell"],
                              'website': resultQuery[0]["web"],
                              'address': resultQuery[0]["address"],
                              'status': resultQuery[0]["quote"],
                              'isOnline':
                                  int.parse(resultQuery[0]["connected"]),
                              'image': resultQuery[0]["image_id"]
                            },
                          )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: LocalImage(widget.image))),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.fullName,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                          Text(
                              widget.connectivity == "1" ? "Online" : "Offline",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[400]))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                    widget.selectChat.listSelectedChat.length == 1
                        ? CupertinoIcons.reply_thick_solid
                        : widget.selectChat.listSelectedChat.length > 1
                            ? CupertinoIcons.forward
                            : CupertinoIcons.video_camera_solid,
                    color: Colors.white),
                iconSize: 25,
                onPressed: () {
                  if (widget.selectChat.listSelectedChat.length == 0) {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: VideoCall(
                              name: widget.fullName,
                            )));
                  } else if (widget.selectChat.listSelectedChat.length == 1) {
                    widget.selectChat.getSelectedChat.forEach((k, v) {
                      String imageLocation;
                      if (v.attachmentType == "3") {
                        String textDecode =
                            Uri.decodeQueryComponent(Uri.decodeFull(v.text));
                        int idx = textDecode.indexOf("(");
                        var textLatLng = textDecode
                            .substring(idx + 1, textDecode.trim().length - 1)
                            .split(",");
                        imageLocation =
                            "https://maps.googleapis.com/maps/api/staticmap?center=" +
                                textLatLng[0] +
                                "," +
                                textLatLng[1].trimLeft() +
                                "&zoom=15&size=" +
                                300.toString() +
                                "x" +
                                150.toString() +
                                "&maptype=normal&markers=color:red|" +
                                textLatLng[0] +
                                "," +
                                textLatLng[1].trimLeft() +
                                "&key=AIzaSyC79oNmadezP9O_4Q_Ud2bbuJ_L7M--y1s";
                      }
                      widget.attachment.replyContent = {
                        "message_id": v.messageId,
                        "attachment_type": v.attachmentType,
                        "fromName":
                            v.isOriginator ? "You" : "${widget.fullName}",
                        "text":
                            v.attachmentType == "3" || v.attachmentType == "-1"
                                ? ""
                                : v.text,
                        "thumb_id": v.thumbName,
                        "thumb_location": imageLocation
                      };
                      widget.select.falseSelected = k;
                    });
                    widget.selectChat.clearList = true;
                  } else {
                    List<dynamic> data = List();
                    for (var i = 0;
                        i < widget.selectChat.getSelectedChat.length;
                        i++) {
                      data.add({
                        "index":
                            widget.selectChat.getSelectedChat.keys.elementAt(i),
                        "data": widget.selectChat.getSelectedChat.values
                            .elementAt(i)
                      });
                      widget.select.falseSelected =
                          widget.selectChat.getSelectedChat.keys.elementAt(i);
                    }
                    widget.selectChat.clearList = true;
                    if (widget.attachment.cantForward > 0) {
                      Fluttertoast.showToast(
                          msg: "Unduh file/dokumen terlebih dahulu",
                          toastLength: Toast.LENGTH_LONG);
                      return null;
                    }
                    data.sort((b, a) => a["index"].compareTo(b["index"]));
                    showDialog(
                        context: context,
                        builder: (_) {
                          return Dialog(
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: ForwardChat(data),
                            ),
                          );
                        });
                  }
                },
              ),
              IconButton(
                  icon: Icon(
                      widget.selectChat.listSelectedChat.length == 1
                          ? CupertinoIcons.forward
                          : widget.selectChat.listSelectedChat.length > 1
                              ? CupertinoIcons.delete_solid
                              : CupertinoIcons.phone_solid,
                      color: Colors.white),
                  iconSize: 25,
                  onPressed: () async {
                    if (widget.selectChat.listSelectedChat.length == 0) {
                      List<dynamic> resultQuery = await API.query(
                          "SELECT device_id FROM BUDDY where f_pin='${widget.identifier}'");
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: AudioCall(
                                isInitiatior: 1,
                                name: widget.fullName,
                                image: widget.image,
                                deviceId: resultQuery[0]["device_id"],
                              )));
                    } else if (widget.selectChat.listSelectedChat.length == 1) {
                      List<dynamic> data = List();
                      for (var i = 0;
                          i < widget.selectChat.getSelectedChat.length;
                          i++) {
                        data.add({
                          "index": widget.selectChat.getSelectedChat.keys
                              .elementAt(i),
                          "data": widget.selectChat.getSelectedChat.values
                              .elementAt(i)
                        });
                        widget.select.falseSelected =
                            widget.selectChat.getSelectedChat.keys.elementAt(i);
                      }
                      widget.selectChat.clearList = true;
                      if (widget.attachment.cantForward > 0) {
                        Fluttertoast.showToast(
                            msg: "Unduh file/dokumen terlebih dahulu",
                            toastLength: Toast.LENGTH_LONG);
                        return null;
                      }
                      data.sort((b, a) => a["index"].compareTo(b["index"]));
                      showDialog(
                          context: context,
                          builder: (_) {
                            return Dialog(
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: ForwardChat(data),
                              ),
                            );
                          });
                    }
                  }),
              widget.selectChat.listSelectedChat.length == 1
                  ? PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 4,
                          child: Text("Tambahkan ke pesan favorite"),
                        ),
                        PopupMenuItem(
                          value: 5,
                          child: Text("Hapus Pesan"),
                        ),
                      ],
                    )
                  : widget.selectChat.listSelectedChat.length > 1
                      ? PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 4,
                              child: Text("Tambahkan ke pesan favorite"),
                            )
                          ],
                        )
                      : PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Text(translate("search")),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text(translate("block")),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: Text(translate("deleteConv")),
                            )
                          ],
                        )
            ],
          ),
          body: widget.attachment.loading
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Stack(
                        children: <Widget>[
                          ScrollablePositionedList.builder(
                              itemCount: widget.select.messageChat.length,
                              itemScrollController: _scrollController,
                              physics: const ClampingScrollPhysics(),
                              itemPositionsListener: _positionListener,
                              itemBuilder: (context, index) {
                                bool isShowDate = false;
                                var data = widget.select.messageChat;
                                String date = DateTime.now()
                                            .difference(data[index].date)
                                            .inHours <
                                        24
                                    ? translate("today")
                                    : DateTime.now()
                                                .difference(data[index].date)
                                                .inHours <
                                            48
                                        ? translate("yesterday")
                                        : DateFormat('dd MMMM yyyy')
                                            .format(data[index].date);
                                if (data.length == 1) {
                                  isShowDate = true;
                                } else {
                                  if (index == 0) {
                                    isShowDate = true;
                                  }
                                  if (index + 1 != data.length) {
                                    var format = DateFormat('dd');
                                    String date1 =
                                        format.format(data[index].date);
                                    String date2 =
                                        format.format(data[index + 1].date);
                                    if (date1 != date2) {
                                      isShowDate = true;
                                    }
                                  }
                                }
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    isShowDate
                                        ? Center(
                                            child: Container(
                                                child: Text(
                                                  date,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                height: 24,
                                                margin: EdgeInsets.all(10.0),
                                                padding: EdgeInsets.all(5.0),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.blueAccent),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3.0))),
                                          )
                                        : Container(),
                                    BubbleChatPersonal(
                                      isOriginator: data[index].isOriginator,
                                      text: data[index].text,
                                      fileName: data[index].fileName,
                                      thumbName: data[index].thumbName,
                                      attachmentType:
                                          data[index].attachmentType,
                                      credential: data[index].credential,
                                      messageId: data[index].messageId,
                                      time: data[index].time,
                                      refId: data[index].refId,
                                      refFrom: data[index].refFrom,
                                      refType: data[index].refType,
                                      refText: data[index].refText,
                                      countCredential:
                                          data[index].countCredential,
                                      progress: data[index].progress,
                                      refThumbLoc: data[index].refThumbLoc,
                                      refThumbId: data[index].refThumbId,
                                      statusRead: data[index].statusRead,
                                      isSelected: data[index].isSelected,
                                      onStartCount: () {
                                        if (!data[index].runCount) {
                                          startTimer(
                                              data[index].countCredential,
                                              index);
                                        }
                                      },
                                      onTapReply: () {
                                        int idx = widget.select.getChat.indexOf(
                                            Chat(messageId: data[index].refId));
                                        _scrollController.jumpTo(index: idx);
                                        widget.select.trueSelected = idx;
                                        Future.delayed(
                                            Duration(milliseconds: 500), () {
                                          widget.select.falseSelected = idx;
                                        });
                                      },
                                      onLongPress: () {
                                        if (!data[index].isSelected) {
                                          widget.select.trueSelected = index;
                                          widget.selectChat.addList = {
                                            "index": index,
                                            "data": data[index]
                                          };
                                          if (data[index].attachmentType !=
                                                  "0" &&
                                              !File(widget.attachment.path
                                                          .path +
                                                      "/" +
                                                      data[index].fileName)
                                                  .existsSync()) {
                                            widget.attachment.cantForward =
                                                widget.attachment.cantForward +
                                                    1;
                                          }
                                        } else if (data[index].isSelected) {
                                          widget.select.falseSelected = index;
                                          widget.selectChat.removeList = index;
                                          if (data[index].attachmentType !=
                                                  "0" &&
                                              !File(widget.attachment.path
                                                          .path +
                                                      "/" +
                                                      data[index].fileName)
                                                  .existsSync()) {
                                            widget.attachment.cantForward =
                                                widget.attachment.cantForward -
                                                    1;
                                          }
                                        }
                                      },
                                      onTapPress: () async {
                                        if (widget.selectChat.getSelectedChat
                                                .length >
                                            0) {
                                          if (!data[index].isSelected) {
                                            widget.select.trueSelected = index;
                                            widget.selectChat.addList = {
                                              "index": index,
                                              "data": data[index]
                                            };
                                            if (data[index].attachmentType !=
                                                    "0" &&
                                                !File(widget.attachment.path
                                                            .path +
                                                        "/" +
                                                        data[index].fileName)
                                                    .existsSync()) {
                                              widget.attachment.cantForward =
                                                  widget.attachment
                                                          .cantForward +
                                                      1;
                                            }
                                          } else if (widget.select
                                              .messageChat[index].isSelected) {
                                            widget.select.falseSelected = index;
                                            widget.selectChat.removeList =
                                                index;
                                            if (data[index].attachmentType !=
                                                    "0" &&
                                                !File(widget.attachment.path
                                                            .path +
                                                        "/" +
                                                        data[index].fileName)
                                                    .existsSync()) {
                                              widget.attachment.cantForward =
                                                  widget.attachment
                                                          .cantForward -
                                                      1;
                                            }
                                          }
                                        } else if (data[index].fileName !=
                                                null &&
                                            data[index].fileName.isNotEmpty) {
                                          if (data[index].attachmentType == "2" ||
                                              data[index].attachmentType ==
                                                  "6" ||
                                              data[index].attachmentType ==
                                                  "-1") {
                                            if (!File(widget.attachment.path
                                                            .path +
                                                        "/" +
                                                        data[index].fileName)
                                                    .existsSync() &&
                                                data[index].progress == null) {
                                              API.download(
                                                  data[index].fileName);
                                              if (mounted) {
                                                API.onDownloadProgress =
                                                    (double progress,
                                                        String fileName) {
                                                  widget.select.updateProgress =
                                                      {
                                                    'index': index,
                                                    'value': progress
                                                  };
                                                };
                                              }
                                            } else if (File(widget
                                                        .attachment.path.path +
                                                    "/" +
                                                    data[index].fileName)
                                                .existsSync()) {
                                              OpenFile.open(
                                                  widget.attachment.path.path +
                                                      "/" +
                                                      data[index].fileName);
                                            }
                                          } else if (data[index]
                                                  .attachmentType ==
                                              "1") {
                                            if (!File(widget.attachment.path
                                                            .path +
                                                        "/" +
                                                        data[index].fileName)
                                                    .existsSync() &&
                                                data[index].progress == null) {
                                              API.download(
                                                  data[index].fileName);
                                              if (mounted) {
                                                API.onDownloadProgress =
                                                    (double progress,
                                                        String fileName) {
                                                  widget.select.updateProgress =
                                                      {
                                                    'index': index,
                                                    'value': progress
                                                  };
                                                };
                                              }
                                            } else if (File(widget
                                                        .attachment.path.path +
                                                    "/" +
                                                    data[index].fileName)
                                                .existsSync()) {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .fade,
                                                      child: Stack(
                                                        children: <Widget>[
                                                          Center(
                                                            child: PhotoView(
                                                                imageProvider: FileImage(File(widget
                                                                        .attachment
                                                                        .path
                                                                        .path +
                                                                    "/" +
                                                                    data[index]
                                                                        .fileName)),
                                                                backgroundDecoration:
                                                                    BoxDecoration(
                                                                        color: Colors
                                                                            .blueGrey)),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Container(
                                                              child: Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child:
                                                                    GestureDetector(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Icon(
                                                                          Icons
                                                                              .arrow_back_ios,
                                                                          color:
                                                                              Colors.white),
                                                                      Text(
                                                                          translate(
                                                                              "back"),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 18))
                                                                    ],
                                                                  ),
                                                                  onTap: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                ),
                                                              ),
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 40.0,
                                                                      left:
                                                                          5.0),
                                                            ),
                                                          )
                                                        ],
                                                      )));
                                            }
                                          }
                                        } else if (data[index].attachmentType ==
                                            "3") {
                                          String textDecode =
                                              Uri.decodeQueryComponent(
                                                  Uri.decodeFull(
                                                      data[index].text));
                                          int idx = textDecode.indexOf("(");
                                          var textLatLng = textDecode
                                              .substring(idx + 1,
                                                  textDecode.trim().length - 1)
                                              .split(",");
                                          final url =
                                              'https://www.google.com/maps/search/?api=1&query=${textLatLng[0]},${textLatLng[1].trimLeft()}';
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          }
                                        }
                                      },
                                    )
                                  ],
                                );
                              }),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        widget.attachment.getListImage.length > 0
                            ? screenImageList(widget.attachment)
                            : widget.attachment.getVideo != null
                                ? screenVideo(widget.attachment)
                                : Container(),
                        clip(widget.attachment),
                        _textComposerWidget(widget.attachment)
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

class Chat {
  bool isOriginator, isSelected, runCount;
  String text,
      fileName,
      thumbName,
      messageId,
      refId,
      refFrom,
      refText,
      refType,
      refThumbId,
      refThumbLoc,
      statusRead,
      time,
      attachmentType,
      credential;
  int countCredential;
  DateTime date;
  double progress;

  Chat(
      {this.isOriginator,
      this.runCount,
      this.text,
      this.fileName,
      this.thumbName,
      this.messageId,
      this.refId,
      this.refFrom,
      this.refText,
      this.refType,
      this.refThumbId,
      this.refThumbLoc,
      this.statusRead,
      this.time,
      this.date,
      this.attachmentType,
      this.progress,
      this.countCredential,
      this.credential,
      this.isSelected = false});
  @override
  bool operator ==(other) => other is Chat && other.messageId == messageId;

  @override
  int get hashCode => super.hashCode;
}

class ListMessage with ChangeNotifier {
  List<Chat> messageChat = List();

  List<Chat> get getChat => messageChat;

  set addChat(Chat value) {
    messageChat.add(value);
    notifyListeners();
  }

  set addChatAll(List<Chat> value) {
    messageChat.addAll(value);
    notifyListeners();
  }

  set updateProgress(var value) {
    messageChat[value["index"]].progress = value['value'];
    notifyListeners();
  }

  set trueSelected(int i) {
    messageChat[i].isSelected = true;
    notifyListeners();
  }

  set falseSelected(int i) {
    messageChat[i].isSelected = false;
    notifyListeners();
  }

  set trueRunCount(int i) {
    messageChat[i].runCount = true;
    notifyListeners();
  }

  set countCredential(var value) {
    messageChat[value["index"]].countCredential = value["count"];
    notifyListeners();
  }

  set credential(var value) {
    messageChat[value["index"]].credential = value["credential"];
    notifyListeners();
  }
}

class SelectedChat with ChangeNotifier {
  Map<int, Chat> listSelectedChat = Map();

  Map<int, Chat> get getSelectedChat => listSelectedChat;

  set addList(var i) {
    listSelectedChat[i["index"]] = i["data"];
    notifyListeners();
  }

  set removeList(int i) {
    listSelectedChat.remove(i);
    notifyListeners();
  }

  set clearList(bool value) {
    listSelectedChat.clear();
    notifyListeners();
  }
}

class Attachment with ChangeNotifier {
  var _replyContent;
  bool _ackActive = false,
      _confidentialActive = false,
      _refresh = false,
      _loading = true;
  int _cantForward = 0;
  Directory _path;
  List<File> _listImage = List();
  File _video, _thumbnailVideo, _file;

  get getReplyContent => _replyContent;

  bool get getAckActive => _ackActive;

  bool get loading => _loading;

  bool get refresh => _refresh;

  int get cantForward => _cantForward;

  Directory get path => _path;

  bool get getConfidentialActive => _confidentialActive;

  List<File> get getListImage => _listImage;

  File get getVideo => _video;

  File get getThumbnailVideo => _thumbnailVideo;

  File get getFile => _file;

  set replyContent(var value) {
    _replyContent = value;
    notifyListeners();
  }

  set ackActive(bool value) {
    _ackActive = value;
    notifyListeners();
  }

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set cantForward(int value) {
    _cantForward = value;
    notifyListeners();
  }

  set path(Directory value) {
    _path = value;
    notifyListeners();
  }

  set refresh(bool value) {
    _refresh = value;
    notifyListeners();
  }

  set confidentialActive(bool value) {
    _confidentialActive = value;
    notifyListeners();
  }

  set listImage(List<File> value) {
    _listImage.addAll(value);
    notifyListeners();
  }

  set addListImage(File value) {
    _listImage.add(value);
    notifyListeners();
  }

  set removeListImage(int index) {
    _listImage.removeAt(index);
    notifyListeners();
  }

  set clearListImage(bool value) {
    _listImage.clear();
    notifyListeners();
  }

  set video(File value) {
    _video = value;
    notifyListeners();
  }

  set thumbnailVideo(File value) {
    _thumbnailVideo = value;
    notifyListeners();
  }

  set file(File value) {
    _file = value;
    notifyListeners();
  }
}
