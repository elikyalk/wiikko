import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef LikeButtonTapCallback = Future<bool> Function(bool isLiked);

class MesWidgets {
  static Text textAvecStyle(String texte,
      {double textSize = 12,
        Color color = Colors.white,
        FontStyle fontStyle = FontStyle.normal,
        bool softWrap = true,
        TextOverflow overflow = TextOverflow.ellipsis,
        int maxLines = 10000,
        textScaleFactor = 1.0,
        FontWeight fontWeight = FontWeight.normal,
        TextBaseline textBaseline = TextBaseline.alphabetic,
        TextDecoration decoration = TextDecoration.lineThrough,
        TextDecorationStyle decorationStyle = TextDecorationStyle.solid,
        TextAlign textAlign: TextAlign.start,
        String fontFamily}) {
    return Text(
      texte,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: textSize,
        color: color,
        fontStyle: fontStyle,
        fontWeight: fontWeight,
        textBaseline: TextBaseline.alphabetic,
        decoration: TextDecoration.none,
        decorationStyle: TextDecorationStyle.dashed,
        fontFamily: fontFamily,
      ),
    );
  }

  static Widget inputField(State state, void onChanged(String value),
      {String hintText = "",
        IconData icon,
        double textSize = 12,
        Color color = Colors.black,
        FontStyle fontStyle = FontStyle.normal,
        int maxLines = 1,
        int maxLength = 30,
        TextCapitalization capitalization = TextCapitalization.none,
        bool autocorrect = false,
        bool isPassword = false,
        TextInputType keyboardType = TextInputType.text,
        bool visiblePassword = true,
        String errorMessage = "Le champs contient une erreur !",
        double borderSize = 10.0,
        double leftPadding = 0,
        double rightPadding = 0}) {
    bool _valueError = false;

    return Container(
      padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(borderSize))),
            child: TextField(
              onChanged: (String string) {
                state.setState(() {
                  _valueError = false;
                });
                if (string.length != 9) {
                  state.setState(() {
                    _valueError = true;
                  });
                }
                onChanged(string);
              },
              style: TextStyle(
                  fontSize: textSize, color: color, fontStyle: fontStyle),
              //textAlign: TextAlign.center,
              maxLines: maxLines,
              maxLength: maxLength,
              autocorrect: autocorrect,
              textCapitalization: capitalization,
              obscureText: !visiblePassword,
              decoration: InputDecoration(
                  prefixIcon: icon == null
                      ? null
                      : Icon(
                    icon,
                    color: Colors.black54,
                  ),
                  suffixIcon: !isPassword
                      ? null
                      : IconButton(
                      icon: Icon(
                          visiblePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54),
                      onPressed: () {
                        state.setState(() {
                          visiblePassword = !visiblePassword;
                        });
                      }),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.black54,
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(241, 239, 241, 1),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(borderSize)),
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0)),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            child: _valueError
                ? MesWidgets.textAvecStyle(errorMessage, color: Colors.red)
                : null,
          ),
        ],
      ),
    );
  }

}
