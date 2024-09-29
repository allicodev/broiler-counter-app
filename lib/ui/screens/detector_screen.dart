import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:scanner/main.dart';
import 'package:scanner/models/bounding_boxes.dart';
import 'package:scanner/provider/app_provider.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:scanner/widgets/snackbar.dart';

class Detector extends StatefulWidget {
  const Detector({super.key});

  @override
  State<Detector> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Detector> {
  late ModelObjectDetection _objectModel;
  final ImagePicker _picker = ImagePicker();
  List<BoundingBox> boxes = [];
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  bool generatingBoxes = false;
  bool sendingToAdmin = false;
  bool fetching = false;
  File? _image;

  bool _isCameraInitialized = false;
  CameraImage? imgCamera;
  bool isWorking = false;
  int frameSkipCount = 0;
  final GlobalKey cameraPreviewKey = GlobalKey();
  String inferenceTime = "Inference time: 0ms";
  Timer? _debounce;

  int aganars = 0;

  late CameraController _cameraController;
  get _controller => _cameraController;

  @override
  void initState() {
    super.initState();
    loadModel();
    initPusher();
  }

  @override
  void dispose() {
    if (_isCameraInitialized) {
      _cameraController.stopImageStream();
      _cameraController.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  Future loadModel() async {
    String pathObjectDetectionModel = "assets/yolov5s.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
          pathObjectDetectionModel, 1, 640, 640,
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

    final __image = await File(image.path).readAsBytes();
    final resizedImage =
        img.copyResize(img.decodeImage(__image)!, width: 640, height: 640);

    setState(() {
      generatingBoxes = true;
    });

    List<BoundingBox> _boxes = [];
    final objDetect = await _objectModel.getImagePredictionList(
        img.encodeJpg(resizedImage),
        minimumScore: 0.85,
        IOUThershold: 0.85,
        boxesLimit: 99);
    for (var element in objDetect) {
      if (element != null) {
        _boxes.add(BoundingBox(
            className: element.className ?? "aga nars",
            top: element.rect.top,
            left: element.rect.left,
            width: element.rect.width,
            height: element.rect.height,
            confidence: element.score));
      }
    }
    setState(() {
      generatingBoxes = false;
      _image = File(image.path);
      boxes = _boxes;
    });
  }

  Future<void> runLiveObjectDetection() async {
    if (!_isCameraInitialized || imgCamera == null || !mounted)
      return; // Check if the camera is initialized here
    final stopwatch = Stopwatch()..start(); // Start the stopwatch

    final previewSize = cameraPreviewKey.currentContext
        ?.findRenderObject()
        ?.semanticBounds
        .size;

    final objDetect = await _objectModel.getImagePredictionFromBytesList(
        imgCamera!.planes.map((plane) => plane.bytes).toList(),
        imgCamera!.width,
        imgCamera!.height,
        minimumScore: 0.70,
        IOUThershold: 0.70,
        boxesLimit: 99);

    List<BoundingBox> _boxes = [];
    for (var element in objDetect) {
      if (element != null) {
        _boxes.add(BoundingBox(
            className: element.className ?? "aga nars",
            top: element.rect.top,
            left: element.rect.left,
            width: element.rect.width,
            height: element.rect.height,
            confidence: element.score));
      }
    }

    if (!mounted)
      return; // Check if the widget is still in the tree before calling setState
    updateBoxes(_boxes);
    isWorking = false;
    stopwatch.stop(); // Stop the stopwatch
    if (!mounted) return; // Another check before calling setState
    setState(() {
      inferenceTime =
          "Inference time: ${stopwatch.elapsedMilliseconds}ms"; // Update inference time
    });
  }

  void updateBoxes(List<BoundingBox> newBoxes) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          boxes = newBoxes;
        });
      }
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
    double price = Provider.of<AppProvider>(context, listen: false).price;

    pusher.trigger(PusherEvent(
      channelName: "jarold-gwapo",
      eventName: "new-broiler",
    ));

    Provider.of<AppProvider>(context, listen: false).sendBroiler(
        payload: {
          "broiler": boxes.length,
          "total": price * boxes.length,
          "price": price
        },
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

  @override
  Widget build(BuildContext context) {
    AppProvider app = context.watch<AppProvider>();

    double price = app.price;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Widget generateImageWithBoundingBoxes() {
      return SizedBox(
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
            : _isCameraInitialized
                ? Column(
                    children: [
                      SizedBox(
                        height: height * 0.65,
                        child: Stack(
                          children: [
                            ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: SizedBox(
                                    width: width,
                                    height: height * .65,
                                    child: AspectRatio(
                                      aspectRatio:
                                          _controller.value.aspectRatio,
                                      child: CameraPreview(
                                        _controller,
                                        key: cameraPreviewKey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                                        _isCameraInitialized = false;
                                        _image = null;
                                      });
                                      _cameraController.stopImageStream();
                                      _cameraController.dispose();
                                    },
                                    icon: const Icon(Icons.close)),
                              ),
                            ),
                            Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  color: Colors.black87,
                                  child: Text(
                                    inferenceTime,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )),
                            generateImageWithBoundingBoxes(),
                          ],
                        ),
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
                                      fit: BoxFit.fill,
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
                                                  if (mounted) {
                                                    setState(() {
                                                      boxes = [];
                                                      _image = null;
                                                    });
                                                  }

                                                  _cameraController =
                                                      CameraController(
                                                          cameras![0],
                                                          ResolutionPreset
                                                              .high);

                                                  _cameraController
                                                      .initialize()
                                                      .then((_) {
                                                    if (!mounted) {
                                                      return;
                                                    }
                                                    setState(() {
                                                      _isCameraInitialized =
                                                          true;
                                                      _cameraController
                                                          .startImageStream(
                                                              (imageFromStream) {
                                                        if (!isWorking &&
                                                            frameSkipCount++ %
                                                                    2 ==
                                                                0) {
                                                          isWorking = true;
                                                          imgCamera =
                                                              imageFromStream;
                                                          runLiveObjectDetection();
                                                        }
                                                      });
                                                    });
                                                  }).catchError((error) {
                                                    print(
                                                        "Error initializing camera: $error");
                                                  });
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
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        _cameraController = CameraController(
                                            cameras![0], ResolutionPreset.high);

                                        _cameraController
                                            .initialize()
                                            .then((_) {
                                          if (!mounted) {
                                            return;
                                          }
                                          setState(() {
                                            _isCameraInitialized = true;
                                            _cameraController.startImageStream(
                                                (imageFromStream) {
                                              if (!isWorking &&
                                                  frameSkipCount++ % 2 == 0) {
                                                isWorking = true;
                                                imgCamera = imageFromStream;
                                                runLiveObjectDetection();
                                              }
                                            });
                                          });
                                        }).catchError((error) {
                                          print(
                                              "Error initializing camera: $error");
                                        });
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
