import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MainLogo extends StatelessWidget {
  const MainLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: const [
            Icon(
              FontAwesomeIcons.locationPin,
              color: FlexColor.bahamaBlueDarkSecondaryContainer,
              size: 55,
            ),
            Positioned(
              top: 12.0,
              child: Icon(
                FontAwesomeIcons.solidHeart,
                // fill: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 4.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'GottaGo',
            style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)
                .copyWith(fontSize: 60),
          ),
        ),
      ],
    );
  }
}
