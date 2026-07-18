/*
 *   Webkul Software.
 *   @package Mobikul Application Code.
 *   @Category Mobikul
 *   @author Webkul <support@webkul.com>
 *   @Copyright (c) Webkul Software Private Limited (https://webkul.com)
 *   @license https://store.webkul.com/license.html
 *   @link https://store.webkul.com/license.html
 */

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:bagisto_app_demo/screens/checkout/utils/index.dart'  hide Options;
import '../../../data_model/save_order_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ProcessPaynowPayment extends StatefulWidget {
  const ProcessPaynowPayment({Key? key}) : super(key: key);

  @override
  State<ProcessPaynowPayment> createState() => _ProcessPaynowPaymentState();
}

class _ProcessPaynowPaymentState extends State<ProcessPaynowPayment> with TickerProviderStateMixin {
  bool isLoggedIn = false;
  SaveOrderModel? saveOrderModel;
  late AnimationController _controller;
  static const int _timerDuration = 15 * 60;

  @override
  void initState() {
    SaveOrderBloc saveOrderBloc = context.read<SaveOrderBloc>();
    saveOrderBloc.add(SaveOrderFetchDataEvent());
    isLoggedIn = appStoragePref.getCustomerLoggedIn();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timerDuration),
    );
    // Start the countdown
    _controller.reverse(from: 1.0);
    _controller.addStatusListener(_timerCompletionListener);
    super.initState();
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
      _controller.stop();
      _controller.dispose(); 
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
          title: Text(StringConstants.paynow.localized()),
          automaticallyImplyLeading: true,
          centerTitle: false,
        ),
        body: _saveOrderBloc(context));
  }

  ///SaverOrder BLOC CONTAINER///
  _saveOrderBloc(BuildContext context) {
    return BlocConsumer<SaveOrderBloc, SaveOrderBaseState>(
      listener: (BuildContext context, SaveOrderBaseState state) {},
      builder: (BuildContext context, SaveOrderBaseState state) {
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
  Widget buildUI(BuildContext context, SaveOrderBaseState state) {
    if (state is SaveOrderFetchDataState) {
      if (state.status == SaveOrderStatus.success) {
        saveOrderModel = state.saveOrderModel;
        NavigatorState navigator = Navigator.of(context);
        _enquirePaymentStatus(navigator).then(_handlePaymentStatusresult);
        return _processPaynowView(state.saveOrderModel!);
      }
      if (state.status == SaveOrderStatus.fail) {
        return ErrorMessage.errorMsg(
            "${state.error ?? ""} ${StringConstants.addMoreProductsMsg}"
                .localized());
      }
    }
    if (state is SaveOrderInitialState) {
      return const Loader();
    }

    return const SizedBox();
  }

  void _handlePaymentStatusresult(SaveOrderModel? result) {
    _controller.removeStatusListener(_timerCompletionListener);
    _controller.stop();
    _controller.dispose(); 
    if(result != null && result?.success == true) {
      Navigator.pushReplacementNamed(context, orderPlacedScreen, arguments: {"model": result});
    } else {
      ShowMessage.errorNotification(
            StringConstants.failedPayment.localized(), context);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  Future<SaveOrderModel?> _enquirePaymentStatus(NavigatorState navState) async {
    int count = 5, i=0;
    SaveOrderModel? model;
    while(i < count) {
      try {
        model = await ApiClient().enquirePaymentStatus(saveOrderModel?.payment?.chargeId);
        return model;
      } catch (e) {
        //Do Nothing
        print('Error: $e');
      }
      sleep(const Duration(seconds: 10));
      i++;
    }
    return null;
  }

  _processPaynowView(SaveOrderModel saveOrderModel) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingNormal),
      alignment: Alignment.center,
      child: Wrap(
        children: [
          Card(
            elevation: 0,
            shape: const ContinuousRectangleBorder(),
            // color: Colors.white,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.spacingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: AppSizes.spacingSmall,
                  ),
                  Wrap(
                    children: [
                      Text(
                        StringConstants.completePayment
                            .localized()
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: AppSizes.spacingLarge,
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
                  const SizedBox(
                    height: AppSizes.spacingSmall,
                  ),
                  Image.network(saveOrderModel.payment?.qrFileLink ?? "", 
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover),
                  const SizedBox(
                    height: AppSizes.spacingSmall,
                  ),
                  MaterialButton(
                    color: Theme.of(context).colorScheme.onBackground,
                    elevation: 0.0,
                    textColor: Theme.of(context).colorScheme.background,
                    onPressed: () {
                      try {
                        _saveQRToPhotos(saveOrderModel.payment?.qrFileLink).then((result) => {
                          if(context.mounted) {
                            ShowMessage.successNotification(result, context)
                          }
                        });
                          
                      } catch (e) {
                          ShowMessage.errorNotification('Error: $e', context);
                      }
                    },
                    child: Text(
                      StringConstants.downloadQR
                          .localized()
                          .toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.background
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: AppSizes.spacingSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
