import 'package:flutter/material.dart';

extension MemriIcon on IconData {
  static IconData getByName(String iconName) {
    //TODO: need to discuss with team @mkslanc
    switch (iconName) {
      case 'person.circle':
        return Icons.person;
      case 'bell':
        return Icons.notifications_none;
      case 'creditcard':
        return Icons.credit_card;
      case 'cart':
        return Icons.shopping_cart;
      case 'hand.thumbsdown':
        return Icons.thumb_down;
      case 'increase.indent':
        return Icons.read_more;
      case 'envelope.fill':
        return Icons.email;
      case 'bubble.left.fill':
        return Icons.chat_bubble;
      case 'square.and.pencil':
      case 'pencil':
        return Icons.edit;
      case 'star.fill':
        return Icons.star;
      case 'star':
        return Icons.star_border;
      case "xmark.circle":
        return Icons.close;
      case "plus":
        return Icons.add;
      case "rhombus.fill":
        return Icons.filter_list;
      case "arrow_right":
        return Icons.arrow_right;
      case "bold":
        return Icons.format_bold;
      case "italic":
        return Icons.format_italic;
      case "underline":
        return Icons.format_underline;
      case "strikethrough":
        return Icons.format_strikethrough;
      case "paintpalette":
        return Icons.palette;
      case "highlighter":
        return Icons.border_color_outlined;
      case "camera":
        return Icons.camera_alt_outlined;
      case "photo":
        return Icons.image_outlined;
      case "checkmark.square":
        return Icons.check_box_outlined;
      case "list.bullet":
        return Icons.format_list_bulleted;
      case "list.number":
        return Icons.format_list_numbered;
      case "decrease.indent":
        return Icons.format_indent_decrease;
      case "increase.indent":
        return Icons.format_indent_increase;
      case "textbox": //TODO:
        return Icons.article_outlined;
      case "arrowshape.turn.up.left.circle":
        return Icons.arrow_back;
      case "trash":
        return Icons.delete;
      case "minus.circle.fill":
        return Icons.remove_circle;
      case 'plus':
        return Icons.add;
      case 'increase.indent':
        return Icons.format_indent_increase;
      case 'cloud':
        return Icons.cloud_queue;
      case 'ellipsis':
        return Icons.more_horiz;
      case 'calendar':
        return Icons.calendar_today;
      default:
        print("Unknown icon $iconName");
        return Icons.contact_support_rounded;
    }
  }
}
