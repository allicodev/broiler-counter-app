import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:scanner/models/bounding_boxes.dart';
import 'package:scanner/provider/app_provider.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:scanner/utilities/shared_pref.dart';
import 'package:scanner/widgets/snackbar.dart';

class Detector extends StatefulWidget {
  const Detector({super.key});

  @override
  State<Detector> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Detector> {
  late ModelObjectDetection _objectModel;
  final ImagePicker _picker = ImagePicker();
  String? _imagePrediction;
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  List<BoundingBox> boxes = [];

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  bool generatingBoxes = false;
  bool sendingToAdmin = false;
  bool fetching = false;
  File? _image;
  bool openCamera = false;

  int aganars = 0;
  int price = 0;

  late List<CameraDescription> cameras;
  late CameraController _cameraController;
  get _controller => _cameraController;

  Future<void> init() async {
    fetching = true;
    await getValue("price").then((e) {
      setState(() => price = int.parse(e));
      fetching = false;
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    initPusher();
    init();
  }

  Future loadModel() async {
    String pathObjectDetectionModel = "assets/yolov5s.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
          pathObjectDetectionModel, 80, 640, 640,
          labelPath: "assets/labels.txt");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  Future runObjectDetection(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      generatingBoxes = true;
    });

    List<BoundingBox> _boxes = [];
    objDetect = await _objectModel.getImagePrediction(
        await File(image.path).readAsBytes(),
        minimumScore: 0.5,
        IOUThershold: 0.3,
        boxesLimit: 99);

    for (var element in objDetect) {
      if (element != null && element.className == "bird") {
        _boxes.add(BoundingBox(
            className: element.className!,
            top: element.rect.top,
            left: element.rect.left,
            width: element.rect.width,
            height: element.rect.height));
      }
    }
    setState(() {
      generatingBoxes = false;
      _image = File(image.path);
      boxes = _boxes;
    });
  }

  Future initPusher() async {
    await pusher.init(
      apiKey: "8736f06e31cef8829144",
      cluster: "ap1",
      onConnectionStateChange: (current, previous) {},
      onEvent: (PusherEvent event) {},
    );
    await pusher.subscribe(channelName: 'jarold-gwapo');
    await pusher.connect();
  }

  sendToAdmin() {
    pusher.trigger(PusherEvent(
      channelName: "jarold-gwapo",
      eventName: "new-broiler",
    ));
    Provider.of<AppProvider>(context, listen: false).sendBroiler(
        payload: boxes.length,
        callback: (code, message) {
          launchSnackbar(
              context: context,
              mode: code != 200 ? "ERROR" : "SUCCESS",
              message: message);

          if (code == 200) {
            setState(() {
              boxes = [];
              _image = null;
            });
          }
        });
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    aganars++;

    if (aganars % 2 == 0 && openCamera) {
      List<BoundingBox> _boxes = [];

      objDetect = await _objectModel.getImagePredictionFromBytesList(
          cameraImage.planes.map((e) => e.bytes).toList(),
          cameraImage.width,
          cameraImage.height,
          minimumScore: 0.5,
          IOUThershold: 0.3,
          boxesLimit: 99);

      for (var element in objDetect) {
        if (element != null && element.className == "bird") {
          _boxes.add(BoundingBox(
              className: element.className!,
              top: element.rect.top,
              left: element.rect.left,
              width: element.rect.width,
              height: element.rect.height));
        }
      }
      setState(() {
        generatingBoxes = false;
        boxes = _boxes;
      });
    }

    setState(() {});
    // _detector?.processFrame(cameraImage);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider app = context.watch<AppProvider>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Widget generateImageWithBoundingBoxes() {
      return SizedBox(
        width: width,
        height: height * 0.65,
        child: Stack(
          children: List.generate(
                  boxes.length,
                  (i) =>
                      boxes[i].drawableContainer(width, height * 0.65, false))
              .toList(),
        ),
      );
    }

    return Scaffold(
        body: fetching
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : openCamera
                ? Column(
                    children: [
                      Stack(
                        children: [
                          CameraPreview(_controller),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100)),
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      openCamera = false;
                                      _image = null;
                                    });

                                    _cameraController.dispose();
                                  },
                                  icon: const Icon(Icons.close)),
                            ),
                          ),
                          generateImageWithBoundingBoxes(),
                          Text(boxes.length.toString()),
                        ],
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned(
                                top: 0,
                                left: 5,
                                child: Text(
                                    'Found (${boxes.length}) Broiler Chicken',
                                    style: const TextStyle(
                                        color: Colors.black87))),
                            Center(
                              child: ElevatedButton(
                                onPressed: () =>
                                    boxes.isEmpty ? null : sendToAdmin(),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: app.loading == "sending"
                                      ? const CircularProgressIndicator()
                                      : boxes.isEmpty
                                          ? const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "No broiler scanned in the image"),
                                                Text("Please try again"),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                        "$PESO$price x ${boxes.length} = $PESO${boxes.length * price}",
                                                        style: const TextStyle(
                                                            fontSize: 24.0))
                                                  ],
                                                ),
                                                const Text(
                                                    "(Tap to confirm and send to Admin)")
                                              ],
                                            ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : generatingBoxes
                    ? const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator()),
                            SizedBox(width: 10.0),
                            Text("Generating boxes")
                          ],
                        ),
                      )
                    : _image != null
                        ? Column(
                            children: [
                              Stack(
                                children: [
                                  SizedBox(
                                    height: height * 0.65,
                                    child: Image.file(
                                      _image!,
                                      width: width,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  generateImageWithBoundingBoxes(),
                                  Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle),
                                            child: IconButton(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                icon: const Icon(
                                                    Icons.camera_alt),
                                                onPressed: () async {
                                                  cameras =
                                                      await availableCameras();

                                                  _cameraController =
                                                      CameraController(
                                                    cameras[0],
                                                    ResolutionPreset.medium,
                                                    enableAudio: false,
                                                  )..initialize()
                                                            .then((_) async {
                                                          await _controller
                                                              .startImageStream(
                                                                  onLatestImageAvailable);
                                                          setState(() {});
                                                        });

                                                  setState(
                                                      () => openCamera = true);
                                                }),
                                          ),
                                          const SizedBox(height: 10.0),
                                          Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle),
                                            child: IconButton(
                                              icon: const Icon(Icons.image),
                                              onPressed: () =>
                                                  runObjectDetection(
                                                      ImageSource.gallery),
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 0,
                                        left: 5,
                                        child: Text(
                                            'Found (${boxes.length}) Broiler Chicken',
                                            style: const TextStyle(
                                                color: Colors.black87))),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () => boxes.isEmpty
                                            ? null
                                            : sendToAdmin(),
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          child: app.loading == "sending"
                                              ? const CircularProgressIndicator()
                                              : boxes.isEmpty
                                                  ? const Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            "No broiler scanned in the image"),
                                                        Text(
                                                            "Please try again"),
                                                      ],
                                                    )
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                "$PESO$price x ${boxes.length} = $PESO${boxes.length * price}",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        24.0))
                                                          ],
                                                        ),
                                                        const Text(
                                                            "(Tap to confirm and send to Admin)")
                                                      ],
                                                    ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Visibility(
                                    visible: _imagePrediction != null,
                                    child: Text("$_imagePrediction"),
                                  ),
                                ),
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        cameras = await availableCameras();

                                        _cameraController = CameraController(
                                          cameras[0],
                                          ResolutionPreset.medium,
                                          enableAudio: false,
                                        )..initialize().then((_) async {
                                            await _controller.startImageStream(
                                                onLatestImageAvailable);
                                            setState(() {});
                                          });

                                        setState(() => openCamera = true);
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Open Camera"),
                                          SizedBox(width: 15.0),
                                          Icon(Icons.camera_alt)
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    ElevatedButton(
                                      onPressed: () => runObjectDetection(
                                          ImageSource.gallery),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Open Gallery"),
                                          SizedBox(width: 15.0),
                                          Icon(Icons.image)
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ));
  }
}
