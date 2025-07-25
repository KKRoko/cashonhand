// Cash on Hand - Reusable Component Library
// Pre-built components using design tokens for consistent UI implementation

import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/enhanced_theme.dart';

/// 🎨 COMPONENT LIBRARY - Reusable UI Building Blocks
/// These components use design tokens and provide consistent styling across the app

/// 💰 FINANCIAL AMOUNT DISPLAY
/// Specialized widget for displaying financial amounts with proper styling and color coding
class FinancialAmount extends StatelessWidget {
  const FinancialAmount({
    super.key,
    required this.amount,
    this.size = FinancialAmountSize.medium,
    this.showSign = true,
    this.showCurrency = true,
    this.currency = '\$',
    this.style,
    this.maxWidth,
    this.adaptive = true,
  });

  final double amount;
  final FinancialAmountSize size;
  final bool showSign;
  final bool showCurrency;
  final String currency;
  final TextStyle? style;
  final double? maxWidth;
  final bool adaptive; // Whether to use adaptive scaling

  @override
  Widget build(BuildContext context) {
    final financial = context.financial;
    final isPositive = amount >= 0;
    final isZero = amount == 0;
    
    // Determine color based on amount
    Color color;
    if (isZero) {
      color = financial.neutralColor;
    } else if (isPositive) {
      color = financial.incomeColor;
    } else {
      color = financial.expenseColor;
    }

    // Get base text style token based on size
    String styleToken;
    double minFontSize;
    double maxFontSize;
    
    switch (size) {
      case FinancialAmountSize.small:
        styleToken = 'amountSmall';
        minFontSize = 10.0;
        maxFontSize = 16.0;
        break;
      case FinancialAmountSize.medium:
        styleToken = 'amountMedium';
        minFontSize = 12.0;
        maxFontSize = 20.0;
        break;
      case FinancialAmountSize.large:
        styleToken = 'amountLarge';
        minFontSize = 16.0;
        maxFontSize = 32.0;
        break;
    }

    // Get responsive text style
    TextStyle textStyle = adaptive
        ? DesignTokens.adaptiveTextStyle(
            styleToken,
            context,
            maxWidth: maxWidth,
            minFontSize: minFontSize,
            maxFontSize: maxFontSize,
          )
        : DesignTokens.textStyle(styleToken);

    // Format the amount with smart formatting for large numbers
    String formattedAmount = _formatAmount(amount.abs());
    String displayText = '';
    
    if (showCurrency) {
      displayText += currency;
    }
    
    // Signs removed - relying on color coding instead
    
    displayText += formattedAmount;

    // Use FittedBox to prevent overflow and ensure text fits
    return maxWidth != null
        ? SizedBox(
            width: maxWidth,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                displayText,
                style: (style ?? textStyle).copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayText,
              style: (style ?? textStyle).copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          );
  }

  /// Smart number formatting that abbreviates large amounts
  String _formatAmount(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}

enum FinancialAmountSize { small, medium, large }

/// 📱 RESPONSIVE TEXT
/// Text widget that automatically scales and prevents wrapping
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.styleToken,
    this.maxWidth,
    this.minFontSize,
    this.maxFontSize,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.adaptive = true,
  });

  final String text;
  final TextStyle? style;
  final String? styleToken;
  final double? maxWidth;
  final double? minFontSize;
  final double? maxFontSize;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final int maxLines;
  final bool adaptive;

  @override
  Widget build(BuildContext context) {
    // Get base text style
    TextStyle baseStyle;
    if (style != null) {
      baseStyle = style!;
    } else if (styleToken != null) {
      baseStyle = adaptive
          ? DesignTokens.adaptiveTextStyle(
              styleToken!,
              context,
              minFontSize: minFontSize,
              maxFontSize: maxFontSize,
            )
          : DesignTokens.textStyle(styleToken!);
    } else {
      baseStyle = DesignTokens.responsiveTextStyle('bodyMedium', context);
    }

    final textWidget = Text(
      text,
      style: baseStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );

    // If maxWidth is specified, use FittedBox to prevent overflow
    if (maxWidth != null) {
      return SizedBox(
        width: maxWidth,
        child: maxLines == 1
            ? FittedBox(
                fit: BoxFit.scaleDown,
                alignment: textAlign == TextAlign.center
                    ? Alignment.center
                    : textAlign == TextAlign.right
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: textWidget,
              )
            : textWidget,
      );
    }

    return textWidget;
  }
}

/// 🃏 ENHANCED CARD
/// Card component with design token styling and optional financial context
class CashCard extends StatelessWidget {
  const CashCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 'sm',
    this.onTap,
    this.financialContext,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final String elevation;
  final VoidCallback? onTap;
  final FinancialContext? financialContext;

  @override
  Widget build(BuildContext context) {
    final financial = context.financial;
    
    // Determine background color based on financial context
    Color bgColor = backgroundColor ?? DesignTokens.color('surface');
    Color border = borderColor ?? DesignTokens.color('border');
    
    if (financialContext != null) {
      switch (financialContext!) {
        case FinancialContext.income:
          bgColor = financial.incomeBackground;
          border = financial.incomeColor.withOpacity(0.3);
          break;
        case FinancialContext.expense:
          bgColor = financial.expenseBackground;
          border = financial.expenseColor.withOpacity(0.3);
          break;
        case FinancialContext.neutral:
          bgColor = financial.neutralBackground;
          border = financial.neutralColor.withOpacity(0.3);
          break;
      }
    }

    Widget card = Container(
      margin: margin ?? EdgeInsets.all(DesignTokens.space('xs')),
      padding: padding ?? EdgeInsets.all(DesignTokens.space('md')),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: DesignTokens.radius('md'),
        border: Border.all(color: border, width: 1),
        boxShadow: DesignTokens.shadow(elevation),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.radius('md'),
        child: card,
      );
    }

    return card;
  }
}

enum FinancialContext { income, expense, neutral }

/// 🔘 ENHANCED BUTTONS
/// Button components with consistent styling from design tokens

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    this.loading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonSize size;
  final bool fullWidth;
  final bool loading;  
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(size),
      child: FilledButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DesignTokens.color('onPrimary'),
                ),
              )
            : (icon != null ? Icon(icon, size: _getIconSize(size)) : const SizedBox.shrink()),
        label: child,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(size),
            vertical: DesignTokens.space('sm'),
          ),
          textStyle: _getTextStyle(size),
        ),
      ),
    );
  }

  double _getHeight(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  double _getHorizontalPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.space('sm');
      case ButtonSize.medium:
        return DesignTokens.space('md');
      case ButtonSize.large:
        return DesignTokens.space('lg');
    }
  }

  double _getIconSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.textStyle('labelMedium');
      case ButtonSize.medium:
        return DesignTokens.textStyle('labelLarge');
      case ButtonSize.large:
        return DesignTokens.textStyle('titleSmall');
    }
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonSize size;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(size),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: _getIconSize(size)) : const SizedBox.shrink(),
        label: child,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(size),
            vertical: DesignTokens.space('sm'),
          ),
          textStyle: _getTextStyle(size),
        ),
      ),
    );
  }

  double _getHeight(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  double _getHorizontalPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.space('sm');
      case ButtonSize.medium:
        return DesignTokens.space('md');
      case ButtonSize.large:
        return DesignTokens.space('lg');
    }
  }

  double _getIconSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.textStyle('labelMedium');
      case ButtonSize.medium:
        return DesignTokens.textStyle('labelLarge');
      case ButtonSize.large:
        return DesignTokens.textStyle('titleSmall');
    }
  }
}

class FinancialButton extends StatelessWidget {
  const FinancialButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.financialType,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FinancialButtonType financialType;
  final ButtonSize size;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final financial = context.financial;
    
    Color backgroundColor;
    Color foregroundColor;
    
    switch (financialType) {
      case FinancialButtonType.income:
        backgroundColor = financial.incomeColor;
        foregroundColor = DesignTokens.color('onSuccess');
        break;
      case FinancialButtonType.expense:
        backgroundColor = financial.expenseColor;
        foregroundColor = DesignTokens.color('onError');
        break;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(size),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: _getIconSize(size)) : const SizedBox.shrink(),
        label: child,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(size),
            vertical: DesignTokens.space('sm'),
          ),
          textStyle: _getTextStyle(size),
        ),
      ),
    );
  }

  double _getHeight(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  double _getHorizontalPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.space('sm');
      case ButtonSize.medium:
        return DesignTokens.space('md');
      case ButtonSize.large:
        return DesignTokens.space('lg');
    }
  }

  double _getIconSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return DesignTokens.textStyle('labelMedium');
      case ButtonSize.medium:
        return DesignTokens.textStyle('labelLarge');
      case ButtonSize.large:
        return DesignTokens.textStyle('titleSmall');
    }
  }
}

enum ButtonSize { small, medium, large }
enum FinancialButtonType { income, expense }

/// 📊 PROGRESS INDICATORS
/// Progress indicators with financial context and design token styling

class FinancialProgressBar extends StatelessWidget {
  const FinancialProgressBar({
    super.key,
    required this.value,
    required this.total,
    this.height = 8,
    this.showLabels = true,
    this.label,
    this.financialContext = FinancialContext.income,
  });

  final double value;
  final double total;
  final double height;
  final bool showLabels;
  final String? label;
  final FinancialContext financialContext;

  @override
  Widget build(BuildContext context) {
    final financial = context.financial;
    final progress = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    
    Color progressColor;
    switch (financialContext) {
      case FinancialContext.income:
        progressColor = financial.incomeColor;
        break;
      case FinancialContext.expense:
        progressColor = financial.expenseColor;
        break;
      case FinancialContext.neutral:
        progressColor = financial.neutralColor;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: DesignTokens.textStyle('labelMedium'),
                ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: DesignTokens.textStyle('labelMedium').copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.space('xs')),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: DesignTokens.color('surfaceContainer'),
            borderRadius: DesignTokens.radius('full'),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: DesignTokens.radius('full'),
              ),
            ),
          ),
        ),
        if (showLabels) ...[
          SizedBox(height: DesignTokens.space('xs')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FinancialAmount(
                amount: value,
                size: FinancialAmountSize.small,
                showSign: false,
              ),
              FinancialAmount(
                amount: total,
                size: FinancialAmountSize.small,
                showSign: false,
                style: DesignTokens.textStyle('amountSmall').copyWith(
                  color: DesignTokens.color('textSecondary'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 🏷 CATEGORY CHIP
/// Chip component for displaying categories with icons and financial context

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.name,
    this.icon,
    this.financialContext,
    this.selected = false,
    this.onTap,
    this.size = ChipSize.medium,
  });

  final String name;
  final String? icon;
  final FinancialContext? financialContext;
  final bool selected;
  final VoidCallback? onTap;
  final ChipSize size;

  @override
  Widget build(BuildContext context) {
    final financial = context.financial;
    
    Color backgroundColor = DesignTokens.color('surfaceContainer');
    Color textColor = DesignTokens.color('textPrimary');
    Color borderColor = DesignTokens.color('border');
    
    if (selected) {
      backgroundColor = DesignTokens.color('primaryContainer');
      textColor = DesignTokens.color('onPrimaryContainer');
      borderColor = DesignTokens.color('primary');
    } else if (financialContext != null) {
      switch (financialContext!) {
        case FinancialContext.income:
          backgroundColor = financial.incomeBackground;
          borderColor = financial.incomeColor.withOpacity(0.3);
          break;
        case FinancialContext.expense:
          backgroundColor = financial.expenseBackground;
          borderColor = financial.expenseColor.withOpacity(0.3);
          break;
        case FinancialContext.neutral:
          backgroundColor = financial.neutralBackground;
          borderColor = financial.neutralColor.withOpacity(0.3);
          break;
      }
    }

    EdgeInsets padding;
    TextStyle textStyle;
    double iconSize;
    
    switch (size) {
      case ChipSize.small:
        padding = EdgeInsets.symmetric(
          horizontal: DesignTokens.space('xs'),
          vertical: DesignTokens.space('xs') / 2,
        );
        textStyle = DesignTokens.textStyle('labelSmall');
        iconSize = 14;
        break;
      case ChipSize.medium:
        padding = EdgeInsets.symmetric(
          horizontal: DesignTokens.space('sm'),
          vertical: DesignTokens.space('xs'),
        );
        textStyle = DesignTokens.textStyle('labelMedium');
        iconSize = 16;
        break;
      case ChipSize.large:
        padding = EdgeInsets.symmetric(
          horizontal: DesignTokens.space('md'),
          vertical: DesignTokens.space('sm'),
        );
        textStyle = DesignTokens.textStyle('labelLarge');
        iconSize = 18;
        break;
    }

    Widget chip = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: DesignTokens.radius('full'),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(
              icon!,
              style: TextStyle(fontSize: iconSize),
            ),
            SizedBox(width: DesignTokens.space('xs')),
          ],
          Text(
            name,
            style: textStyle.copyWith(color: textColor),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }

    return chip;
  }
}

enum ChipSize { small, medium, large }

/// 🎬 ANIMATED TRANSITIONS
/// Pre-built animations using design token timing

class FadeTransition extends StatelessWidget {
  const FadeTransition({
    super.key,
    required this.child,
    required this.visible,
    this.duration = 'normal',
    this.curve = 'easeInOut',
  });

  final Widget child;
  final bool visible;
  final String duration;
  final String curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: DesignTokens.duration(duration),
      curve: DesignTokens.curve(curve),
      child: child,
    );
  }
}

class SlideTransition extends StatelessWidget {
  const SlideTransition({
    super.key,
    required this.child,
    required this.visible,
    this.direction = SlideDirection.up,
    this.duration = 'normal',
    this.curve = 'easeInOut',
  });

  final Widget child;
  final bool visible;
  final SlideDirection direction;
  final String duration;
  final String curve;

  @override
  Widget build(BuildContext context) {
    Offset begin;
    switch (direction) {
      case SlideDirection.up:
        begin = const Offset(0, 1);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -1);
        break;
      case SlideDirection.left:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(-1, 0);
        break;
    }

    return AnimatedSlide(
      offset: visible ? Offset.zero : begin,
      duration: DesignTokens.duration(duration),
      curve: DesignTokens.curve(curve),
      child: child,
    );
  }
}

enum SlideDirection { up, down, left, right }

class ExpandTransition extends StatelessWidget {
  const ExpandTransition({
    super.key,
    required this.child,
    required this.expanded,
    this.axis = Axis.vertical,
    this.duration = 'normal',
    this.curve = 'easeInOut',
  });

  final Widget child;
  final bool expanded;
  final Axis axis;
  final String duration;
  final String curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignTokens.duration(duration),
      curve: DesignTokens.curve(curve),
      height: axis == Axis.vertical ? (expanded ? null : 0) : null,
      width: axis == Axis.horizontal ? (expanded ? null : 0) : null,
      child: ClipRect(child: child),
    );
  }
}

/// 📏 SPACING UTILITIES
/// Helper widgets for consistent spacing

class VSpace extends StatelessWidget {
  const VSpace(this.space, {super.key});
  
  final String space;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: DesignTokens.space(space));
  }
}

class HSpace extends StatelessWidget {
  const HSpace(this.space, {super.key});
  
  final String space;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: DesignTokens.space(space));
  }
}

/// 🎯 RESPONSIVE HELPERS
/// Utilities for responsive design

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return DesignTokens.responsive<Widget>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

class ResponsiveValue<T> extends StatelessWidget {
  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;
  final Widget Function(T value) builder;

  @override
  Widget build(BuildContext context) {
    final value = DesignTokens.responsive<T>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    
    return builder(value);
  }
}