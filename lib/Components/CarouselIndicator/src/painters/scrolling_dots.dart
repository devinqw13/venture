import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venture/Components/CarouselIndicator/src/effects/scrolling_dots.dart';

import 'indicator_painter.dart';

/// Paints a scale-dot transition effect between active
/// and non-active dots
///
/// Good for big pages count because it can show
/// only [ScrollingDotsEffect.maxVisibleDots] at once
/// and scrolls as needed
class ScrollingDotsPainter extends BasicIndicatorPainter {
  /// The painting configuration
  final ScrollingDotsEffect effect;

  /// Default constructor
  ScrollingDotsPainter({
    required this.effect,
    required int count,
    required double offset,
  }) : super(offset, count, effect);

  @override
  void paint(Canvas canvas, Size size) {
    final current = super.offset.floor();
    final switchPoint = (effect.maxVisibleDots / 2).floor();
    final firstVisibleDot =
        (current < switchPoint || count - 1 < effect.maxVisibleDots)
            ? 0
            : min(current - switchPoint, count - effect.maxVisibleDots);
    final lastVisibleDot =
        min(firstVisibleDot + effect.maxVisibleDots, count - 1);
    final inPreScrollRange = current < switchPoint;
    final inAfterScrollRange = current >= (count - 1) - switchPoint;
    final willStartScrolling = (current + 1) == switchPoint + 1;
    final willStopScrolling = current + 1 == (count - 1) - switchPoint;

    final dotOffset = offset - offset.toInt();
    final dotPaint = Paint()
      ..strokeWidth = effect.strokeWidth
      ..style = effect.paintStyle;

    final drawingAnchor = (inPreScrollRange || inAfterScrollRange)
        ? -(firstVisibleDot * distance)
        : -((offset - switchPoint) * distance);

    const smallDotScale = 0.66;
    final activeScale = effect.activeDotScale - 1.0;
    for (var index = firstVisibleDot; index <= lastVisibleDot; index++) {
      var color = effect.dotColor;

      var scale = 1.0;

      if (index == current) {
        // ! Both a and b are non nullable
        color = Color.lerp(effect.activeDotColor, effect.dotColor, dotOffset)!;
        if (offset > count - 1 && count > effect.maxVisibleDots) {
          scale = effect.activeDotScale - (smallDotScale * dotOffset);
        } else {
          scale = effect.activeDotScale - (activeScale * dotOffset);
        }
      } else if ((index == firstVisibleDot && offset > count - 1)) {
        color = Color.lerp(effect.dotColor, effect.activeDotColor, dotOffset)!;
        if (count <= effect.maxVisibleDots) {
          scale = 1 + (activeScale * dotOffset);
        } else {
          scale =
              smallDotScale + (((1 - smallDotScale) + activeScale) * dotOffset);
        }
      } else if (index - 1 == current) {
        // ! Both a and b are non nullable
        color = Color.lerp(effect.dotColor, effect.activeDotColor, dotOffset)!;
        scale = 1.0 + (activeScale * dotOffset);
      } else if (count - 1 < effect.maxVisibleDots) {
        scale = 1.0;
      } else if (index == firstVisibleDot) {
        if (willStartScrolling) {
          scale = (1.0 * (1.0 - dotOffset));
        } else if (inAfterScrollRange) {
          scale = smallDotScale;
        } else if (!inPreScrollRange) {
          scale = smallDotScale * (1.0 - dotOffset);
        }
      } else if (index == firstVisibleDot + 1 &&
          !(inPreScrollRange || inAfterScrollRange)) {
        scale = 1.0 - (dotOffset * (1.0 - smallDotScale));
      } else if (index == lastVisibleDot - 1.0) {
        if (inPreScrollRange) {
          scale = smallDotScale;
        } else if (!inAfterScrollRange) {
          scale = smallDotScale + ((1.0 - smallDotScale) * dotOffset);
        }
      } else if (index == lastVisibleDot) {
        if (inPreScrollRange) {
          scale = 0.0;
        } else if (willStopScrolling) {
          scale = dotOffset;
        } else if (!inAfterScrollRange) {
          scale = smallDotScale * dotOffset;
        }
      }

      final scaledWidth = (effect.dotWidth * scale);
      final scaledHeight = effect.dotHeight * scale;
      final yPos = size.height / 2;
      final xPos = effect.dotWidth / 2 + drawingAnchor + (index * distance);

      final rRect = RRect.fromLTRBR(
        xPos - scaledWidth / 2 + effect.spacing / 2,
        yPos - scaledHeight / 2,
        xPos + scaledWidth / 2 + effect.spacing / 2,
        yPos + scaledHeight / 2,
        dotRadius * scale,
      );

      canvas.drawRRect(rRect, dotPaint..color = color);
    }
  }
}

class ScrollingDotsWithFixedCenterPainter extends BasicIndicatorPainter {
  /// The painting configuration
  final ScrollingDotsEffect effect;

  /// Default constructor
  ScrollingDotsWithFixedCenterPainter({
    required this.effect,
    required int count,
    required double offset,
  }) : super(offset, count, effect);

  @override
  void paint(Canvas canvas, Size size) {
    var current = offset.floor();
    var dotOffset = offset - current;
    var dotPaint = Paint()
      ..strokeWidth = effect.strokeWidth
      ..style = effect.paintStyle;

    for (var index = 0; index < count; index++) {
      var color = effect.dotColor;
      if (index == current) {
        // ! Both a and b are non nullable
        color = Color.lerp(effect.activeDotColor, effect.dotColor, dotOffset)!;
      } else if (index - 1 == current) {
        // ! Both a and b are non nullable
        color =
            Color.lerp(effect.activeDotColor, effect.dotColor, 1 - dotOffset)!;
      }

      var scale = 1.0;
      const smallDotScale = 0.66;
      final revDotOffset = 1 - dotOffset;
      final switchPoint = (effect.maxVisibleDots - 1) / 2;

      if (count > effect.maxVisibleDots) {
        if (index >= current - switchPoint &&
            index <= current + (switchPoint + 1)) {
          if (index == (current + switchPoint)) {
            scale = smallDotScale + ((1 - smallDotScale) * dotOffset);
          } else if (index == current - (switchPoint - 1)) {
            scale = 1 - (1 - smallDotScale) * dotOffset;
          } else if (index == current - switchPoint) {
            scale = (smallDotScale * revDotOffset);
          } else if (index == current + (switchPoint + 1)) {
            scale = (smallDotScale * dotOffset);
          }
        } else {
          continue;
        }
      }

      final rRect = _calcBounds(
        size.height,
        size.width / 2 - (offset * (effect.dotWidth + effect.spacing)),
        index,
        scale,
      );

      canvas.drawRRect(rRect, dotPaint..color = color);
    }

    final rRect =
        _calcBounds(size.height, size.width / 2, 0, effect.activeDotScale);
    canvas.drawRRect(
        rRect,
        Paint()
          ..color = effect.activeDotColor
          ..strokeWidth = effect.activeStrokeWidth
          ..style = PaintingStyle.stroke);
  }

  RRect _calcBounds(double canvasHeight, double startingPoint, num i,
      [double scale = 1.0]) {
    final scaledWidth = effect.dotWidth * scale;
    final scaledHeight = effect.dotHeight * scale;

    final xPos = startingPoint + (effect.dotWidth + effect.spacing) * i;
    final yPos = canvasHeight / 2;
    return RRect.fromLTRBR(
      xPos - scaledWidth / 2,
      yPos - scaledHeight / 2,
      xPos + scaledWidth / 2,
      yPos + scaledHeight / 2,
      dotRadius * scale,
    );
  }
}