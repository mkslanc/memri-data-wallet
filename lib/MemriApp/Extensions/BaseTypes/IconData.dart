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
      default:
        return Icons.contact_support_rounded;
    }
  }
}
