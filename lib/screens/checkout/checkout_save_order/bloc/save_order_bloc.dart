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


class SaveOrderBloc extends Bloc<SaveOrderBaseEvent, SaveOrderBaseState> {
  SaveOrderRepository? repository;
  Object? arguments;

  SaveOrderBloc(this.repository,this.arguments) : super(SaveOrderInitialState()){
    on<SaveOrderBaseEvent>(mapEventToState);
  }
  void mapEventToState(SaveOrderBaseEvent event,Emitter<SaveOrderBaseState> emit) async {
    if (event is SaveOrderFetchDataEvent) {
      try {
        Map<String, dynamic> args = arguments as Map<String, dynamic>;
        SaveOrderModel? saveOrderModel;

        if(args['model'] is SaveOrderModel) {
          saveOrderModel = args['model'];
        } else {
          saveOrderModel = await repository?.savePaymentReview(arguments as Map<String, dynamic>?);
        }
        
        if(saveOrderModel?.success==true) {
          emit (SaveOrderFetchDataState.success(saveOrderModel: saveOrderModel));
        }else{
          emit (SaveOrderFetchDataState.fail(error: "Fail to complete payment"));
        }
        
      } catch (e) {
        emit (SaveOrderFetchDataState.fail(error: e.toString()));
      }
    }

  }

}
