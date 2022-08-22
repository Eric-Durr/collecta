import 'package:collecta/constants.dart';
import 'package:collecta/db/transect_point_database.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:flutter/material.dart';

import 'package:collecta/size_config.dart';
import 'package:flutter_map/plugin_api.dart';

class MeasureList extends StatefulWidget {
  final List<TransectPoint> measures;
  const MeasureList({
    Key? key,
    required this.measures,
  }) : super(key: key);

  @override
  State<MeasureList> createState() => _MeasureListState();
}

class _MeasureListState extends State<MeasureList> {
  Color listNumbersColor(int length) {
    if (length <= 25) {
      return lightColorScheme.error;
    } else if (length > 25 && length < 100) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Color getInfoColor(TransectPoint? point) {
    if (point!.mulch == true) {
      return Color(0xf4adad33);
    }
    if (point.soil == true) {
      return Colors.brown;
    }
    if (point.rock == true) {
      return Colors.blueGrey;
    }
    if (point.stone == true) {
      return Colors.grey;
    }
    if (point.species != '') {
      return Colors.teal;
    }
    return Colors.transparent;
  }

  String? getPointName(TransectPoint? point) {
    if (point!.species != '') {
      return point.species;
    }
    if (point.mulch == true) {
      return 'Mulch';
    }
    if (point.rock == true) {
      return 'Rock';
    }
    if (point.soil == true) {
      return 'Soil';
    }
    if (point.stone == true) {
      return 'Stone';
    }
    return 'Error in name';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15))),
      height: getProportionateScreenHeight(500),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  'TODAY MEASURES LIST',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: getProportionateScreenWidth(14),
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(10)),
                  child: Container(
                    width: getProportionateScreenWidth(90),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 3, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  '${(widget.measures.length)}/100',
                  style: TextStyle(
                      color: listNumbersColor(widget.measures.length),
                      fontSize: getProportionateScreenWidth(15),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          widget.measures.isEmpty
              ? Text('No Transect measures yet')
              : Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: widget.measures.length,
                    itemBuilder: (context, index) {
                      // Point measure card
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Card(
                            elevation: 1,
                            margin: EdgeInsets.fromLTRB(
                                10,
                                getProportionateScreenHeight(20),
                                10,
                                getProportionateScreenWidth(5)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/logo.png',
                                        color: Colors.grey,
                                        width: getProportionateScreenWidth(50),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                getProportionateScreenWidth(
                                                    20)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Area ${widget.measures[index].areaId} - Point ${index + 1}/100',
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenWidth(
                                                        15),
                                              ),
                                            ),
                                            Container(
                                              width:
                                                  getProportionateScreenWidth(
                                                      140),
                                              child: Text(
                                                '${getPointName(widget.measures[index])}',
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenWidth(
                                                          14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width:
                                                getProportionateScreenWidth(40),
                                            child: FloatingActionButton(
                                              heroTag: 'btn$index',
                                              onPressed: () {},
                                              elevation: 0,
                                              backgroundColor: getInfoColor(
                                                  widget.measures[index]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                      'Hits: ${widget.measures[index].hits}    Time: ${widget.measures[index].mark}')
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0, 0, getProportionateScreenWidth(10), 0),
                            child: createdDate(index),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  String twoDigits(int num) => num.toString().padLeft(2, '0');

  Text createdDate(int index) {
    return Text(
      '${widget.measures[index].created.month}/${widget.measures[index].created.day}/${widget.measures[index].created.year} - ${twoDigits(widget.measures[index].created.hour)}:${twoDigits(widget.measures[index].created.minute)}:${twoDigits(widget.measures[index].created.second)}',
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
