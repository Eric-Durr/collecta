import 'package:collecta/constants.dart';
import 'package:collecta/db/transect_point_database.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:flutter/material.dart';

import 'package:collecta/size_config.dart';
import 'package:flutter_map/plugin_api.dart';

class MeasureList extends StatefulWidget {
  List<TransectPoint> measures;
  MeasureList({
    Key? key,
    required this.measures,
  }) : super(key: key);

  @override
  State<MeasureList> createState() => _MeasureListState();
}

class _MeasureListState extends State<MeasureList> {
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      widget.measures.sort((a, b) => a.created.compareTo(b.created));
    });
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
                                            Container(
                                              width:
                                                  getProportionateScreenWidth(
                                                      140),
                                              child: Text(
                                                '${getPointName(widget.measures[index])}',
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenWidth(
                                                          15),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Point ${index + 1}/100',
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenWidth(
                                                        13),
                                              ),
                                            ),
                                            Container(
                                              width:
                                                  getProportionateScreenWidth(
                                                      140),
                                              child: Text(
                                                'Area ${widget.measures[index].areaId}',
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenWidth(
                                                          12),
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
                                      'HITS: ${widget.measures[index].hits}    Time: ${widget.measures[index].mark}')
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
