import 'dart:io';

import 'package:collecta/controller/area.dart';
import 'package:collecta/controller/transect.dart';
import 'package:collecta/screens/transect_point_measure/widgets/transect_form_args.screen.dart';
import 'package:collecta/models/measure_area.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:collecta/widgets/custom_suffix_icon.dart';
import 'package:collecta/widgets/deffault_button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';
import '../../../db/transect_point_database.dart';
import '../../../size_config.dart';
import '../../../widgets/form_error.dart';
import '../../transect_point_measure/initial_form_screen.dart';
import 'measure_list.dart';

class Body extends StatefulWidget {
  Body({
    Key? key,
    required this.updatePositionCallback,
    required this.updateAreasCallback,
    required this.currentPosition,
    required this.zoneAreas,
    this.isOnline = false,
  }) : super(key: key);

  late Position currentPosition;
  late List<MeasureArea> zoneAreas;
  final bool isOnline;

  // Parent comunication callbacks
  Function(Position) updatePositionCallback;
  Function(List<MeasureArea>) updateAreasCallback;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  // status handlers
  bool isBussy = false;
  bool isReloadBussy = false;
  bool onlyThisArea = true;
  bool locationFail = false;
  final List<String> errors = [];

  // Geolocation
  final Geolocator geolocator = Geolocator();
  late MeasureArea? closestArea = null;

  // Tool variables
  List<TransectPoint> measures = [];

  // Area dialog
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _areaIdValue = TextEditingController();
  final TextEditingController _areaAnnotationsValue = TextEditingController();

  @override
  void initState() {
    super.initState();

    infoSetup();

    // Mocked connection check
  }

  void infoSetup() async {
    setState(() {
      isBussy = true;
    });
    await getClosestAreaIn100m(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
      widget.zoneAreas,
    ).then((value) => closestArea = (value != null) ? value : null);

    await initLocalDB();

    if (widget.isOnline) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await getTeamTransectMeasures(sharedPreferences.getString('areaId') ?? '',
          sharedPreferences.getString('teamId') ?? '');
    }

    setState(() {
      isBussy = false;
    });
  }

  Future initLocalDB() async {
    if (closestArea == null) {
      measures = [];
    } else {
      if (onlyThisArea) {
        measures = await TransectPointDatabase.instance
            .readByArea(closestArea?.id ?? -1);
      } else {
        measures = await TransectPointDatabase.instance.readAll();
      }
    }
    print(measures.last.created.toIso8601String().substring(0, 10));
    print(DateTime.now().toIso8601String().substring(0, 10));
    if (measures.isNotEmpty) {
      if (measures.last.created.toIso8601String().substring(0, 10) !=
          DateTime.now().toIso8601String().substring(0, 10)) {
        TransectPointDatabase.instance.purge();
        measures = [];
      }
    }
  }

  _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.denied) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
              forceAndroidLocationManager: true)
          .then((Position position) {
        setState(() {
          widget.currentPosition = position;
        });
      }).catchError((e) {
        setState(() {
          locationFail = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          dismissDirection: DismissDirection.down,
          duration: const Duration(seconds: 20),
          backgroundColor: lightColorScheme.errorContainer,
          content: Text(
            e.toString(),
            style: TextStyle(color: lightColorScheme.onErrorContainer),
          ),
        ));
      });
    } else {
      setState(() {
        locationFail = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              if (isBussy)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: lightColorScheme.primaryContainer,
                  ),
                ),
              if (!isBussy)
                closestArea == null
                    ? SizedBox(
                        width: getProportionateScreenWidth(200),
                        child: DefaultButton(
                          text: '+ Add new area',
                          onPressedFunction: () async {
                            await showInformationDialog(context);
                            await initLocalDB();
                          },
                          buttonColor: lightColorScheme.surfaceVariant,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Area ${closestArea!.id}',
                            style: TextStyle(
                                fontSize: getProportionateScreenWidth(18),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              if (isReloadBussy)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              SizedBox(height: getProportionateScreenHeight(14)),
              Card(
                elevation: 0,
                color: lightColorScheme.primaryContainer,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (isBussy) const CircularProgressIndicator(),
                        if (!isBussy && !locationFail)
                          Text(
                            'Latitude: ${widget.currentPosition.latitude.toStringAsPrecision(8)}, Longitude: ${widget.currentPosition.longitude.toStringAsPrecision(8)}',
                            style: TextStyle(
                                color: lightColorScheme.onPrimaryContainer,
                                fontSize: getProportionateScreenWidth(12),
                                fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            'Retry location load',
                            style: TextStyle(
                                color: lightColorScheme.onPrimaryContainer,
                                fontSize: getProportionateScreenWidth(12),
                                fontWeight: FontWeight.bold),
                          ),
                        FormError(errors: errors),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                          child: OutlinedButton(
                            onPressed: () async {
                              setState(() {
                                isReloadBussy = true;
                              });
                              await _determinePosition();
                              widget.updatePositionCallback(
                                  widget.currentPosition);

                              SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();

                              await updateClosestArea(sharedPreferences);

                              // update data
                              await initLocalDB();
                              setState(() {
                                isReloadBussy = false;
                              });
                            },
                            child: const Icon(
                              Icons.replay_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
              if (closestArea != null)
                Column(
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.black,
                      splashColor: Colors.white.withOpacity(0.5),
                      tooltip: 'Add area measure in current location',
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                      onPressed: () async {
                        List<TransectPoint> newMeasures =
                            await Navigator.pushNamed(
                                context, TransectFormInitialScreen.routeName,
                                arguments: TransectArguments(
                                  measures: measures,
                                  areaId: closestArea!.id,
                                )) as List<TransectPoint>;
                        for (var measure in newMeasures) {
                          if (await TransectPointDatabase.instance
                                  .contains(measure.id ?? -1) ==
                              false) {
                            await TransectPointDatabase.instance
                                .create(measure);
                          }
                        }

                        setState(() {
                          updateMeasure();
                        });
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(5)),
                    const Text('Add area measure'),
                  ],
                ),
              SizedBox(height: getProportionateScreenHeight(10)),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      onlyThisArea
                          ? 'TODAY MEASURES LIST'
                          : 'TEAM MEASURES HISTORY',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: getProportionateScreenWidth(14),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                            getProportionateScreenWidth(10),
                            0,
                            getProportionateScreenWidth(10),
                            0),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 3, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    if (onlyThisArea)
                      Text(
                        '${(measures.length)}/100',
                        style: TextStyle(
                            color: listNumbersColor(measures.length),
                            fontSize: getProportionateScreenWidth(15),
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              CheckboxListTile(
                title: const Text("Show only this area"),
                value: onlyThisArea,
                onChanged: (newValue) async {
                  if (!isBussy) {
                    setState(() {
                      isBussy = true;
                      onlyThisArea = newValue ?? false;
                    });

                    await initLocalDB();
                    setState(() {
                      isBussy = false;
                    });
                  }
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ),
              isBussy
                  ? const CircularProgressIndicator()
                  : MeasureList(
                      measures: measures,
                    ),
              SizedBox(height: getProportionateScreenHeight(50)),
            ]),
          ),
        ),
      ),
    );
  }

  Color listNumbersColor(int length) {
    if (length <= 25) {
      return lightColorScheme.error;
    } else if (length > 25 && length < 100) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  updateMeasure() async {
    measures = await TransectPointDatabase.instance.readAll();
  }

  Future<void> updateClosestArea(SharedPreferences sharedPreferences) async {
    await getZoneAreas(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
      sharedPreferences.getString('projectId'),
    ).then((value) {
      widget.zoneAreas = value;
      widget.updateAreasCallback(value);
    });

    await getClosestAreaIn100m(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
      widget.zoneAreas,
    ).then((value) => closestArea = value != null ? value : null);
  }

  // New area dialog toggle
  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: const Text('New area data'),
              content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      areaIdTextField(),
                      SizedBox(
                        height: getProportionateScreenHeight(20),
                      ),
                      areaAnnotationsTextField(),
                    ],
                  )),
              actions: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: IconButton(
                        iconSize: getProportionateScreenWidth(32),
                        color: lightColorScheme.error,
                        onPressed: () {
                          _areaIdValue.clear();
                          _areaAnnotationsValue.clear();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.cancel),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: IconButton(
                        iconSize: getProportionateScreenWidth(32),
                        color: successContainer,
                        onPressed: () async {
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          if (_formKey.currentState!.validate()) {
                            await addArea(
                                    widget.currentPosition.latitude,
                                    widget.currentPosition.longitude,
                                    int.parse(_areaIdValue.text),
                                    sharedPreferences.getString('projectId'),
                                    _areaAnnotationsValue.text,
                                    widget.zoneAreas)
                                .then((result) async {
                              // Update areas and

                              SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              print(result.toString());
                              if (result == 400) {
                                // On error drop dialog

                                await updateClosestArea(sharedPreferences);

                                Navigator.of(context).pop();

                                // Show error
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  dismissDirection: DismissDirection.down,
                                  duration: const Duration(seconds: 20),
                                  backgroundColor:
                                      lightColorScheme.errorContainer,
                                  content: Text(
                                    'ERROR: Area already exists. Try with a different ID',
                                    style: TextStyle(
                                        color:
                                            lightColorScheme.onErrorContainer),
                                  ),
                                ));
                              } else {
                                await updateClosestArea(sharedPreferences);
                                Navigator.of(context).pop();
                                // Show error
                                // Show error
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  dismissDirection: DismissDirection.down,
                                  duration: Duration(seconds: 20),
                                  backgroundColor: successContainer,
                                  content: Text(
                                    'Area added successfully',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ));
                              }
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.check_circle,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            );
          });
        });
  }

  TextFormField areaIdTextField() {
    return TextFormField(
        controller: _areaIdValue,
        validator: (value) {
          return value!.isNotEmpty ? null : "Enter any text";
        },
        decoration: const InputDecoration(
            labelText: 'Area ID', helperText: 'Enter an area ID'));
  }

  TextFormField areaAnnotationsTextField() {
    return TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        controller: _areaAnnotationsValue,
        decoration: const InputDecoration(
            labelText: 'Annotations', helperText: '(optional)'));
  }
}
