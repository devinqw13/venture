import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeFormat {

  Widget withoutDate(String dateString, {bool numericDates = true, TextStyle? style}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return Text(
        '${(difference.inDays / 365).floor()}yr',
        style: style
      );
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? 
        Text('1yr',style: style) : 
        Text('Last year', style: style);
    } else if ((difference.inDays / 30).floor() >= 2) {
      return Text(
        '${((difference.inDays / 365) * 10).floor()}mo',
        style: style
      );
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? 
        Text('1mo', style: style) :
        Text('Last month', style: style);
    } else if ((difference.inDays / 7).floor() >= 2) {
      return Text(
        '${(difference.inDays / 7).floor()}w',
        style: style
      );
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? 
        Text('1w', style: style) :
        Text('Last week', style: style);
    } else if (difference.inDays >= 2) {
      return Text(
        '${difference.inDays}d',
        style: style
      );
    } else if (difference.inDays >= 1) {
      return (numericDates) ?
        Text('1d', style: style) :
        Text('Yesterday', style: style);
    } else if (difference.inHours >= 2) {
      return Text(
        '${difference.inHours}h',
        style: style
      );
    } else if (difference.inHours >= 1) {
      return (numericDates) ?
        Text('1h', style: style) :
        Text('An hour ago', style: style);
    } else if (difference.inMinutes >= 2) {
      return Text(
        '${difference.inMinutes}m',
        style: style
      );
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ?
        Text('1m', style: style) :
        Text('A minute ago', style: style);
    } else if (difference.inSeconds >= 30) {
      return Text(
        '${difference.inSeconds}s',
        style: style
      );
    } else {
      return Text(
        'Just now',
        style: style
      );
    }
  }

  Widget withDate(String dateString, {bool numericDates = true, TextStyle? style}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if (difference.inDays >= 7) {
      DateFormat format = date.year < date2.year ? DateFormat('MMM d, yyyy') : DateFormat('MMM d');
      return Text(format.format(date), style: style);
    } else if (difference.inDays >= 1) {
      return (numericDates) ?
        Text('${difference.inDays}d', style: style) :
        Text('${difference.inDays} days ago', style: style);
    } else if (difference.inHours >= 2) {
      return (numericDates) ? 
        Text('${difference.inHours}h', style: style) : 
        Text('${difference.inHours} hours ago', style: style);
    } else if (difference.inHours >= 1) {
      return (numericDates) ?
        Text('1h', style: style) :
        Text('An hour ago', style: style);
    } else if (difference.inMinutes >= 2) {
      return (numericDates) ?
        Text('${difference.inMinutes}m', style: style) :
        Text('${difference.inMinutes} minutes ago', style: style);
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ?
        Text('1m', style: style) :
        Text('A minute ago', style: style);
    } else if (difference.inSeconds >= 30) {
      return (numericDates) ?
        Text('${difference.inSeconds}s', style: style) :
        Text('${difference.inSeconds} seconds ago', style: style);
    } else {
      return Text(
        'Just now',
        style: style
      );
    }
  }
}