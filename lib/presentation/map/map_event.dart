import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:yeohaeng_ttukttak/data/vo/filter.dart';
import 'package:yeohaeng_ttukttak/domain/model/place.dart';
import 'package:yeohaeng_ttukttak/presentation/map/components/place_sort_option.dart';

part 'map_event.freezed.dart';

@freezed
abstract class MapEvent with _$MapEvent {
  const factory MapEvent.findNearbyPlace() = FindNearbyPlaceEvent;
  const factory MapEvent.getPlaceDetail(Place place) = GetPlaceDetailEvent;
  const factory MapEvent.selectPlace(Place? place) = SelectPlaceEvent;
  const factory MapEvent.selectPlaceSearchResult(Place place) = _PlaceSearchResult;
  const factory MapEvent.changePosition(CameraPosition position) = ChangePositionEvent;
  const factory MapEvent.changeToMyPosition() = MoveToMyPositionEvent;
  const factory MapEvent.updateFilter(Filter filter) = UpdateFilterEvent;
  const factory MapEvent.sortPlace(PlaceSortOption option) = _SortPlace;
}
