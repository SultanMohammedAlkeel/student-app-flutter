import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final IconData iconData;
  final Color color;
  final String route;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.color,
    required this.route,
  });

  // تحويل النموذج إلى Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconData': iconData.codePoint,
      'color': color.value,
      'route': route,
    };
  }

  // إنشاء نموذج من Map (لا يستخدم عادة لأن الخدمات ثابتة)
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconData: IconData(json['iconData'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      route: json['route'],
    );
  }
}
