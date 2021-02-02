import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ReportABug extends StatefulWidget {
  static String id = "reportABug";
  @override
  _ReportABugState createState() => _ReportABugState();
}

class _ReportABugState extends State<ReportABug> {
  static final String id = "report";
  final String url =
      'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAMAADGaV1RUQlRDWkc1V1BHRDBVRjkxSkk1REtEREI2NS4u';
  InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.darkPrimary,
          centerTitle: true,
          title: Text('Report a bug',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: MyColors.white)),
        ),
        body: InAppWebView(
          initialUrl: url,
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
          },
        ));
  }
}
