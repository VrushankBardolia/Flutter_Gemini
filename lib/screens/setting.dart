import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemini_ai/global.dart';

enum Mode { precise, neutral, creative }

Map <Mode,double> modeValue = <Mode,double> {
  Mode.precise: 0.1,
  Mode.neutral: 0.5,
  Mode.creative: 0.9,
};

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {

  late Mode selectedMode;

  @override
  Widget build(BuildContext context) {

    if(temperature == 0.1){
      selectedMode = Mode.precise;
    } else if (temperature == 0.5){
      selectedMode = Mode.neutral;
    }else if (temperature == 0.9){
      selectedMode = Mode.creative;
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text('Response Type',style: TextStyle(fontSize: 18),),
              CupertinoSlidingSegmentedControl(
                thumbColor: Theme.of(context).colorScheme.primaryContainer,
                groupValue: selectedMode,
                onValueChanged: (value) {
                  if(value != null){
                    setState(() {
                      selectedMode = value;
                      temperature = modeValue[selectedMode]!;
                    });
                  }
                },
                children:const <Mode,Widget>{
                  Mode.precise: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Precise'),
                  ),
                  Mode.neutral: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Neutral'),
                  ),
                  Mode.creative: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Creative'),
                  ),
                },
              ),
              // Text(modeValue[selectedMode].toString()),
              // Text(temperature.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
