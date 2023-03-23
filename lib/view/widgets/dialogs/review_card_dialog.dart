import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../tweens/custom_rect_tween.dart';

class ReviewCardDialog extends StatelessWidget {
  final dynamic review;
  const ReviewCardDialog({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              createRectTween: (begin, end) {
                return CustomRectTween(begin: begin!, end: end!);
              },
              tag: 'reviewHero',
              child: Card(
                elevation: 1.6,
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            '"${review['text']}"',
                            maxLines: 30,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: 125,
                        child: FittedBox(
                          child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8.0,
                              children: [
                                RatingBar.builder(
                                    allowHalfRating: true,
                                    itemSize: 12,
                                    itemCount: 5,
                                    ignoreGestures: true,
                                    initialRating: review['rating'].toDouble(),
                                    itemBuilder: (context, index) {
                                      return const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      );
                                    },
                                    onRatingUpdate: (value) {}),
                                Text(
                                  '${review['rating'].toString()}.0',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: CircleAvatar(
                                radius: 16,
                                child: CachedNetworkImage(
                                    imageUrl: review['profile_photo_url']),
                              ),
                            ),
                            const SizedBox(
                              width: 12.0,
                            ),
                            Flexible(
                              flex: 4,
                              child: FittedBox(
                                child: Text(
                                  review['author_name'],
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ),
          ]),
    );
  }
}
