import 'dart:async';
import 'dart:math';

import 'package:collecta/constants.dart';
import 'package:collecta/db/transect_point_database.dart';
import 'package:collecta/main.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:collecta/size_config.dart';
import 'package:collecta/widgets/custom_suffix_icon.dart';
import 'package:collecta/widgets/deffault_button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'progress_header.dart';

enum TransectPointTypes { species, mulch, soil, stone, rock }

class InitialBody extends StatefulWidget {
  final List<TransectPoint> measures;
  const InitialBody({
    Key? key,
    required this.measures,
  }) : super(key: key);

  @override
  State<InitialBody> createState() => _InitialBodyState();
}

class _InitialBodyState extends State<InitialBody> {
  Duration duration = Duration();
  String formStage = 'init';
  TransectPointTypes measureType = TransectPointTypes.species;
  int hits = 0;
  final TextEditingController hitsController = new TextEditingController();
  bool enableField = true;
  Timer? timer;
  late TransectPoint currentPoint;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    hitsController.text = '0';
    // startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    hitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: Column(children: [
            Text(
              'AREA ${widget.measures[0].areaId}',
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(18),
                  fontWeight: FontWeight.bold),
            ),
            pageHeader(),
            SizedBox(height: getProportionateScreenHeight(20)),
            ProgressHeader(
              stepTitle: headerTitle(),
            ),
            if (formStage == 'hits' ||
                formStage == 'type' ||
                formStage == 'hitsAndType' ||
                formStage == 'speciesSelect')
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: getProportionateScreenHeight(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [Expanded(child: buildHitsField())],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Radio(
                              value: TransectPointTypes.species,
                              groupValue: measureType,
                              onChanged: (TransectPointTypes? value) {
                                setState(() {
                                  measureType = value!;
                                  enableField = true;
                                });
                              },
                            ),
                            Expanded(
                              child: Text('Species'),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Radio(
                              value: TransectPointTypes.soil,
                              groupValue: measureType,
                              onChanged: (TransectPointTypes? value) {
                                setState(() {
                                  measureType = value!;
                                  hitsController.text = '1';
                                  enableField = false;
                                  formStage = 'hitsAndType';
                                });
                              },
                            ),
                            Expanded(child: Text('Soil'))
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Radio(
                              value: TransectPointTypes.rock,
                              groupValue: measureType,
                              onChanged: (TransectPointTypes? value) {
                                setState(() {
                                  measureType = value!;
                                });
                              },
                            ),
                            Expanded(child: Text('Rock'))
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(child: Text('')),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Radio(
                              value: TransectPointTypes.mulch,
                              groupValue: measureType,
                              onChanged: (TransectPointTypes? value) {
                                setState(() {
                                  measureType = value!;
                                });
                              },
                            ),
                            Expanded(child: Text('Mulch'))
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Radio(
                              value: TransectPointTypes.stone,
                              groupValue: measureType,
                              onChanged: (TransectPointTypes? value) {
                                setState(() {
                                  measureType = value!;
                                });
                              },
                            ),
                            Expanded(child: Text('Stone'))
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              SizedBox(height: getProportionateScreenHeight(200)),
            if (formStage == 'speciesSelect')
              buildHitsField()
            else
              SizedBox(height: getProportionateScreenHeight(200)),
            if (formStage == 'init')
              DefaultButton(
                text: 'START',
                buttonColor: successContainer,
                textColor: Colors.white,
                onPressedFunction: () {
                  startTimer();
                  setState(() {
                    formStage = 'hits';
                  });
                },
              )
            else
              controlButtons(),
            SizedBox(height: getProportionateScreenHeight(20)),
            StepProgressIndicator(
              totalSteps: 5,
              currentStep: indicateStep(),
              size: 20,
              padding: 0,
              selectedColor: const Color.fromARGB(255, 147, 85, 222),
              unselectedColor: Colors.grey.withOpacity(0.3),
              roundedEdges: const Radius.circular(14),
            ),
            Text(indicateStepHint())
          ]),
        ),
      ),
    );
  }

  TextFormField buildHitsField() {
    return TextFormField(
        keyboardType: TextInputType.text,
        enabled: enableField,
        initialValue: hits.toString(),
        onChanged: (value) {
          hits = int.parse(value);
        },
        decoration: const InputDecoration(
          labelText: 'Hits',
          helperText: 'Enter number of hits',
        ));
  }

  void _printLatestValue() {
    print('${hitsController.text}');
  }

  Row controlButtons() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(15)),
            child: DefaultButton(
              text: 'BACK',
              buttonColor: lightColorScheme.error,
              textColor: Colors.white,
              onPressedFunction: () {
                setState(() {
                  if (formStage == 'hits' || formStage == 'type') {
                    formStage = 'init';
                    stopTimer();
                  }
                });
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(5)),
            child: DefaultButton(
              text: controllerButtonText(),
              buttonColor: formStage == 'hitsAndType'
                  ? successContainer
                  : lightColorScheme.outline,
              textColor: Colors.white,
              onPressedFunction: () {
                setState(() {
                  if (formStage == 'hitsAndType') {
                    if (measureType != 'species') {
                      formStage = 'speciesSelect';
                    } else {
                      formStage = widget.measures.length == 100
                          ? 'lastComplete'
                          : 'complete';
                    }
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Row pageHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: getProportionateScreenWidth(30),
          backgroundColor: lightColorScheme.secondaryContainer,
          child: Text(
            databaseConnection.username
                .toString()
                .substring(0, 2)
                .toUpperCase(),
            style: TextStyle(
                fontSize: getProportionateScreenWidth(22),
                fontWeight: FontWeight.w600,
                color: lightColorScheme.onSecondaryContainer),
          ),
        ),
        SizedBox(
          width: getProportionateScreenWidth(10),
        ),
        Text(
          '${databaseConnection.username!.split('_').join(' ').toUpperCase()}',
          style: TextStyle(
              fontSize: getProportionateScreenWidth(14),
              fontWeight: FontWeight.bold),
        ),
        buildTime(),
      ],
    );
  }

  Widget buildTime() {
    String twoDigits(int num) => num.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.remainder(60));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Card(
        color: lightColorScheme.secondaryContainer,
        margin:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: Text(
            '$hours:$minutes:$seconds',
            style: TextStyle(
                fontSize: getProportionateScreenWidth(20),
                color: lightColorScheme.onSecondaryContainer),
          ),
        ));
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void resetTimer() {
    setState(() => duration = Duration());
  }

  addTime() {
    final addSecond = 1;
    setState(() {
      final seconds = duration.inSeconds + addSecond;
      duration = Duration(seconds: seconds);
    });
  }

  int indicateStep() {
    if (formStage == 'init') {
      return 1;
    }
    if (formStage == 'hits' || formStage == 'type') {
      return 2;
    }
    if (formStage == 'hitsAndType') {
      return 3;
    }
    if (formStage == 'speciesSelect') {
      return 4;
    }
    if (formStage == 'complete' || formStage == 'lastComplete') {
      return 5;
    }
    return 0;
  }

  String indicateStepHint() {
    if (formStage == 'init') {
      return 'Area measures overview';
    }
    if (formStage == 'hits' || formStage == 'type') {
      return 'Add hits and select point type';
    }
    if (formStage == 'hitsAndType') {
      return 'Hit next to select Species';
    }
    if (formStage == 'speciesSelect') {
      return 'Select, type or ask for species';
    }
    if (formStage == 'complete') {
      return 'Submit or pass to next point';
    }

    if (formStage == 'lastComplete') {
      return 'Submit area measure';
    }
    return '';
  }

  String controllerButtonText() {
    if (formStage == 'hitsAndType' &&
        measureType != TransectPointTypes.species &&
        widget.measures.length != 100) {
      return 'ADD POINT';
    } else if (formStage == 'hitsAndType' &&
        measureType != TransectPointTypes.species &&
        widget.measures.length == 100) {
      return 'SUBMIT AREA';
    } else {
      return 'NEXT';
    }
  }

  void stopTimer() {
    setState(() {
      timer?.cancel();
    });
  }

  String headerTitle() {
    if (formStage == 'init') {
      return 'MEASURES OVERVIEW';
    }
    if (formStage == 'hits' || formStage == 'type') {
      return 'MEASURE DATA POINT ${widget.measures.length + 1}';
    }
    if (formStage == 'hitsAndType') {
      return 'MEASURE DATA POINT ${widget.measures.length + 1}';
    }
    if (formStage == 'speciesSelect') {
      return 'SELECT SPECIES POINT ${widget.measures.length + 1}';
    }
    if (formStage == 'complete') {
      return 'POINT ${widget.measures.length + 1} COMPLETE';
    }

    if (formStage == 'lastComplete') {
      return 'SUBMIT AREA';
    }
    return '';
  }
}
