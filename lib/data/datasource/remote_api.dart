import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:yeohaeng_ttukttak/data/models/page_model.dart';
import 'package:yeohaeng_ttukttak/data/models/visit_model.dart';
import 'package:yeohaeng_ttukttak/data/vo/image_model.dart';
import 'package:yeohaeng_ttukttak/domain/model/auth.dart';
import 'package:yeohaeng_ttukttak/domain/model/bookmark.dart';
import 'package:yeohaeng_ttukttak/domain/model/member.dart';
import 'package:yeohaeng_ttukttak/domain/model/image.dart';
import 'package:yeohaeng_ttukttak/domain/model/place.dart';
import 'package:yeohaeng_ttukttak/domain/model/place_review.dart';
import 'package:yeohaeng_ttukttak/domain/model/place_suggestion.dart';
import 'package:yeohaeng_ttukttak/domain/model/profile.dart';
import 'package:yeohaeng_ttukttak/domain/model/travel.dart';
import 'package:yeohaeng_ttukttak/domain/model/visit.dart';
import 'package:yeohaeng_ttukttak/utils/api_error.dart';
import 'package:yeohaeng_ttukttak/utils/result.dart';

class RemoteAPI {
  final Dio dio;

  RemoteAPI(this.dio);

  final String remoteUrl = const String.fromEnvironment("REMOTE_URL");
  final String remoteHost = const String.fromEnvironment("REMOTE_HOST");

  final Map<String, String> headers = {
    'Content-type': 'application/json; charset=UTF-8',
    'Accept-Language': 'ko'
  };

  Future<Result<Auth, ApiError>> signIn(String email, String password) async {
    try {
      final response = await dio.post('$remoteUrl/api/v1/members/sign-in',
          data: {'email': email, 'password': password},
          options: Options(headers: headers));

      return Result.success(Auth.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Member, ApiError>> signUp(String email, String password,
      String nickname, String verificationCode) async {
    try {
      final response = await dio.post('$remoteUrl/api/v1/members/sign-up',
          data: {
            'email': email,
            'password': password,
            'nickname': nickname,
            'verificationCode': verificationCode
          },
          options: Options(headers: headers));

      return Result.success(Member.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Auth, ApiError>> renewAuth(String refreshToken) async {
    try {
      final response = await dio.post('$remoteUrl/api/v1/members/auth/renew',
          data: {'refreshToken': refreshToken},
          options: Options(headers: headers));

      return Result.success(Auth.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Member, ApiError>> findProfile() async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/members/profile',
          options: Options(headers: headers));

      return Result.success(Member.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<Travel>, ApiError>> findNearby(
      double latitude, double longitude, int radius) async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/travels/nearby',
          queryParameters: {
            'location': '$latitude,$longitude',
            'radius': radius.toString(),
          },
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => Travel.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<PageModel<ImageModel>, ApiError>> getImages(
      int id, int page, int pageSize) async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/places/$id/images',
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString()
          },
          options: Options(headers: headers));

      return Result.success(
          PageModel<ImageModel>.of(ImageModel.of, response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<void, ApiError>> verifyEmail(String email) async {
    try {
      await dio.post('$remoteUrl/api/v1/members/email/verify/send',
          data: {'email': email}, options: Options(headers: headers));

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<DailyVisitSummary>, ApiError>> findVisits(int id) async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/travels/$id/visits',
          options: Options(headers: headers));

      return Result.success(List.of(response.data["data"])
          .map((e) => DailyVisitSummary.of(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Bookmark, ApiError>> addPlaceBookmark(int id) async {
    try {
      final response = await dio.post('$remoteUrl/api/v1/bookmarks/places/$id',
          options: Options(headers: headers));

      return Result.success(Bookmark.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Bookmark, ApiError>> deletePlaceBookmark(int id) async {
    try {
      final response = await dio.delete(
          '$remoteUrl/api/v1/bookmarks/places/$id',
          options: Options(headers: headers));

      return Result.success(Bookmark.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Bookmark, ApiError>> addTravelBookmark(int id) async {
    try {
      final response = await dio.post('$remoteUrl/api/v1/bookmarks/travels/$id',
          options: Options(headers: headers));

      return Result.success(Bookmark.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Bookmark, ApiError>> deleteTravelBookmark(int id) async {
    try {
      final response = await dio.delete(
          '$remoteUrl/api/v1/bookmarks/travels/$id',
          options: Options(headers: headers));

      return Result.success(Bookmark.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<Place>, ApiError>> getBookmarkedPlace() async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/places/bookmarked',
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => Place.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<Travel>, ApiError>> getBookmarkedTravel() async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/travels/bookmarked',
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => Travel.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Place, ApiError>> findPlace(int id) async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/places/$id',
          options: Options(headers: headers));

      return Result.success(Place.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<Travel>, ApiError>> findMyTravels() async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/travels/member/my',
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => Travel.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Travel, ApiError>> findTravel(int id) async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/travels/$id',
          options: Options(headers: headers));

      return Result.success(Travel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<Visit>, ApiError>> findTravelVisits(int id) async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/travels/$id/visits',
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => Visit.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<int, ApiError>> createTravel(Travel travel) async {
    try {
      final response = await dio.post('$remoteUrl/api/v1/travels/',
          options: Options(headers: headers),
          data: {
            'name': travel.name,
            'startedOn': travel.startedOn?.toIso8601String(),
            'endedOn': travel.endedOn?.toIso8601String(),
            'visibility': travel.visibility
          });

      return Result.success(
          int.parse(response.headers['location']!.first.split('/').last));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<void, ApiError>> createTravelVisits(
      int travelId, List<Visit> visits) async {
    try {
      await dio.post('$remoteUrl/api/v1/travels/$travelId/visits',
          options: Options(headers: headers),
          data: visits
              .map<Map<String, dynamic>>((visit) => {
                    'dayOfTravel': visit.dayOfTravel,
                    'orderOfVisit': visit.orderOfVisit,
                    'placeId': visit.place.id
                  })
              .toList());

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<void, ApiError>> modifyTravel(
      Travel travel, List<Visit> visits) async {
    try {
      await dio.patch('$remoteUrl/api/v1/travels/${travel.id}',
          options: Options(headers: headers),
          data: {
            'name': travel.name,
            'startedOn': travel.startedOn?.toIso8601String(),
            'endedOn': travel.endedOn?.toIso8601String(),
            'visibility': travel.visibility,
            'visits': visits
                .map<Map<String, dynamic>>((visit) => {
                      'id': visit.id,
                      'dayOfTravel': visit.dayOfTravel,
                      'orderOfVisit': visit.orderOfVisit,
                      'placeId': visit.place.id
                    })
                .toList()
          });

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<PlaceSuggestion>, ApiError>> autocomplete(
      String query) async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/places/autocomplete',
          queryParameters: {'query': query},
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => PlaceSuggestion.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<PlaceReview>, ApiError>> findPlaceReviews(
      int placeId) async {
    try {
      final response = await dio.get(
          '$remoteUrl/api/v1/places/$placeId/reviews',
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => PlaceReview.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<Travel>, ApiError>> findPlaceTravels(int placeId) async {
    try {
      final response = await dio.get(
          '$remoteUrl/api/v1/places/$placeId/travels',
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => Travel.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<List<Image>, ApiError>> findPlaceImages(int placeId) async {
    try {
      final response = await dio.get('$remoteUrl/api/v1/places/$placeId/images',
          options: Options(headers: headers));

      return Result.success(List.of(response.data['data'])
          .map((e) => Image.fromJson(e))
          .toList());
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<void, ApiError>> createPlaceReview(int placeId, double rating, bool wantsToRevisit, String? comment) async {
    try {
       await dio.post(
          '$remoteUrl/api/v1/places/$placeId/reviews',
          options: Options(headers: headers),
          data: {
            'rating': rating,
            'wantsToRevisit': wantsToRevisit,
            'comment' : comment
          });

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<Auth, ApiError>> googleSignIn(Profile profile, String idToken) async {
    try {
      final response = await dio.post(
          '$remoteUrl/api/v1/members/sign-in/google',
          options: Options(headers: headers),
          data: {
            'nickname': profile.name,
            'email': profile.email,
            'ageGroup': profile.ageGroup,
            'gender': profile.gender,
            'idToken': idToken
          });

      return Result.success(Auth.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }


  Future<Result<void, ApiError>> deleteAccount() async {
    try {
      await dio.delete('$remoteUrl/api/v1/members/',
          options: Options(headers: headers));

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

  Future<Result<void, ApiError>> deleteTravelVisit(int travelId, int visitId) async {
    try {
      await dio.delete('$remoteUrl/api/v1/travels/$travelId/visits/$visitId',
          options: Options(headers: headers));

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(ApiError.fromResponse(e.response));
    }
  }

}
