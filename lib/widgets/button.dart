import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final bool? isLoading;
  final IconData? icon;
  final IconData? rightIcon;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Function? onPress;
  final Function? onLongPress;
  final EdgeInsets? padding;
  // bool? disabled;
  final double? borderRadius;
  final EdgeInsets? margin;
  final double? fontSize;
  final MainAxisAlignment? mainAxisAlignment;
  final FontWeight? fontWeight;
  final bool? displayMode;
  final bool? isTextExpanded;
  final double? width;
  final double? height;

  const Button(
      {Key? key,
      this.icon,
      this.isLoading = false,
      required this.label,
      this.onPress,
      this.onLongPress,
      this.backgroundColor,
      this.borderColor,
      this.padding,
      // this.disabled,
      this.borderRadius,
      this.margin,
      this.fontSize,
      this.rightIcon,
      this.mainAxisAlignment,
      this.fontWeight,
      this.textColor,
      this.displayMode,
      this.isTextExpanded,
      this.width,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var text = Text(label,
        textAlign: TextAlign.left,
        maxLines: 1,
        style: TextStyle(
          fontWeight: fontWeight ?? FontWeight.w600,
          fontSize: fontSize ?? 14,
          letterSpacing: 0.27,
          color: textColor ?? Colors.white,
        ));

    return Opacity(
      opacity:
          !(displayMode ?? false) && (onPress == null && onLongPress == null)
              ? 0.5
              : 1,
      child: Container(
        margin: margin,
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 5)),
            border: Border.all(color: borderColor ?? Colors.black54)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 5)),
            onLongPress: (onLongPress == null || isLoading!)
                ? null
                : () => onLongPress!(),
            onTap: (onPress == null || isLoading!) ? null : () => onPress!(),
            child: Padding(
              padding: padding ??
                  const EdgeInsets.only(
                      top: 12, bottom: 12, left: 18, right: 18),
              child: Center(
                child: Row(
                  mainAxisAlignment:
                      mainAxisAlignment ?? MainAxisAlignment.center,
                  children: [
                    if (isLoading!)
                      SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: textColor ?? Colors.white,
                          strokeWidth: 1,
                        ),
                      ),
                    if (icon != null && !isLoading!)
                      Icon(
                        icon,
                        color: textColor ?? Colors.white,
                        size: fontSize ?? 14,
                      ),
                    if (icon != null || isLoading!)
                      SizedBox(
                        width: isLoading! ? 15 : 10,
                      ),
                    (isTextExpanded ?? false) ? Expanded(child: text) : text,
                    if (rightIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Icon(
                          rightIcon,
                          color: textColor ?? Colors.white,
                          size: fontSize ?? 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
