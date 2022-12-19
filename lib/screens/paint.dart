import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';

import 'package:provider/provider.dart';

import '../controller/controller.dart';
import '../widgets/general/appbar.dart';
import '../widgets/general/bigbutton.dart';
import '../widgets/notescreen/bottombar.dart';
import '../widgets/notescreen/bottomitem.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8, Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatermarkPaint &&
          runtimeType == other.runtimeType &&
          price == other.price &&
          watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}

class _MyHomePageState extends State<MyHomePage> {
  ByteData _img = ByteData(0);
  var color = 0;
  var colorChanger = Colors.black;
  var strokeWidth = 5.0;
  final _sign = GlobalKey<SignatureState>();

  List colors = [
    Colors.black,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.lime,
    Colors.green
  ];

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 238, 88),
        appBar: PreferredSize(preferredSize: Size.fromHeight(screenHeight / 12), child: CustomAppBar()),
        body: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 7),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Signature(
              color: colorChanger,
              key: _sign,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.yellow[200],
          padding: MediaQuery.of(context).viewInsets,
          child: Row(
            children: [
              BottomBar(
                  child: Row(children: [
                BottomBarItem(
                    icon: Icons.palette,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SizedBox(
                            height: screenHeight / 5,
                            child: Wrap(alignment: WrapAlignment.center, children: [
                              for (var i = 0; i < colors.length; i++)
                                InkWell(
                                    onTap: () {
                                      print(colors[i]);
                                      Navigator.pop(context);
                                      setState(() {
                                        colorChanger = colors[i];
                                      });
                                    },
                                    child: Container(
                                        margin: EdgeInsets.all(screenWidth / 30),
                                        height: screenHeight / 17,
                                        width: screenWidth / 10,
                                        decoration: BoxDecoration(
                                            color: colors[i], borderRadius: BorderRadius.circular(100))))
                            ])),
                      );
                    }),
                BottomBarItem(
                  icon: Icons.draw_outlined,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                          height: screenHeight / 5,
                          child: Wrap(alignment: WrapAlignment.center, children: [
                            for (var i = 10; i > 0; i--)
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      strokeWidth = (i - 10).abs().toDouble();
                                    });
                                  },
                                  child: Container(
                                      margin: EdgeInsets.all(screenWidth / 30),
                                      height: screenHeight / 17,
                                      width: screenWidth / 10,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(color: Colors.white, width: i * 1.75),
                                        borderRadius: BorderRadius.circular(100),
                                      )))
                          ])),
                    );
                  },
                ),
                BottomBarItem(
                    icon: Icons.delete,
                    onPressed: () {
                      final sign = _sign.currentState;
                      sign!.clear();
                      setState(() {
                        _img = ByteData(0);
                      });
                    })
              ])),
              BigIconButton(
                color: const Color.fromARGB(255, 255, 238, 88),
                icon: Icons.save,
                onPressed: () async {
                  final sign = _sign.currentState;
                  //retrieve image data, do whatever you want with it (send to server, save locally...)
                  final image = await sign!.getData();
                  var data = await image.toByteData(format: ui.ImageByteFormat.png);
                  sign.clear();
                  final encoded = base64.encode(data!.buffer.asUint8List());
                  setState(() {
                    _img = data;
                  });
                  Provider.of<Controller>(context, listen: false).newDrawn(_img);
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ));
  }
}
