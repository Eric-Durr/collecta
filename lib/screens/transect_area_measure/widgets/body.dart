import 'package:collecta/controller/area.dart';
import 'package:collecta/helpers/transect_form_args.screen.dart';
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
    ).then((value) => closestArea = value != null ? value : null);
    if (widget.isOnline) {
      // onlineDB if user is connected
    } else {
      await initLocalDB();
    }

    setState(() {
      isBussy = false;
    });
  }

  Future initLocalDB() async {
    // measures = await TransectPointDatabase.instance.readAll();
    measures = [];
    if (measures.isEmpty) {
      measures.insert(
          0,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: '00:01:00',
              hits: 3,
              areaId: 0,
              teamId: 0));
      measures.insert(
          1,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: '00:01:00',
              hits: 3,
              areaId: 0,
              teamId: 0));

      measures.insert(
          2,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: '00:01:00',
              hits: 3,
              areaId: 0,
              teamId: 0));
      measures.insert(
          3,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: '00:01:00',
              hits: 3,
              areaId: 0,
              teamId: 0));

      measures.insert(
          4,
          TransectPoint(
              species: 'Rumex Lunaria',
              soil: false,
              mulch: false,
              rock: false,
              stone: false,
              annotations: '',
              created: DateTime.now(),
              mark: '00:01:00',
              hits: 3,
              areaId: 0,
              teamId: 0));
    }
    measures[1] = measures[0].copy(species: '', mulch: true, hits: 1);
    measures[2] = measures[0].copy(species: '', soil: true, hits: 1);
    measures[3] = measures[0].copy(species: '', stone: true, hits: 1);
    measures[4] = measures[0].copy(species: '', rock: true, hits: 1);
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
                            widget
                                .updatePositionCallback(widget.currentPosition);

                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();

                            await updateClosestArea(sharedPreferences);

                            // update data

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
            SizedBox(height: getProportionateScreenHeight(24)),
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
                    onPressed: () {
                      Navigator.pushNamed(
                          context, TransectFormInitialScreen.routeName,
                          arguments: TransectArguments(
                            measures: measures,
                            areaId: closestArea!.id,
                          ));
                    },
                  ),
                  SizedBox(height: getProportionateScreenHeight(5)),
                  const Text('Add area measure'),
                ],
              ),
            SizedBox(height: getProportionateScreenHeight(40)),
            isBussy
                ? const CircularProgressIndicator()
                : MeasureList(
                    measures: measures,
                  ),
          ]),
        ),
      ),
    );
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
