import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'constants.dart';

late BranchUniversalObject branchUniversalObject;
late BranchLinkProperties linkProperties;
late String branchLink;

/* 
  Creates a Branch link with the specified Branch Universal Object (buo), alias and deeplinkPath
  • buo - a content reference. More info here: https://www.branch.io/resources/blog/branch-concepts-the-branch-universal-object/
  • alias - unique, public-facing field on a link
  • deepLinkPath - the $deeplink_path value for the link
    • possible values: 
      • Quick Links - navigates to the quick links screen 
      • Event Tracking - navigates to the event tracking screen
      • Notifications - navigates to the push notifications screen
*/
Future<String> createBranchLink(
    BranchUniversalObject buo, String alias, String deeplinkPath) async {
  linkProperties = BranchLinkProperties(alias: alias);
  linkProperties.addControlParam(DEEPLINK_PATH, deeplinkPath);
  BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo, linkProperties: linkProperties);
  if (response.success) {
    print('Link generated: ${response.result}');
    branchLink = response.result;
    branchUniversalObject = buo;
    return branchLink;
  } else {
    print('Error : ${response.errorCode} - ${response.errorMessage}');
    return "";
  }
}

/*
  Share a Branch link using a Share Sheet
  • More info here: https://help.branch.io/developers-hub/docs/flutter-sdk-full-reference#showsharesheet
*/
void shareLink(BranchUniversalObject buo) async {
  BranchResponse response = await FlutterBranchSdk.showShareSheet(
      buo: buo,
      linkProperties: linkProperties,
      messageText: branchLink,
      androidMessageTitle: 'Share your Branch link!',
      androidSharingTitle: 'Share with: ');

  if (response.success) {
    print('showShareSheet Success');
  } else {
    print('Error : ${response.errorCode} - ${response.errorMessage}');
  }
}

/*
  Create a Branch QR code with link data
  • primaryColor - the QR code (foreground) color
  • backgroundColor - the QR code (background) color
  • Colors can be specified as Colors.Black or Hexadecimal (0xff443a49)
*/
Future<void> createQRCode(BranchUniversalObject buo, Color? primaryColor,
    Color? backgroundColor) async {
  BranchResponse response = await FlutterBranchSdk.getQRCodeAsImage(
      buo: buo,
      linkProperties: linkProperties,
      qrCode: BranchQrCode(
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          imageFormat: BranchImageFormat.PNG));

  if (response.success) {
    print('Successfully created QR code');
  } else {
    print(
        'Error creating QR Code : ${response.errorCode} - ${response.errorMessage}');
  }
}

/*
  Set the identity from cross-platform and cross-device attribution
  • Stored on events as the developer identity field
  • Best practices:
    • Deciding on what ID to set: https://help.branch.io/developers-hub/docs/flutter-sdk-full-reference#setidentity 
    • Don't send PII: https://help.branch.io/using-branch/docs/best-practices-to-avoid-sending-pii-to-branch#developer-identity
*/
void login(String userID) {
  FlutterBranchSdk.setIdentity(userID);
}

/*
removes the developer ID from events tracked after this function is called
• call when the user logs out of their account
*/
void logout() {
  FlutterBranchSdk.logout();
}

/*
  Use to obtain the $deeplink_path from the Branch link
  • can use this value to route the user to the proper screen in the app
  • possible values: 
      • Quick Links - navigates to the quick links screen 
      • Event Tracking - navigates to the event tracking screen
      • Notifications - navigates to the push notifications screen
*/
String getDeepLinkPath(Map<dynamic, dynamic> data) {
  if (data.containsKey(DEEPLINK_PATH)) {
    return data[DEEPLINK_PATH];
  } else {
    return "";
  }
}

/* 
  Track a standard Branch event (commerce, content, or user lifecylce event)
  • Example: BranchStandardEvent.PURCHASE
  • To see the full list of Branch events, check Branch's Event Ontology: https://help.branch.io/developers-hub/docs/branch-event-ontology 
*/
void trackStandardBranchEvent(BranchStandardEvent branchStandardEvent) {
  BranchEvent branchEvent = BranchEvent.standardEvent(branchStandardEvent);
  trackBranchEvent(branchEvent);
}

/* 
  Track a custom Branch event
  • Use this function if the event is not available as one of Branch's standard events
  • Can pass in any String as the event name for your custom event
*/
void trackCustomBranchEvent(String customEventName) {
  BranchEvent branchEvent = BranchEvent.customEvent(customEventName);
  trackBranchEvent(branchEvent);
}

/* 
  Track a Branch event
  • Creates a buo with a canonicalIdentifier of id
*/
void trackBranchEvent(BranchEvent branchEvent) {
  branchUniversalObject = BranchUniversalObject(canonicalIdentifier: "id");
  FlutterBranchSdk.trackContent(
      buo: [branchUniversalObject], branchEvent: branchEvent);
}

/*
  Retrieve the Branch latest referring params at any point in the app lifecycle
  • Use if you need to wait until after an onboarding / login flow to deep link
  • Important: Call this function AFTER the Branch SDK is initialized (or the link data will be old/empty)
*/
Future<Map<dynamic, dynamic>> getLatestBranchReferringParameters() async {
  Map<dynamic, dynamic> params =
      await FlutterBranchSdk.getLatestReferringParams();
  return params;
}

/*
  Called when a notification is clicked  
    • payload is the Branch link
    • Use handleDeepLink() for intra-app routing. More info: https://pub.dev/packages/flutter_branch_sdk#handle-links-in-your-own-app
*/
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    print('notification payload: $payload');
    FlutterBranchSdk.handleDeepLink(payload!);
  }
}
