import 'package:chap_app_wiikko/ui/widgets/mes_widgets.dart';
import 'package:flutter/material.dart';

class LoadingAlertDialog extends StatelessWidget {
  String titleText = "Chargement";
  String contentText = "Chargement en cours...";
  bool annulerButton = false;

  LoadingAlertDialog({this.titleText, this.contentText, this.annulerButton}) {
    if (titleText == null) titleText = "Chargement";
    if (contentText == null) contentText = "Chargement en cours...";
    if (annulerButton == null) annulerButton = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget circular = CircleAvatar(
      radius: 55,
      backgroundColor: Colors.grey.shade200,
      child: CircularProgressIndicator(),
    );

    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(right: 16.0),
          height: 150,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(75),
                  bottomLeft: Radius.circular(75),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Row(
            children: <Widget>[
              SizedBox(width: 20.0),
              circular,
              SizedBox(width: 20.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        titleText,
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(height: 10.0),
                      SingleChildScrollView(
                        child: Text(contentText),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Container(
                            child: !annulerButton
                                ? null
                                : Expanded(
                                    child: RaisedButton(
                                      child: MesWidgets.textAvecStyle("Ok"),
                                      color: Colors.red,
                                      colorBrightness: Brightness.dark,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                    ),
                                  ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
