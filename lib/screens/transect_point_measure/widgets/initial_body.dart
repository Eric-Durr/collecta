import 'dart:async';
import 'dart:math';

import 'package:collecta/constants.dart';
import 'package:collecta/controller/species.dart';
import 'package:collecta/db/transect_point_database.dart';
import 'package:collecta/main.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:collecta/size_config.dart';
import 'package:collecta/widgets/custom_suffix_icon.dart';
import 'package:collecta/widgets/deffault_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'progress_header.dart';

enum TransectPointTypes { species, mulch, soil, stone, rock }

class InitialBody extends StatefulWidget {
  const InitialBody({
    Key? key,
    required this.areaId,
    required this.measures,
  }) : super(key: key);

  final List<TransectPoint> measures;
  final int areaId;

  @override
  State<InitialBody> createState() => _InitialBodyState();
}

class _InitialBodyState extends State<InitialBody> {
  String formStage = 'init';
  String userName = '';
  TransectPointTypes measureType = TransectPointTypes.species;

  bool enableHitsField = true;
  late TransectPoint currentPoint;

  // Controllers
  final TextEditingController _hitsController = TextEditingController()
    ..text = '0';
  final TextEditingController _speciesNameController = TextEditingController()
    ..text = '';

  // Timer variables
  Timer? timer;
  Duration duration = const Duration();

  @override
  void initState() {
    // TODO: implement initState
    initPerefernces();
    super.initState();

    // startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void initPerefernces() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userName = sharedPreferences.getString('username') ?? '';
    });
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
            Text(formStage),
            Text(
              'AREA ${widget.areaId} - POINT ${widget.measures.length + 1}',
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(18),
                  fontWeight: FontWeight.bold),
            ),
            pageHeader(),
            SizedBox(height: getProportionateScreenHeight(20)),
            ProgressHeader(stepTitle: headerTitle()),
            if (formStage != 'init' && formStage != 'details')
              selectionRadioButtons()
            else
              SizedBox(height: getProportionateScreenHeight(200)),
            if (formStage == 'species' || formStage == 'nextSpecies')
              selectionMenu()
            else
              SizedBox(height: getProportionateScreenHeight(100)),
            if (formStage == 'details')
              Center(child: Text('form details goes here')),
            SizedBox(height: getProportionateScreenHeight(100)),
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
              totalSteps: 6,
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

  // Widget Functions

  Column selectionMenu() {
    return Column(
      children: [
        SizedBox(height: getProportionateScreenHeight(42)),
        TypeAheadField<String?>(
          minCharsForSuggestions: 2,
          suggestionsCallback: getTransectSpeciesNamesLoaded,
          hideOnLoading: true,
          itemBuilder: (context, String? speciesSugestion) {
            final species = speciesSugestion;
            return ListTile(title: Text(species ?? ''));
          },
          keepSuggestionsOnLoading: false,
          textFieldConfiguration:
              TextFieldConfiguration(controller: _speciesNameController),
          noItemsFoundBuilder: (context) => Center(
            child: Container(
                padding: EdgeInsets.all(10),
                width: getProportionateScreenWidth(200),
                height: getProportionateScreenHeight(2000),
                child: Column(
                  children: [
                    Text(
                        '${_speciesNameController.text} not found in database'),
                    DefaultButton(
                      text: 'add to list',
                      onPressedFunction: () {},
                    ),
                  ],
                )),
          ),
          onSuggestionSelected: (String? suggestion) {
            _speciesNameController.text = suggestion ?? '';
            if (_speciesNameController.text != '') {
              formStage = 'nextSpecies';
            }
          },
        ),
      ],
    );
  }

  Column selectionRadioButtons() {
    return Column(
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
                        enableHitsField = true;
                        _hitsController.text = '0';
                        _speciesNameController.text = '';
                        if (_hitsController.text == '0') {
                          formStage = 'hits';
                        }
                      });
                    },
                  ),
                  const Expanded(
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
                        _hitsController.text = '1';
                        _speciesNameController.text = 'Suelo';
                        enableHitsField = false;
                        formStage = 'details';
                      });
                    },
                  ),
                  const Expanded(child: Text('Soil'))
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
                        setState(() {
                          measureType = value!;
                          _hitsController.text = '1';
                          _speciesNameController.text = 'Roca';
                          enableHitsField = false;
                          formStage = 'details';
                        });
                      });
                    },
                  ),
                  const Expanded(child: Text('Rock'))
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(child: Text('')),
            Expanded(
              flex: 1,
              child: typeSelectionRadioButtons(),
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
                        setState(() {
                          measureType = value!;
                          _hitsController.text = '1';
                          _speciesNameController.text = 'Piedra';
                          enableHitsField = false;
                          formStage = 'details';
                        });
                      });
                    },
                  ),
                  const Expanded(child: Text('Stone'))
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row typeSelectionRadioButtons() {
    return Row(
      children: [
        Radio(
          value: TransectPointTypes.mulch,
          groupValue: measureType,
          onChanged: (TransectPointTypes? value) {
            setState(() {
              setState(() {
                measureType = value!;
                _hitsController.text = '1';
                _speciesNameController.text = 'Mantillo';
                enableHitsField = false;
                formStage = 'details';
              });
            });
          },
        ),
        const Expanded(child: Text('Mulch'))
      ],
    );
  }

  TextFormField buildHitsField() {
    return TextFormField(
        keyboardType: TextInputType.text,
        enabled: enableHitsField,
        controller: _hitsController,
        onChanged: (value) {
          _hitsController.text != '' ? int.parse(_hitsController.text) : 0;

          if (value == '0' || value == '') {
            setState(() {
              formStage = 'hits';
            });
          } else if (measureType == TransectPointTypes.species) {
            setState(() {
              formStage = 'species';
            });
          } else {
            setState(() {
              formStage = 'details';
            });
          }
        },
        decoration: const InputDecoration(
          labelText: 'Hits',
          helperText: 'Enter number of hits',
        ));
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
                  } else if (formStage == 'species') {
                    _speciesNameController.text = '';
                    formStage = 'hits';
                  } else if (formStage == 'details') {
                    formStage = measureType == TransectPointTypes.species
                        ? 'species'
                        : 'init';
                    if (measureType != TransectPointTypes.species) {
                      measureType = TransectPointTypes.species;
                      enableHitsField = true;
                    }
                  } else if (formStage == 'next' || formStage == 'submit') {
                    formStage = 'details';
                  } else if (formStage == 'nextSpecies') {
                    formStage = 'species';
                  } else {
                    formStage = 'type';
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
              buttonColor: formStage == 'details' ||
                      formStage == 'submit' ||
                      formStage == 'next' ||
                      formStage == 'nextSpecies'
                  ? successContainer
                  : lightColorScheme.outline,
              textColor: Colors.white,
              onPressedFunction: () {
                setState(() {
                  if (formStage == 'details') {
                    formStage =
                        widget.measures.length == 100 ? 'submit' : 'next';
                  }
                  if (formStage == 'submit') {
                    // Submit all transect measures
                  }
                  if (formStage == 'next') {
                    // Add point to measures and reset form
                  }

                  if (formStage == 'nextSpecies') {
                    formStage = 'details';
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
            userName.toString().substring(0, 2).toUpperCase(),
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
          '${userName.split('_').join(' ').toUpperCase()}',
          style: TextStyle(
              fontSize: getProportionateScreenWidth(14),
              fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        buildTime(),
      ],
    );
  }

  // Layout state setters

  //                                                             point_id == 100 ?
  // STATES FOR SPECIES: init > type > hits > species > details > next || submit
  //                      (1)    (2)    (3)     (4)      (5)       (6)     (7)
  // STATES FOR OTHER: init > type > details > submit

  int indicateStep() {
    if (formStage == 'init') {
      return 1;
    }
    if (formStage == 'type') {
      return 2;
    }
    if (formStage == 'hits') {
      return 3;
    }
    if (formStage == 'species' || formStage == 'nextSpecies') {
      return 4;
    }
    if (formStage == 'details') {
      return 5;
    }
    if (formStage == 'next' || formStage == 'submit') {
      return 6;
    }
    return 0;
  }

  String indicateStepHint() {
    if (formStage == 'init') {
      return 'Area measures overview';
    }
    if (formStage == 'type') {
      return 'Select point type';
    }
    if (formStage == 'hits') {
      return 'Type the hits value on the text field';
    }
    if (formStage == 'species') {
      return 'Add the species in the combobox';
    }
    if (formStage == 'nextSpecies') {
      return 'Press next to see details';
    }
    if (formStage == 'details') {
      return 'Finish measure by adding optional annotations';
    }
    if (formStage == 'next') {
      return 'Add a new point to the transect';
    }
    if (formStage == 'submit') {
      return 'Submit area transect measures';
    }
    return '';
  }

  String headerTitle() {
    if (formStage == 'init') {
      return 'MEASURES OVERVIEW';
    }
    if (formStage == 'hits' || formStage == 'type') {
      return 'MEASURE DATA SETTING';
    }
    if (formStage == 'species') {
      return 'SELECT POINT SPECIES ';
    }

    if (formStage == 'nextSpecies') {
      return 'SPECIES SELECTED';
    }
    if (formStage == 'details') {
      return 'POINT ${widget.measures.length + 1} PREVIEW';
    }

    if (formStage == 'next') {
      return 'POINT ${widget.measures.length + 1} COMPLETE';
    }

    if (formStage == 'submit') {
      return 'SUBMIT TRANSECT';
    }
    return '';
  }

  String controllerButtonText() {
    if (formStage == 'details' && widget.measures.length != 100) {
      return 'ADD POINT';
    } else if (formStage == 'details' &&
        measureType != TransectPointTypes.species &&
        widget.measures.length == 100) {
      return 'SUBMIT';
    } else {
      return 'NEXT';
    }
  }

  // Timer controller
  void stopTimer() {
    setState(() {
      timer?.cancel();
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void resetTimer() {
    setState(() => duration = const Duration());
  }

  addTime() {
    final addSecond = 1;
    setState(() {
      final seconds = duration.inSeconds + addSecond;
      duration = Duration(seconds: seconds);
    });
  }

  // Timer
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
}
