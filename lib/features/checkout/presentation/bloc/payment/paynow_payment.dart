import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bagisto_flutter/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../checkout_bloc.dart';
import 'package:flutter/material.dart';

class PaynowPaymentPage extends StatefulWidget {
  final String qrLink;
  final String chargeId;
  final ValueNotifier<bool> placeOrderNotifier;
  const PaynowPaymentPage({Key? key, required this.qrLink, required this.chargeId, required this.placeOrderNotifier}) : super(key: key);

  @override
  State<PaynowPaymentPage> createState() => _PaynowPaymentPageState();
}

class _PaynowPaymentPageState extends State<PaynowPaymentPage> with TickerProviderStateMixin {
  bool isLoggedIn = false;
  late AnimationController _controller;
  static const int _timerDuration = 15 * 60;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timerDuration),
    );
    // Start the countdown
    _controller.reverse(from: 1.0);
    super.initState();
    widget.placeOrderNotifier.addListener(() => _timerCompletionListener(widget.placeOrderNotifier.value ? AnimationStatus.completed : AnimationStatus.dismissed));
    _controller.addStatusListener(_timerCompletionListener);
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    bool statuses;
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      statuses = sdkInt < 29 ? await Permission.storage.request().isGranted : true;
    } else {
      statuses = await Permission.photosAddOnly.request().isGranted;
    }
  }

  void _timerCompletionListener(AnimationStatus status) {
    if (status == AnimationStatus.completed ||status == AnimationStatus.dismissed) {
      _controller.removeStatusListener(_timerCompletionListener);
      Navigator.pop(context);
    }
  }

  Future<String> _saveQRToPhotos(String? url) async {
    try {
      final response = await Dio().get(url ?? "",
        options: Options(responseType: ResponseType.bytes),
      );
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String picturesPath = 'image_$timestamp.jpg';
      final result = await SaverGallery.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        fileName: picturesPath,
        //albumPath: "NetworkImages",
        skipIfExists: true,
      );
      return result.toString();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.paynow),
          automaticallyImplyLeading: true,
          centerTitle: false,
        ),
        body: _processPaynowView(widget.qrLink));
  }

  ///SaverOrder BLOC CONTAINER///
  _saveOrderBloc(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) => {
      },
      builder: (BuildContext context, CheckoutState state) {
        return buildUI(context, state);
      },
    );
  }

  String get timerString {
    Duration duration = _controller.duration! * _controller.value;
    String minutes = '${duration.inMinutes}';
    String seconds = '${duration.inSeconds % 60}'.padLeft(2, '0');
    return '$minutes:$seconds';
  }

  ///SaverOrder UI METHODS///
  Widget buildUI(BuildContext context, CheckoutState state) {
    return _processPaynowView(widget.qrLink);
    // if (state is SaveOrderFetchDataState) {
    //   if (state.status == SaveOrderStatus.success) {
    //     saveOrderModel = state.saveOrderModel;
    //     NavigatorState navigator = Navigator.of(context);
    //     _enquirePaymentStatus(navigator).then(_handlePaymentStatusresult);
    //     return _processPaynowView(state.saveOrderModel!);
    //   }
    //   if (state.status == SaveOrderStatus.fail) {
    //     return ErrorMessage.errorMsg(
    //         "${state.error ?? ""} ${StringConstants.addMoreProductsMsg}"
    //             .localized());
    //   }
    // }
    // if (state is SaveOrderInitialState) {
    //   return const Loader();
    // }

    //return const SizedBox();
  }

  // void _handlePaymentStatusresult(SaveOrderModel? result) {
  //   _controller.removeStatusListener(_timerCompletionListener);
  //   _controller.stop();
  //   _controller.dispose(); 
  //   if(result != null && result?.success == true) {
  //     Navigator.pushReplacementNamed(context, orderPlacedScreen, arguments: {"model": result});
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(AppLocalizations.of(context)!.failedPayment),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     Navigator.pop(context);
  //     Navigator.pop(context);
  //   }
  // }

  // Future<CheckoutOr?> _enquirePaymentStatus(NavigatorState navState) async {

  //   context.read<CheckoutBloc>().add(PlaceOrder());
  //   int count = 5, i=0;
  //   SaveOrderModel? model;
  //   while(i < count) {
  //     try {
  //       model = await ApiClient().enquirePaymentStatus(saveOrderModel?.payment?.chargeId);
  //       return model;
  //     } catch (e) {
  //       //Do Nothing
  //       print('Error: $e');
  //     }
  //     sleep(const Duration(seconds: 10));
  //     i++;
  //   }
  //   return null;
  // }

  Widget _processPaynowView(String qrLink) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: Wrap(
        children: [
          Card(
            elevation: 0,
            shape: const ContinuousRectangleBorder(),
            // color: Colors.white,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 2,
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.completePayment,
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Text(
                            timerString,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                            ),
                          );
                        },
                      )
                    ],
                  ),
                  Image.network(qrLink, 
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover),
                  const SizedBox(
                    height: 8,
                  ),
                  MaterialButton(
                    color: Theme.of(context).colorScheme.onBackground,
                    elevation: 0.0,
                    textColor: Theme.of(context).colorScheme.background,
                    onPressed: () {
                      try {
                        _saveQRToPhotos(qrLink).then((result) => {
                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                backgroundColor: Colors.green,
                              ),
                            )
                          }
                        });
                          
                      } catch (e) {
                        if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.downloadQR,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.background
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
   void dispose() {
     _controller.stop();
     _controller.dispose(); 
     super.dispose();
   }
}
