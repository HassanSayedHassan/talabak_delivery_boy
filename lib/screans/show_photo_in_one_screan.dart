
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class show_photo_in_one_screan extends StatelessWidget {

  var image;
  show_photo_in_one_screan(this.image);
  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider:
      CachedNetworkImageProvider(image),
    );
  }
}
