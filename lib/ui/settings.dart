import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:scanner/utilities/shared_pref.dart';
import 'package:scanner/widgets/button.dart';
import 'package:scanner/widgets/form/textfieldstyle.dart';
import 'package:scanner/widgets/snackbar.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int price = 0;
  bool fetching = false;

  Future<void> init() async {
    fetching = true;
    await getValue("price").then((e) {
      setState(() => price = e != "" ? int.parse(e) : 0);
      fetching = false;
    });

    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: const Text("Settings"),
      ),
      body: fetching
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text("Broiler Price",
                              style: TextStyle(fontSize: 22.0)),
                          const SizedBox(width: 25.0),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextFormField(
                                onChanged: (val) =>
                                    setState(() => price = int.parse(val)),
                                initialValue: price.toString(),
                                style: const TextStyle(fontSize: 21),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Sender Name is required";
                                  }
                                  return null;
                                },
                                decoration: textFieldStyle(
                                    prefix: "₱",
                                    labelStyle: const TextStyle(fontSize: 25),
                                    contentPadding: const EdgeInsets.all(5.0),
                                    backgroundColor:
                                        ACCENT_PRIMARY.withOpacity(.03)),
                              ))
                        ],
                      )
                    ],
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Button(
                        label: "SAVE",
                        icon: Icons.save,
                        backgroundColor: ACCENT_PRIMARY,
                        borderColor: Colors.transparent,
                        onPress: () {
                          setKeyValue("price", price.toString());
                          launchSnackbar(
                              context: context,
                              mode: "SUCCESS",
                              message: "Saved successfully");
                        },
                      ))
                ],
              ),
            ),
    );
  }
}
