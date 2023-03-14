import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'branch_utils.dart';
import 'constants.dart';
import 'notifications.dart';

Future<void> main() async {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String deeplinkPath = "";

  @override
  void initState() {
    super.initState();

    setupLocalNotifications();

/*
    Used to append metadata to any events tracked via the Branch SDK
    • Be sure to call this BEFORE the Branch SDK is initialized, so that the metadata gets added to install and open events
    • Required to set the analytics ID if you have any Data Integrations (i.e. Adobe Analytics)
    • More info: https://help.branch.io/developers-hub/docs/flutter-sdk-full-reference#setrequestmetadata
*/
    FlutterBranchSdk.setRequestMetadata("key", "value");

    FlutterBranchSdk.initSession().listen((data) {
      deeplinkPath = getDeepLinkPath(data);
      print(deeplinkPath);
      switch (deeplinkPath) {
        case QUICK_LINKS:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuickLinkScreen()),
          );
          break;
        case EVENT_TRACKING:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const EventTrackingScreen()),
          );
          break;
        case NOTIFICATIONS:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
          break;
      }
    });

    //run validateSDKIntegration() to check if Branch SDK dependencies are setup correctly
    //output will appear in the Debug Console
    //FlutterBranchSdk.validateSDKIntegration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            SizedBox(
                width: double.infinity,
                height: 100,
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QuickLinkScreen()),
                        );
                      },
                      child: const Text(QUICK_LINKS),
                    ))),
            SizedBox(
                width: double.infinity,
                height: 100,
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const EventTrackingScreen()),
                        );
                      },
                      child: const Text(EVENT_TRACKING),
                    ))),
            SizedBox(
                width: double.infinity,
                height: 100,
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationsScreen()),
                        );
                      },
                      child: const Text(NOTIFICATIONS),
                    )))
          ])),
    );
  }
}

class QuickLinkScreen extends StatefulWidget {
  const QuickLinkScreen({Key? key}) : super(key: key);

  @override
  QuickLinkScreenState createState() => QuickLinkScreenState();
}

class QuickLinkScreenState extends State<QuickLinkScreen> {
  String dropdownvalue = QUICK_LINKS;

  var items = [
    QUICK_LINKS,
    EVENT_TRACKING,
    NOTIFICATIONS,
  ];

  late String branchLink;
  BranchUniversalObject buo =
      BranchUniversalObject(canonicalIdentifier: 'flutter/branch');

  String alias = "";

  final textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //use resizeToAvoidBottomInset to prevent "overflowed by pixels" issue. More info: https://stackoverflow.com/questions/54156420/flutter-bottom-overflowed-by-119-pixels
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(QUICK_LINKS),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              const Text('Create a Quick Link', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 25),
              SizedBox(
                  width: 200.0,
                  child: TextField(
                    onChanged: (value) {
                      alias = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter alias',
                    ),
                  )),
              const SizedBox(height: 25),
              const Text('Deep Link Destination',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 25),
              DropdownButton(
                value: dropdownvalue,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      createBranchLink(buo, alias, dropdownvalue).then(
                          (value) => {
                                branchLink = value,
                                textEditingController.text = branchLink
                              });
                    },
                    child: const Text('CREATE BRANCH LINK'),
                  )),
              const SizedBox(height: 25),
              TextField(
                  controller: textEditingController,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 25),
              SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      shareLink(buo);
                    },
                    child: const Text('SHARE'),
                  )),
              const SizedBox(height: 25),
              SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      createQRCode(buo, Colors.black, Colors.white);
                    },
                    child: const Text('QR Code'),
                  )),
            ])));
  }
}

enum EventType { commerce, content, lifecycle, custom }

class EventTrackingScreen extends StatefulWidget {
  const EventTrackingScreen({Key? key}) : super(key: key);

  @override
  EventTrackingScreenState createState() => EventTrackingScreenState();
}

class EventTrackingScreenState extends State<EventTrackingScreen> {
  String dropdownvalue = COMMERCE_EVENT;

  var items = [COMMERCE_EVENT, CONTENT_EVENT, LIFECYCLE_EVENT, CUSTOM_EVENT];

  String id = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //use resizeToAvoidBottomInset to prevent "overflowed by pixels" issue. More info: https://stackoverflow.com/questions/54156420/flutter-bottom-overflowed-by-119-pixels
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(EVENT_TRACKING),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              const Text('Track Events', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 25),
              SizedBox(
                  width: 200.0,
                  child: TextField(
                    onChanged: (value) {
                      id = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter user ID',
                    ),
                  )),
              const SizedBox(height: 25),
              SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      login(id);
                    },
                    child: const Text('Login'),
                  )),
              const SizedBox(height: 25),
              SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      logout();
                    },
                    child: const Text('Logout'),
                  )),
              const SizedBox(height: 25),
              DropdownButton(
                value: dropdownvalue,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      switch (dropdownvalue) {
                        case COMMERCE_EVENT:
                          trackStandardBranchEvent(
                              BranchStandardEvent.PURCHASE);
                          break;
                        case CONTENT_EVENT:
                          trackStandardBranchEvent(
                              BranchStandardEvent.VIEW_ITEM);
                          break;
                        case LIFECYCLE_EVENT:
                          trackStandardBranchEvent(BranchStandardEvent.LOGIN);
                          break;
                        case CUSTOM_EVENT:
                          trackCustomBranchEvent(CUSTOM_EVENT);
                          break;
                      }
                    },
                    child: const Text('TRACK EVENT'),
                  )),
            ])));
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  String dropdownvalue = QUICK_LINKS;
  String localNotificationTitle = "";
  String localNotificationMessage = "";
  String deeplink = "";

  var items = [
    QUICK_LINKS,
    EVENT_TRACKING,
    NOTIFICATIONS,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //use resizeToAvoidBottomInset to prevent "overflowed by pixels" issue. More info: https://stackoverflow.com/questions/54156420/flutter-bottom-overflowed-by-119-pixels
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(NOTIFICATIONS),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              const Text('Trigger Push Notifications',
                  style: TextStyle(fontSize: 40)),
              const SizedBox(height: 25),
              SizedBox(
                  width: 200.0,
                  child: TextField(
                    onChanged: (value) {
                      localNotificationTitle = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Title',
                    ),
                  )),
              const SizedBox(height: 25),
              SizedBox(
                  width: 200.0,
                  child: TextField(
                    onChanged: (value) {
                      localNotificationMessage = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Message',
                    ),
                  )),
              const SizedBox(height: 25),
              const Text('Deep Link Destination',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 25),
              DropdownButton(
                value: dropdownvalue,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      switch (dropdownvalue) {
                        case QUICK_LINKS:
                          deeplink = QUICK_LINKS_DEEP_LINK;
                          break;
                        case EVENT_TRACKING:
                          deeplink = EVENT_TRACKING_DEEP_LINK;
                          break;
                        case NOTIFICATIONS:
                          deeplink = NOTIFICATIONS_DEEP_LINK;
                          break;
                      }
                      triggerLocalNotification(localNotificationTitle,
                          localNotificationMessage, deeplink);
                    },
                    child: const Text('TRIGGER'),
                  )),
            ])));
  }
}
