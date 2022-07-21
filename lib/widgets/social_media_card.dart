import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../size_config.dart';

class SocialMediaCard extends StatelessWidget {
  const SocialMediaCard({
    Key? key,
    required this.assetPath,
    required this.onPress,
  }) : super(key: key);

  final String assetPath;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.all(getProportionateScreenWidth(12)),
        padding: EdgeInsets.all(getProportionateScreenWidth(12)),
        height: getProportionateScreenHeight(40),
        width: getProportionateScreenWidth(40),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F6F9),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(assetPath),
      ),
    );
  }
}
