import 'package:flutter/material.dart';

class RapidRiseLogo extends StatelessWidget {
  final double width;
  final double height;

  const RapidRiseLogo({
    super.key,
    this.width = 200,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: RapidRiseLogoPainter(),
      ),
    );
  }
}

class RapidRiseLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double stripeWidth = size.width * 0.04;
    final double stripeGap = size.width * 0.02;
    final double stripeHeight = size.height * 0.5;
    final double stripeY = size.height * 0.25;

    // Paint for yellow stripes
    final stripePaint = Paint()
      ..color = const Color(0xFFFFDD00)
      ..style = PaintingStyle.fill;

    // Draw the three stripes
    canvas.drawRect(
      Rect.fromLTWH(0, stripeY, stripeWidth, stripeHeight),
      stripePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          stripeWidth + stripeGap, stripeY, stripeWidth, stripeHeight),
      stripePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          (stripeWidth + stripeGap) * 2, stripeY, stripeWidth, stripeHeight),
      stripePaint,
    );

    // Text configuration
    final textStart = (stripeWidth + stripeGap) * 3 + stripeWidth;

    // "Rapid" text
    final rapidTextPainter = TextPainter(
      text: TextSpan(
        text: 'Rapid',
        style: TextStyle(
          color: const Color(0xFF1B365D),
          fontSize: size.height * 0.5,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // "Rise" text
    final riseTextPainter = TextPainter(
      text: TextSpan(
        text: 'Rise',
        style: TextStyle(
          color: const Color(0xFF1B365D),
          fontSize: size.height * 0.5,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Paint the text
    rapidTextPainter.paint(
      canvas,
      Offset(textStart, size.height * 0.25),
    );
    riseTextPainter.paint(
      canvas,
      Offset(textStart + rapidTextPainter.width, size.height * 0.25),
    );

    // Paint the TM symbol
    final tmTextPainter = TextPainter(
      text: TextSpan(
        text: '™',
        style: TextStyle(
          color: const Color(0xFF1B365D),
          fontSize: size.height * 0.2,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tmTextPainter.paint(
      canvas,
      Offset(
        textStart + rapidTextPainter.width + riseTextPainter.width + 2,
        size.height * 0.2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
