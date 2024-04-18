import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:yeohaeng_ttukttak/data/datasource/remote_api.dart';
import 'package:yeohaeng_ttukttak/data/datasource/secure_storage.dart';
import 'package:yeohaeng_ttukttak/domain/model/auth.dart';
import 'package:yeohaeng_ttukttak/domain/model/member.dart';
import 'package:yeohaeng_ttukttak/utils/api_result.dart';

class MemberRepository {
  final String remoteUrl = const String.fromEnvironment("REMOTE_URL");

  final RemoteAPI api;

  final SecureStorage secureStorage;

  MemberRepository(this.api, this.secureStorage);

  Future<ApiResult<Auth>> signIn(String email, String password) async {
    final uri = Uri.http(remoteUrl, '/api/v1/members/sign-in');
    final headers = {
      'Content-type': 'application/json; charset=UTF-8',
      'Accept-Language': 'ko'
    };

    final body = jsonEncode({'email': email, 'password': password});

    final response = await post(uri, headers: headers, body: body);
    Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != HttpStatus.ok) {
      return const ApiResult.unhandledError('서버와 통신 중 에러가 발생했습니다.');
    }

    return ApiResult.fromJson(json, Auth.fromJson);
  }

  Future<ApiResult<Member>> signUp(
      String email, String password, String nickname) async {
    final uri = Uri.http(remoteUrl, '/api/v1/members/sign-up');
    final headers = {
      'Content-type': 'application/json; charset=UTF-8',
      'Accept-Language': 'ko'
    };

    final body = jsonEncode(
        {'email': email, 'password': password, 'nickname': nickname});

    final response = await post(uri, headers: headers, body: body);
    Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != HttpStatus.created &&
        response.statusCode != HttpStatus.ok) {
      return const ApiResult.unhandledError('서버와 통신 중 에러가 발생했습니다.');
    }

    return ApiResult.fromJson(json, Member.fromJson);
  }

  Future<ApiResult<Member>> findProfile() async {
    // 1. 인증 정보가 저장 되었는지 조회
    final result = await secureStorage.findAuth();

    return result.when(
        success: (auth) async {
          // 2-1. 성공 시 저장된 인증 정보로 요청
          final result = await api.findProfile(auth);

          return result.when(
              // 3-1. 성공
              success: (member) => ApiResult.success(member),
              error: (_) async {
                // 3-2. 인증 정보 만료 시, Access Token 재발급 시도
                final result = await api.renewAuth(auth.refreshToken);

                return result.when(
                    // 4-1. 재발급 성공, 발급된 인증 정보로 재 요청
                    success: (auth) async => api.findProfile(auth),
                    // 4-2. 재발급 실패 시, Refresh Token 만료로 재 로그인
                    error: (_) => const ApiResult.unhandledError(
                        '인증 정보가 만료되었습니다. 다시 로그인해 주세요.'),
                    // 4-3. 서버 통신 실패 시 메세지 반환
                    unhandledError: (message) =>
                        ApiResult.unhandledError(message));
              },
              // 3-3. 서버 통신 실패 시 메세지 반환
              unhandledError: (message) => ApiResult.unhandledError(message));
        },
        error: (_) =>
            // 2-2. 저장된 인증 정보가 없는 경우 재 로그인
            const ApiResult.unhandledError('인증 정보가 만료되었습니다. 다시 로그인해 주세요.'));
  }
}
