import 'package:collecta/screens/team_profile/widgets/body.dart';
import 'package:flutter/material.dart';
import 'package:collecta/size_config.dart';

class TeamProfileScreen extends StatelessWidget {
  static String routeName = '/team-profile';

  const TeamProfileScreen({Key? key, conectivity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Team Profile Screen'),
          automaticallyImplyLeading: false,
        ),
        body: Body());
  }
}
