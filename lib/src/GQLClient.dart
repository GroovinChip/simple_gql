/*
 * File Created: 2020-05-27 16:11
 * Author: Alban LECUIVRE
 * Copyright - 2020 Alban LECUIVRE
 */

part of simple_gql;

class GQLClient {
  final String _url;
  Map<String, String> _headers;

  GQLClient({@required String url, Map<String, String> headers})
      : _url = url,
        _headers = headers ?? {};

  /// Method to set the headers used in the futures queries/mutations
  /// [headers] Headers that you want to set
  ///
  /// ```dart
  /// // Example
  /// client.setHeaders({'Authorization': 'Bearer $token'});
  /// ```
  void setHeaders(Map<String, String> headers) {
    _headers = headers;
  }

  Map<String,String> get headers => _headers;
  
  /// GQL Query using the Dart Http package
  /// [url] is your gql endpoint.
  ///
  /// [query] is your String query.
  ///
  /// [variables] is the map of variables if your query need variables.
  ///
  /// [headers] if you want to tweaks the request's headers.
  ///
  /// Example
  /// ```dart
  /// import 'package:simple_gql/simple_gql.dart';
  ///
  /// final response = await GQLClient(
  ///   url: 'https://your_gql_endpoint',
  /// ).query(
  ///   query: r'''
  ///     query PostsForAuthor($id: Int!) {
  ///       author(id: $id) {
  ///          firstName
  ///         posts {
  ///           title
  ///           votes
  ///         }
  ///       }
  ///     }
  ///   ''',
  ///   variables: { 'id': 1 }
  /// );
  /// ```
  Future<GQLResponse> query(
      {@required String query,
      Map<String, dynamic> variables,
      Map<String, String> headers}) async {
    try {
      return await post(_url,
              headers: (headers ?? _headers)
                ..putIfAbsent('content-type', () => 'application/json'),
              body: jsonEncode({'query': query, 'variables': variables}))
          .then((res) {
        final body = jsonDecode(res.body);
        if ((body['errors'] as List)?.isNotEmpty ?? false) {
          throw GQLError._getErrors(body['errors']);
        }
        return GQLResponse(data: body['data']);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// GQL Mutation using the Dart Http package
  /// [url] is your gql endpoint.
  ///
  /// [query] is your String query.
  ///
  /// [variables] is the map of variables if your query need variables.
  ///
  /// [headers] if you want to tweaks the request's headers.
  ///
  /// Example
  /// ```dart
  /// import 'package:simple_gql/simple_gql.dart';
  ///
  /// final response = await GQLClient(
  ///   url: 'https://your_gql_endpoint',
  /// ).mutation(
  ///   mutation: r'''
  ///     mutation CreateMessage($input: String) {
  ///       createMessage(input: $input) {
  ///         id
  ///       }
  ///     }
  ///   ''',
  ///   variables: { 'input': 'message' }
  /// );
  /// ```
  Future<GQLResponse> mutation(
      {@required String mutation,
      Map<String, dynamic> variables,
      Map<String, String> headers}) async {
    try {
      return await post(_url,
              headers: (headers ?? _headers)
                ..putIfAbsent('content-type', () => 'application/json')
                ..putIfAbsent('accept', () => 'application/json'),
              body: jsonEncode({'query': mutation, 'variables': variables}))
          .then((res) {
        final body = jsonDecode(res.body);
        if ((body['errors'] as List)?.isNotEmpty ?? false) {
          throw GQLError._getErrors(body['errors']);
        }
        return GQLResponse(data: body['data']);
      });
    } catch (e) {
      rethrow;
    }
  }
}
