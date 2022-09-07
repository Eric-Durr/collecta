import 'dart:async';

import 'package:collecta/constants.dart';
import 'package:collecta/controller/species.dart';
import 'package:collecta/db/transect_point_database.dart';
import 'package:collecta/models/transect_point.dart';
import 'package:collecta/size_config.dart';
import 'package:collecta/widgets/deffault_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'progress_header.dart';

enum TransectPointTypes { species, mulch, soil, stone, rock }

class InitialBody extends StatefulWidget {
  InitialBody(
      {Key? key,
      required this.areaId,
      required this.measures,
      required this.updateMeasuresCallback})
      : super(key: key);

  final List<TransectPoint> measures;
  final int areaId;
  Function(List<TransectPoint>) updateMeasuresCallback;

  @override
  State<InitialBody> createState() => _InitialBodyState();
}

class _InitialBodyState extends State<InitialBody> {
  String formStage = 'init';
  String userName = '';
  TransectPointTypes measureType = TransectPointTypes.species;

  List<Map<String, String>> speciesList = [];

  int dummy = 0;

  bool enableHitsField = true;
  bool enableSpeciesField = true;
  late TransectPoint currentPoint;

  // Controllers
  final TextEditingController _hitsController = TextEditingController()
    ..text = '0';
  final TextEditingController _speciesNameController = TextEditingController()
    ..text = '';
  final TextEditingController _listHitsController = TextEditingController()
    ..text = '0';
  final TextEditingController _listSpeciesNameController =
      TextEditingController()..text = '';
  final TextEditingController _transectAnnotationsController =
      TextEditingController()..text = '';

  // Timer variables
  Timer? timer;
  Duration duration = const Duration();
  String markString = '';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20)),
            child: SingleChildScrollView(
              child: Column(children: [
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
                else if (formStage == 'details')
                  SizedBox(height: getProportionateScreenHeight(20))
                else if (formStage == 'init')
                  measuresOverview()
                else
                  SizedBox(height: getProportionateScreenHeight(200)),
                if ((formStage == 'species' || formStage == 'nextSpecies') &&
                    (measureType != TransectPointTypes.species))
                  selectionMenu()
                else if ((measureType == TransectPointTypes.species) &&
                    formStage != 'init' &&
                    formStage != 'details')
                  speciesSelectionMenu()
                else if (formStage != 'details')
                  SizedBox(height: getProportionateScreenHeight(100)),
                if (formStage == 'details') detailsBoard(),
                if (formStage == 'details')
                  SizedBox(height: getProportionateScreenHeight(55))
                else if (formStage == 'init')
                  SizedBox(height: getProportionateScreenHeight(0))
                else
                  SizedBox(height: getProportionateScreenHeight(100)),
                if (formStage == 'init')
                  DefaultButton(
                    text: 'START',
                    buttonColor: widget.measures.length < 100
                        ? successContainer
                        : lightColorScheme.outline,
                    textColor: Colors.white,
                    onPressedFunction: () {
                      if (widget.measures.length < 100) {
                        startTimer();
                        setState(() {
                          formStage = 'hits';
                        });
                      }
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
        ),
      ),
    );
  }

  ///////////////// Widget Functions

  Container measuresOverview() {
    return Container(
      padding: EdgeInsets.all(0),
      height: SizeConfig.screenHeight * 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 100,
              itemBuilder: (context, index) {
                // Point measure card
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.fromLTRB(
                      0,
                      getProportionateScreenHeight(0),
                      0,
                      getProportionateScreenWidth(0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio(
                        overlayColor: MaterialStateProperty.all<Color?>(
                            index < widget.measures.length
                                ? Colors.grey
                                : index == widget.measures.length
                                    ? Colors.blue
                                    : Colors.black),
                        fillColor: MaterialStateProperty.all<Color?>(
                            index < widget.measures.length
                                ? Colors.grey
                                : index == widget.measures.length
                                    ? Colors.blue
                                    : Colors.black),
                        value: dummy,
                        groupValue: measureType,
                        onChanged: (value) {},
                      ),
                      Text(
                        'Point ${index + 1}/100',
                        style: TextStyle(
                            fontWeight: widget.measures.length <= index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: widget.measures.length <= index
                                ? Colors.black
                                : Colors.grey),
                      ),
                      Spacer(),
                      Text(
                        '${index < widget.measures.length ? widget.measures[index].species!.length > 15 ? widget.measures[index].species!.substring(0, 15) + '...' : widget.measures[index].species : ''}',
                        style: TextStyle(
                            fontWeight: widget.measures.length <= index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: widget.measures.length <= index
                                ? Colors.black
                                : Colors.grey),
                      ),
                      Spacer(),
                      Text(
                        '${index < widget.measures.length ? widget.measures[index].mark : ''}',
                        style: TextStyle(
                            fontWeight: widget.measures.length <= index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: widget.measures.length <= index
                                ? Colors.black
                                : Colors.grey),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          Center(
            child: Text(
              'Measures for date: ${DateTime.now().toString().substring(0, 10)}',
              style: TextStyle(fontSize: getProportionateScreenWidth(18)),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          Center(
            child: Text(
              '${widget.measures.length}% point completed',
              style: TextStyle(
                  color: widget.measures.length < 25
                      ? Colors.red
                      : widget.measures.length < 75
                          ? Colors.orange
                          : successContainer,
                  fontSize: getProportionateScreenWidth(18)),
            ),
          )
        ],
      ),
    );
  }

  Column detailsBoard() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 11, 11),
                child: Image.asset(
                  'assets/images/add_image.png',
                  color: Colors.grey.shade200,
                  width: getProportionateScreenWidth(70),
                ),
              ),
            ),
            Spacer(),
            Container(
              height: getProportionateScreenHeight(130),
              width: getProportionateScreenWidth(220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Area ${widget.areaId}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenWidth(17)),
                  ),
                  Text(
                    'point ${widget.measures.length + 1}/100',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenWidth(13)),
                  ),
                  Text(
                    '${_speciesNameController.text}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenWidth(
                            _speciesNameController.text.length >= 30
                                ? 11
                                : _speciesNameController.text.length >= 15 &&
                                        _speciesNameController.text.length < 30
                                    ? 13
                                    : 14)),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(5),
                  ),
                  Text(
                    '${_hitsController.text} HITS',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: getProportionateScreenWidth(13)),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(10),
                  ),
                  Container(
                    width: getProportionateScreenWidth(200),
                    child: Text(
                      '${DateTime.now().toString().substring(0, 19)}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: getProportionateScreenWidth(12)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: getProportionateScreenHeight(40),
        ),
        pointAnnotationsTextField(),
      ],
    );
  }

  TextFormField pointAnnotationsTextField() {
    return TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        controller: _transectAnnotationsController,
        decoration: const InputDecoration(
            labelText: 'Annotations', helperText: '(optional)'));
  }

  Column selectionMenu() {
    return Column(
      children: [
        SizedBox(height: getProportionateScreenHeight(42)),
        TypeAheadField<String?>(
          hideSuggestionsOnKeyboardHide: false,
          minCharsForSuggestions: 2,
          suggestionsCallback: getTransectSpeciesNamesLoaded,
          itemBuilder: (context, String? speciesSugestion) {
            final species = speciesSugestion;
            return ListTile(title: Text(species ?? ''));
          },
          textFieldConfiguration: TextFieldConfiguration(
              controller: _speciesNameController, enabled: enableSpeciesField),
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

  Column speciesSelectionMenu() {
    return Column(
      children: [
        SizedBox(height: getProportionateScreenHeight(18)),
        SizedBox(
          height: SizeConfig.screenHeight * 0.13 * (speciesList.length + 1),
          child: Column(
            children: [
              SizedBox(
                height:
                    SizeConfig.screenHeight * 0.12 * (speciesList.length + 1),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: speciesList.length + 1,
                  itemBuilder: (context, index) {
                    // Point measure card
                    if (index == speciesList.length) {
                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.fromLTRB(
                          0,
                          SizeConfig.screenHeight * 0.02,
                          0,
                          SizeConfig.screenHeight * 0.02,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: SizeConfig.screenWidth * 0.3,
                              child: buildSpeciesHitsField(),
                            ),
                            SizedBox(
                              width: SizeConfig.screenWidth * 0.5,
                              child: TypeAheadField<String?>(
                                hideSuggestionsOnKeyboardHide: false,
                                minCharsForSuggestions: 2,
                                suggestionsCallback:
                                    getTransectSpeciesNamesLoaded,
                                itemBuilder:
                                    (context, String? speciesSugestion) {
                                  final species = speciesSugestion;
                                  return ListTile(title: Text(species ?? ''));
                                },
                                textFieldConfiguration: TextFieldConfiguration(
                                    decoration: const InputDecoration(
                                      labelText: 'Species',
                                    ),
                                    controller: _listSpeciesNameController,
                                    enabled: enableSpeciesField),
                                noItemsFoundBuilder: (context) => Center(
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      width: getProportionateScreenWidth(200),
                                      height:
                                          getProportionateScreenHeight(2000),
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
                                  _listSpeciesNameController.text =
                                      suggestion ?? '';
                                  if (_listSpeciesNameController.text != '') {
                                    formStage = 'nextSpecies';
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.fromLTRB(
                          0,
                          SizeConfig.screenHeight * 0.02,
                          0,
                          SizeConfig.screenHeight * 0.02,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                                width: SizeConfig.screenWidth * 0.3,
                                child: TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        hintText: speciesList[index]
                                            .values
                                            .first
                                            .toString()))),
                            SizedBox(
                                width: SizeConfig.screenWidth * 0.5,
                                child: TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        hintText: speciesList[index]
                                            .keys
                                            .first
                                            .toString()))),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            if (_listHitsController.text == '' ||
                _listHitsController.text == '0' ||
                _listSpeciesNameController.text == '') {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                dismissDirection: DismissDirection.down,
                duration: const Duration(seconds: 5),
                backgroundColor: lightColorScheme.errorContainer,
                content: Text(
                  'Hits and species field must be completed',
                  style: TextStyle(color: lightColorScheme.onErrorContainer),
                ),
              ));
            } else {
              setState(() {
                speciesList.add({
                  _listSpeciesNameController.text: _listHitsController.text
                });
                _listSpeciesNameController.text = '';
                _listHitsController.text = '0';
              });
            }
          },
          icon: Icon(Icons.add_box),
          iconSize: getProportionateScreenWidth(46),
        ),
      ],
    );
  }

  Column selectionRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: getProportionateScreenHeight(20)),
        if (measureType != TransectPointTypes.species)
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
                        enableSpeciesField = true;
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
                        enableSpeciesField = false;
                        formStage = 'nextSpecies';
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
                          enableSpeciesField = false;
                          formStage = 'nextSpecies';
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
                          enableSpeciesField = false;
                          formStage = 'nextSpecies';
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
                enableSpeciesField = false;
                formStage = 'nextSpecies';
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
          if (int.parse(value) > 6 || int.parse(value) < 1) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              dismissDirection: DismissDirection.down,
              duration: const Duration(seconds: 5),
              backgroundColor: lightColorScheme.errorContainer,
              content: Text(
                'Hits must be between 1 and 6',
                style: TextStyle(color: lightColorScheme.onErrorContainer),
              ),
            ));
            setState(() {
              _listHitsController.text = '0';
            });
          }
          if (value == '0' || value == '' || int.parse(value) > 6) {
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

  TextFormField buildSpeciesHitsField() {
    return TextFormField(
        keyboardType: TextInputType.text,
        enabled: enableHitsField,
        controller: _listHitsController,
        onChanged: (value) {
          _listHitsController.text != ''
              ? int.parse(_listHitsController.text)
              : 0;
          if (int.parse(value) > 6 || int.parse(value) < 1) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              dismissDirection: DismissDirection.down,
              duration: const Duration(seconds: 5),
              backgroundColor: lightColorScheme.errorContainer,
              content: Text(
                'Hits must be between 1 and 6',
                style: TextStyle(color: lightColorScheme.onErrorContainer),
              ),
            ));
          }
        },
        decoration: const InputDecoration(
          labelText: 'Hits',
        ));
  }

  Row controlButtons() {
    return Row(
      children: [
        Container(
          width:
              getProportionateScreenWidth(formStage == 'details' ? 100 : 150),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(5)),
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
                    formStage = 'nextSpecies';
                    if (measureType != TransectPointTypes.species) {
                      measureType = TransectPointTypes.species;
                      enableHitsField = true;
                      _speciesNameController.text = '';
                      _hitsController.text = '0';
                      enableSpeciesField = true;
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
              onPressedFunction: () async {
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                setState(() {
                  if (formStage == 'details') {
                    formStage =
                        widget.measures.length == 100 ? 'submit' : 'next';
                  }
                  if (formStage == 'submit') {
                    // Submit all transect measures
                  }
                  if (formStage == 'next') {
                    widget.measures.add(TransectPoint(
                        areaId: widget.areaId,
                        species: _speciesNameController.text,
                        soil: _speciesNameController.text == 'Suelo',
                        mulch: _speciesNameController.text == 'Mantillo',
                        stone: _speciesNameController.text == 'Piedra',
                        rock: _speciesNameController.text == 'Roca',
                        annotations: _transectAnnotationsController.text,
                        created: DateTime.now(),
                        mark: markString,
                        hits: int.parse(_hitsController.text),
                        teamId: int.parse(
                            sharedPreferences.getString('projectId') ?? '0')));
                    _hitsController.text = '0';
                    enableHitsField = true;
                    enableSpeciesField = true;
                    _speciesNameController.text = '';
                    _transectAnnotationsController.text = '';
                    measureType = TransectPointTypes.species;
                    stopTimer();
                    resetTimer();
                    formStage = 'init';
                    widget.updateMeasuresCallback(widget.measures);
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
          userName.split('_').join(' ').toUpperCase(),
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
    setState(() {
      markString = '$hours:$minutes:$seconds';
    });
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

  // Init state methods
  void initPerefernces() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userName = sharedPreferences.getString('username') ?? '';
    });
  }
}
