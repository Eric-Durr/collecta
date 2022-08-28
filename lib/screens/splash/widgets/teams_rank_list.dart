import 'package:collecta/constants.dart';
import 'package:collecta/db/transect_point_database.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:flutter/material.dart';

import 'package:collecta/size_config.dart';
import 'package:flutter_map/plugin_api.dart';

class TeamsRankList extends StatefulWidget {
  List<String> teams;
  TeamsRankList({
    Key? key,
    required this.teams,
  }) : super(key: key);

  @override
  State<TeamsRankList> createState() => _TeamsRankListState();
}

class _TeamsRankListState extends State<TeamsRankList> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
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
          widget.teams.isEmpty
              ? Text('No Transect measures yet')
              : Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: widget.teams.length,
                    itemBuilder: (context, index) {
                      // Point measure card
                      return Card(
                        elevation: 1,
                        margin: EdgeInsets.fromLTRB(
                            10,
                            getProportionateScreenHeight(20),
                            10,
                            getProportionateScreenWidth(5)),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                color: Colors.grey,
                                width: getProportionateScreenWidth(50),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  String twoDigits(int num) => num.toString().padLeft(2, '0');
}
