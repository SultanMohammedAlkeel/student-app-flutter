import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../models/service_model.dart';
import '../widgets/service_card.dart';

class ServicesGridView extends StatelessWidget {
  final List<ServiceModel> services;
  final bool isDarkMode;
  final Function(ServiceModel) onServiceSelected;

  const ServicesGridView({
    Key? key,
    required this.services,
    required this.isDarkMode,
    required this.onServiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isLandscape = width > 600;
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLandscape ? 4 : 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(
              service: service,
              isDarkMode: isDarkMode,
              onTap: () => onServiceSelected(service),
            );
          },
        );
      },
    );
  }
}
