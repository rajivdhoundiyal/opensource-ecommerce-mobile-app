/*
 *   Webkul Software.
 *   @package Mobikul Application Code.
 *   @Category Mobikul
 *   @author Webkul <support@webkul.com>
 *   @Copyright (c) Webkul Software Private Limited (https://webkul.com)
 *   @license https://store.webkul.com/license.html
 *   @link https://store.webkul.com/license.html
 */



import 'package:bagisto_app_demo/screens/checkout/utils/index.dart';
import '../../data_model/save_order_model.dart';

abstract class SaveOrderRepository{
  Future<SaveOrderModel>savePaymentReview(Map<String, dynamic>? arguments);

}
class SaveOrderRepositoryImp implements SaveOrderRepository {
  SaveOrderRepositoryImp();

  @override
  Future<SaveOrderModel> savePaymentReview(Map<String, dynamic>? arguments) async {
    SaveOrderModel? saveOrderModel;
    try {
      saveOrderModel = await ApiClient().placeOrder(arguments?['token'], arguments?['paymentType'], arguments?['amount'], arguments?['currency'], arguments?['chargeId']);
    } catch (error, stacktrace) {
      debugPrint("Error --> $error");
      debugPrint("StackTrace --> $stacktrace");
    }
    return saveOrderModel!;
  }
}


