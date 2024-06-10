import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final double? textWidthInPercentage;
  final IconData? icon;
  final String label;
  final double? size;
  final Color? color;
  final FontWeight? fontWeight;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? width;
  final double? height;
  final bool? isLoading;
  final double? letterSpacing;
  final String? fontFamily;
  final double? iconSize;
  final bool? expandText;
  const IconText(
      {Key? key,
      this.icon,
      required this.label,
      this.size,
      this.width,
      this.height,
      this.color,
      this.fontWeight,
      this.mainAxisAlignment,
      this.backgroundColor,
      this.borderRadius,
      this.textWidthInPercentage,
      this.isLoading,
      this.padding,
      this.letterSpacing,
      this.iconSize,
      this.fontFamily,
      this.expandText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget text = Text(
      label,
      maxLines: 1,
      style: TextStyle(
          fontSize: (size ?? 13),
          color: color ?? Colors.black,
          letterSpacing: letterSpacing,
          fontFamily: fontFamily,
          fontWeight: fontWeight ?? FontWeight.normal),
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius ?? 0)),
      padding: padding ?? const EdgeInsets.all(0),
      child: Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
          children: [
            if (isLoading ?? false)
              SizedBox(
                  height: size ?? 13,
                  width: size ?? 13,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 1,
                  ))
            else if (icon != null)
              Icon(
                icon,
                size: iconSize ?? (size ?? 13),
                color: color ?? Colors.black,
              ),
            if (icon != null || isLoading != null) const SizedBox(width: 5),
            if (expandText ?? false)
              Expanded(child: text)
            else
              SizedBox(
                width: textWidthInPercentage != null
                    ? MediaQuery.of(context).size.width * textWidthInPercentage!
                    : null,
                child: text,
              )
          ]),
    );
  }
}
