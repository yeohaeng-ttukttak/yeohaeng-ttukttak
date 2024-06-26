import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yeohaeng_ttukttak/domain/model/image.dart';

import 'package:yeohaeng_ttukttak/domain/model/place_review.dart';
import 'package:yeohaeng_ttukttak/domain/model/travel.dart';

part 'place_detail_state.freezed.dart';

@freezed
class PlaceDetailState with _$PlaceDetailState {
  factory PlaceDetailState(
      {@Default(false) bool isBusinessHourExpanded,
      @Default(0) int imageIndex,
      @Default([]) List<Image> images,
      @Default([]) List<PlaceReview> reviews,
      @Default([]) List<Travel> travels}) = _PlaceDetailState;
}
