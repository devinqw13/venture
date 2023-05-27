import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Models/VenUser.dart';

Future<dynamic> showReportSheet({
  required BuildContext context,
  required int reportee,
  required String type
}) async {
  // var response = await Get.bottomSheet(
  //   ReportSheet(reportee: reportee, type: type),
  //   // useRootNavigator: true,
  //   isScrollControlled: true
  // );
  var response = await showModalBottomSheet(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
    backgroundColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.75
    ),
    builder: (context) => ReportSheet(reportee: reportee, type: type)
  );
  return response;
}

class ReportSheet extends StatefulWidget {
  final int reportee;
  final String type;
  ReportSheet({Key? key, required this.reportee, required this.type}) : super(key: key);

  @override 
  _ReportSheet createState() => _ReportSheet();
}

class _ReportSheet extends State<ReportSheet> {
  bool _selectedAdditionalInfo = false;
  bool _selectedAdditionalInfoSubmit = false;
  String? infoDesc;
  // static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

  void pushAdditional() {
    setState(() => _selectedAdditionalInfo = true);
  }

  void pushAdditionalSubmit(String desc) {
    setState(() => infoDesc = desc);
    setState(() => _selectedAdditionalInfoSubmit = true);
  }

  void closeSheet(var results) {
    Navigator.pop(context, results);
  }

  void submitReport(String? desc, String? notes) {
    report(
      context,
      VenUser().userKey.value,
      widget.type,
      desc,
      widget.reportee,
      notes
    );

    closeSheet(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Navigator(
          onPopPage: (route, result) {
            if(route.settings.name == '/report-additional-info') {
              setState(() => _selectedAdditionalInfo = false);
            }else if(route.settings.name == '/report-additional-info-submit') {
              setState(() {
                _selectedAdditionalInfoSubmit = false;
                infoDesc = null;
              });
            }
            return route.didPop(result);
          },
          pages: [
            MaterialPage(
              name: '/report-init',
              child: InitReport(
                pushAdditional: pushAdditional,
                closeSheet: closeSheet,
                submitReport: submitReport,
              )
            ),

            if(_selectedAdditionalInfo)
              MaterialPage(
                name: '/report-additional-info',
                child: AdditionalInformation(
                  closeSheet: closeSheet,
                  pushAdditionalSubmit: pushAdditionalSubmit,
                )
              ),

            if(_selectedAdditionalInfoSubmit)
              MaterialPage(
                name: '/report-additional-info-submit',
                child: AdditionalInformationSubmit(
                  closeSheet: closeSheet,
                  submitReport: submitReport,
                  desc: infoDesc!,
                )
              ),
          ],
        )
      )
    );
    // return Container(
    //   // padding: EdgeInsets.all(16),
    //   // height: MediaQuery.of(context).size.height * 0.75,
    //   // constraints: BoxConstraints(
    //   //   maxHeight: MediaQuery.of(context).size.height * 0.75,
    //   // ),
    //   decoration: BoxDecoration(
    //     color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
    //     borderRadius: BorderRadius.only(
    //       topLeft: Radius.circular(16),
    //       topRight: Radius.circular(16),
    //     )
    //   ),
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.only(
    //       topLeft: Radius.circular(16),
    //       topRight: Radius.circular(16),
    //     ),
    //     child: Navigator(
    //       onPopPage: (route, result) {
    //         print(route.settings.name);
    //         if(route.settings.name == '/report-additional-info') {
    //           setState(() => _selectedAdditionalInfo = false);
    //         }else if(route.settings.name == '/report-additional-info-submit') {
    //           setState(() {
    //             _selectedAdditionalInfoSubmit = false;
    //             infoDesc = null;
    //           });
    //         }
    //         return route.didPop(result);
    //       },
    //       pages: [
    //         MaterialPage(
    //           name: '/report-init',
    //           child: InitReport(
    //             pushAdditional: pushAdditional,
    //             closeSheet: closeSheet,
    //             submitReport: submitReport,
    //           )
    //         ),

    //         if(_selectedAdditionalInfo)
    //           MaterialPage(
    //             name: '/report-additional-info',
    //             child: AdditionalInformation(
    //               closeSheet: closeSheet,
    //               pushAdditionalSubmit: pushAdditionalSubmit,
    //             )
    //           ),

    //         if(_selectedAdditionalInfoSubmit)
    //           MaterialPage(
    //             name: '/report-additional-info-submit',
    //             child: AdditionalInformationSubmit(
    //               closeSheet: closeSheet,
    //               submitReport: submitReport,
    //               desc: infoDesc!,
    //             )
    //           ),
    //       ],
    //     )
    //   ),
    // );
  }
}

class InitReport extends StatefulWidget {
  final VoidCallback pushAdditional;
  // final VoidCallback closeSheet;
  final void Function(dynamic) closeSheet;
  final void Function(String?, String?) submitReport;
  InitReport({Key? key, required this.pushAdditional, required this.closeSheet, required this.submitReport}) : super(key: key);

  @override
  _InitReport createState() => _InitReport();
}

class _InitReport extends State<InitReport> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        title: Text(
          "Report",
          style: TextStyle(
            color: Get.isDarkMode ? Colors.white : Colors.black
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => widget.closeSheet(null),
            icon: Icon(Icons.close)
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.1),
          child: Container(
              color: Colors.grey,
              height: 0.1,
          ),
        )
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reporting something?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "You can submit a report now without adding any additional information.",
                          style: TextStyle(
                            fontSize: 16.0
                          ),
                        )
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Add information to help us understand the reason for your report.",
                          style: TextStyle(
                            fontSize: 16.0
                          ),
                        )
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Your report will be submitted anonymously.",
                          style: TextStyle(
                            fontSize: 16.0
                          ),
                        )
                      )
                    ],
                  )
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.submitReport(null, null),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Text(
                        "Submit Report",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                    ),
                  )
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.pushAdditional,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Text(
                        "Add information",
                        style: TextStyle(
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                    ),
                  )
                )
              ],
            ),
            SizedBox(height: 20)
            // IconButton(
            //   onPressed: widget.pushAdditional,
            //   icon: Icon(Icons.ac_unit)
            // )

          ],
        ),
      )
    );
  }
}

class AdditionalInformation extends StatefulWidget {
  final void Function(dynamic) closeSheet;
  // final VoidCallback pushAdditionalSubmit;
  final void Function(String) pushAdditionalSubmit;
  AdditionalInformation({Key? key, required this.closeSheet, required this.pushAdditionalSubmit}) : super(key: key);

  @override
  _AdditionalInformation createState() => _AdditionalInformation();
}

class _AdditionalInformation extends State<AdditionalInformation> {

  Widget _buildListTile(String title) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),
      ),
      trailing: Container(
        width: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
      onTap: () {
        widget.pushAdditionalSubmit(title);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(IconlyLight.arrow_left, size: 25)
        ),
        title: Text(
          "Report",
          style: TextStyle(
            color: Get.isDarkMode ? Colors.white : Colors.black
          ),
        ),
        actions: [
          IconButton(
            // onPressed: widget.closeSheet,
            onPressed: () => widget.closeSheet(null),
            icon: Icon(Icons.close)
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.1),
          child: Container(
              color: Colors.grey,
              height: 0.1,
          ),
        )
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: ListView(
          children: [
            Text(
              "Please select an issue",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Please select a problem that best fit the report.",
              style: TextStyle(
                color: Colors.grey
              ),
            ),
            SizedBox(height: 20),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              columnWidths: const <int, TableColumnWidth>{
                // 0: IntrinsicColumnWidth(),
                // 1: FlexColumnWidth(),
                0: FlexColumnWidth(),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey,
                  width: 0.3
                ),
                bottom: BorderSide(
                  color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey,
                  width: 0.3
                )
              ),
              children: [
                TableRow(
                  children: <Widget>[
                    _buildListTile('False Information'),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildListTile('Spam'),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildListTile('Harassment'),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildListTile('Violence'),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildListTile('Nudity'),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildListTile('Terrorism'),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    _buildListTile('Something else'),
                  ],
                ),
              ]
            )
          ],
        )
      )
    );
  }
}

class AdditionalInformationSubmit extends StatefulWidget {
  final String desc;
  final void Function(dynamic) closeSheet;
  final void Function(String?, String?) submitReport;
  AdditionalInformationSubmit({Key? key, required this.closeSheet, required this.submitReport, required this.desc}) : super(key: key);

  @override
  _AdditionalInformationSubmit createState() => _AdditionalInformationSubmit();
}

class _AdditionalInformationSubmit extends State<AdditionalInformationSubmit> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(IconlyLight.arrow_left, size: 25)
          ),
          title: Text(
            "Report",
            style: TextStyle(
              color: Get.isDarkMode ? Colors.white : Colors.black
            ),
          ),
          actions: [
            IconButton(
              // onPressed: widget.closeSheet,
              onPressed: () => widget.closeSheet(null),
              icon: Icon(Icons.close)
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.1),
            child: Container(
                color: Colors.grey,
                height: 0.1,
            ),
          )
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 16
                          ),
                          children: [
                            TextSpan(
                              text: "You are reporting that this contains "
                            ),
                            TextSpan(
                              text: "${widget.desc}. ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ]
                        )
                      ),
                      SizedBox(height: 20),
                      Text("Provide any addition information"),
                      SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          // boxShadow: [
                          //   BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(0,3),
                          //   blurRadius: 1
                          //   ),
                          // ]
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        KeyboardUtil.hideKeyboard(context);
                        widget.submitReport(widget.desc, _textController.text);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Text(
                          "Submit Report",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      ),
                    )
                  )
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
          // child: ListView(
          //   children: [
          //     Text.rich(
          //       TextSpan(
          //         style: TextStyle(
          //           fontSize: 16
          //         ),
          //         children: [
          //           TextSpan(
          //             text: "You are reporting that this contains "
          //           ),
          //           TextSpan(
          //             text: "${widget.desc}. ",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold
          //             )
          //           ),
          //         ]
          //       )
          //     ),
          //     SizedBox(height: 20),
          //     Text("Provide any addition information"),
          //     SizedBox(height: 5),
          //     Container(
          //       decoration: BoxDecoration(
          //         color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey[300],
          //         borderRadius: BorderRadius.circular(10),
          //         // boxShadow: [
          //         //   BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(0,3),
          //         //   blurRadius: 1
          //         //   ),
          //         // ]
          //       ),
          //       child: TextField(
          //         controller: _textController,
          //         maxLines: 5,
          //       ),
          //     ),
          //   ]
          // )
          // child: Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text.rich(
          //       TextSpan(
          //         style: TextStyle(
          //           fontSize: 16
          //         ),
          //         children: [
          //           TextSpan(
          //             text: "You are reporting that this contains "
          //           ),
          //           TextSpan(
          //             text: "${widget.desc}. ",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold
          //             )
          //           ),
          //         ]
          //       )
          //     ),
          //     SizedBox(height: 20),
          //     Text("Provide any addition information"),
          //     SizedBox(height: 5),
          //     Container(
          //       decoration: BoxDecoration(
          //         color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey[300],
          //         borderRadius: BorderRadius.circular(10),
          //         // boxShadow: [
          //         //   BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(0,3),
          //         //   blurRadius: 1
          //         //   ),
          //         // ]
          //       ),
          //       child: TextField(
          //         controller: _textController,
          //         maxLines: 5,
          //       ),
          //     ),
          //     Expanded(child: Container()),
          //     Row(
          //       children: [
          //         Expanded(
          //           child: ElevatedButton(
          //             onPressed: () {
          //               KeyboardUtil.hideKeyboard(context);
          //               widget.submitReport(widget.desc, _textController.text);
          //             },
          //             child: Padding(
          //               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          //               child: Text(
          //                 "Submit Report",
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontWeight: FontWeight.bold
          //                 ),
          //               )
          //             ),
          //             style: ElevatedButton.styleFrom(
          //               elevation: 0,
          //               backgroundColor: primaryOrange,
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(10),
          //               )
          //             ),
          //           )
          //         )
          //       ],
          //     ),
          //     SizedBox(height: 20)
          //   ],
          // ),
        )
      )
    );
  }
}