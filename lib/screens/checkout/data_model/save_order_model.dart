/*
 *   Webkul Software.
 *   @package Mobikul Application Code.
 *   @Category Mobikul
 *   @author Webkul <support@webkul.com>
 *   @Copyright (c) Webkul Software Private Limited (https://webkul.com)
 *   @license https://store.webkul.com/license.html
 *   @link https://store.webkul.com/license.html
 */

import 'package:json_annotation/json_annotation.dart';

import '../../../data_model/graphql_base_model.dart';
part 'save_order_model.g.dart';


@JsonSerializable()
class SaveOrderModel extends BaseModel{

  String? redirectUrl;
  String?  selectedMethod;
  Order? order;
  String? chargeId;
  Payment? payment;
  SaveOrderModel({this.redirectUrl,this.selectedMethod,this.order, this.chargeId, this.payment});

  factory SaveOrderModel.fromJson(Map<String, dynamic> json) =>
      _$SaveOrderModelFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$SaveOrderModelToJson(this);


}
@JsonSerializable()
class Order {
  int? id;
  String? customerEmail;
  String? customerFirstName;
  String? customerLastName;


  Order({this.id,this.customerEmail, this.customerFirstName, this.customerLastName,
});

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OrderToJson(this);
}

@JsonSerializable()
class Payment {
  String? chargeId;
  String? qrCodePath;
  String? qrFileLink;

  Payment({this.chargeId,this.qrCodePath, this.qrFileLink,});

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PaymentToJson(this);
}