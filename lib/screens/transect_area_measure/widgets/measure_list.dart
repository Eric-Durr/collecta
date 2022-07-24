import 'package:collecta/constants.dart';
import 'package:collecta/db/transect_point_database.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:flutter/material.dart';

import 'package:collecta/size_config.dart';

class MeasureList extends StatefulWidget {
  const MeasureList({
    Key? key,
  }) : super(key: key);

  @override
  State<MeasureList> createState() => _MeasureListState();
}

class _MeasureListState extends State<MeasureList> {
  List<TransectPoint> measures = [];
  bool isBussy = false;

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

    // Mocked connection check
    initLocalDB();
  }

  Future initLocalDB() async {
    setState(() {
      isBussy = true;
    });

    measures = await TransectPointDatabase.instance.readAll();
    setState(() {
      isBussy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Text(
              'TEAM MEASURE HISTORY',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: getProportionateScreenWidth(14),
                  fontWeight: FontWeight.bold),
            ),
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
            Text(
              '${(measures.length)}/100',
              style: TextStyle(
                  color: listNumbersColor(measures.length),
                  fontSize: getProportionateScreenWidth(15),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        isBussy
            ? CircularProgressIndicator()
            : measures.isEmpty
                ? Text('No Transect measures yet')
                : ListView.builder(
                    itemCount: null == measures ? 0 : measures.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(measures[index].id.toString()),
                        subtitle: Text(measures[index].id.toString()),
                        leading: CircleAvatar(
                            child: Text(measures[index].id.toString())),
                      );
                    }),
      ],
    );
  }
}
