import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './tools/network.dart';
import 'package:dio/dio.dart';

class Profile {
  String user = '';
  bool isLogin = false;
  //  好友申请列表
  List friendRequest = [];
  //  头像
  String avatar = '';
  //  昵称
  String nickName = '';
  //  好友列表
  List friendsList = [];

  Profile();

  Profile.fromJson(Map json) {
    user = json['user'];
    isLogin = json['isLogin'];
    friendRequest = json['friendRequest'];
    avatar = json['avatar'];
    friendsList = json['friendsList'];
    nickName = json['nickName'];
  }

  Map<String, dynamic> toJson() => {
    'user': user,
    'isLogin': isLogin,
    'friendRequest': friendRequest,
    'avatar': avatar,
    'friendsList': friendsList,
    'nickName': nickName
  };
}

class Global {
  static SharedPreferences _prefs;
  static Profile profile = Profile();

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();

    String _profile = _prefs.getString('profile');
    Response message;
    if (_profile != null) {
      try {
        //  如果存在用户，则拉取聊天记录
        Map decodeContent = jsonDecode(_profile != null ? _profile : '');
        profile = Profile.fromJson(decodeContent);
        message = await Network.get('getAllMessage', { 'userName' : decodeContent['user'] });
      } catch (e) {
        print(e);
      }
    }
    return {
      'messageArray': message != null ? message.data : []
    };
  }

  static saveProfile() => _prefs.setString('profile', jsonEncode(profile.toJson()));
}

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile(); //保存Profile变更
    super.notifyListeners();
  }
}

class UserModle extends ProfileChangeNotifier {
  String get user => _profile.user;
  set user(String user) {
    _profile.user = user;
    notifyListeners();
  }

  bool get isLogin => _profile.isLogin;
  set isLogin(bool value) {
    _profile.isLogin = value;
    notifyListeners();
  }

  List get friendRequest => _profile.friendRequest;
  set friendRequest(List value) {
    _profile.friendRequest = value;
    notifyListeners();
  }

  String get avatar => _profile.avatar;
  set avatar(String value) {
    _profile.avatar = value;
    notifyListeners();
  }

  List get friendsList => _profile.friendsList;
  set friendsList(List value) {
    _profile.friendsList = value;
    notifyListeners();
  }

  String get nickName => _profile.nickName;
  set nickName(String value) {
    _profile.nickName = value;
    notifyListeners();
  }

  void apiUpdate(Map data) {
    _profile.friendRequest = data['friendRequest'];
    _profile.friendsList = data['friendsList'];
    _profile.nickName = data['nickName'];
    _profile.avatar = data['avatar'];
  }

  Map get modelJson => _profile.toJson();

  String toUser = '123';
  String get sayTo => toUser;
  set sayTo(String value) {
    toUser = value;
    notifyListeners();
  }

  Map findFriendInfo(name) {
    return friendsList.firstWhere((item) => name == item['userName']);
  }
}

class MessageNotifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class SingleMessage {
  String owner;
  String content;
  int timeStamp;

  SingleMessage.fromJson(Map json) {
    owner = json['owner'];
    content = json['content'];
    timeStamp = json['timeStamp'];
  }
}

class SingleMesCollection {
  String bothOwner;
  List<SingleMessage> message = [];
  int user1flag;
  int user2flag;

  SingleMesCollection();

  SingleMesCollection.fromJson(Map json) {
    bothOwner = json['bothOwner'];
    message = json['message'].map<SingleMessage>((item) {
      return SingleMessage.fromJson(item);
    }).toList();
    user1flag = json['user1_flag'];
    user2flag = json['user2_flag'];
  }
}

class Message extends MessageNotifier {
  Message();
  List<SingleMesCollection> messageArray;
  void assignFromJson(List json) {
    messageArray = json.map((item) {
      return SingleMesCollection.fromJson(item);
    }).toList();
  }

  Message.fromJson(List json) {
    messageArray = json.map<SingleMesCollection>((item) {
      return SingleMesCollection.fromJson(item);
    }).toList();
  }

  String getLastMessage(String name) {
    return messageArray.firstWhere((item) => (item.bothOwner.contains(name))).message.last.content;
  }

  SingleMesCollection getUserMesCollection(String name) {
    return messageArray.firstWhere((item) => item.bothOwner.contains(name), orElse: () => new SingleMesCollection());
  }
}