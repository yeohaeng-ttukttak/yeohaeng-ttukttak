import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yeohaeng_ttukttak/domain/model/place.dart';
import 'package:yeohaeng_ttukttak/presentation/search/search_event.dart';
import 'package:yeohaeng_ttukttak/presentation/search/search_view_model.dart';

class Search extends SearchDelegate<Place?> {
  StreamSubscription? _subscription;

  @override
  void close(BuildContext context, Place? result) {
    query = '';
    _subscription?.cancel();

    super.close(context, result);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return theme.copyWith(
        hintColor: Colors.red,
        navigationBarTheme: theme.navigationBarTheme.copyWith(),
        textTheme: theme.textTheme
            .copyWith(titleLarge: theme.textTheme.bodyLarge // query Color
                ),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            hintStyle: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.outline),
            fillColor: theme.colorScheme.surface,
            filled: true,
            isDense: true,
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline))),
        appBarTheme: theme.appBarTheme
            .copyWith(titleSpacing: 0, scrolledUnderElevation: 0));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) {
      return <Widget>[const SizedBox(width: 48)];
    }

    final viewModel = context.read<SearchViewModel>();

    return <Widget>[
      IconButton(
          onPressed: () {
            query = '';
            viewModel.onEvent(const SearchEvent.initState());
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    final viewModel = context.read<SearchViewModel>();
    final places = viewModel.state.places;

    return ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(places[index].name),
            subtitle: Text(places[index].localAddr),
            leading: const Icon(Icons.place_outlined),
            onTap: () {
              viewModel.onEvent(SearchEvent.search(places[index]));
            },
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final viewModel = context.watch<SearchViewModel>();
    final places =
        query.isEmpty ? viewModel.state.history : viewModel.state.places;
    viewModel.onEvent(SearchEvent.autoComplete(query));

    _subscription ??= context.read<SearchViewModel>().stream.listen((event) =>
        event.when(searchComplete: (place) => close(context, place)));


    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(places[index].name),
          subtitle: Text(places[index].roadAddr),
          leading: query.isEmpty
              ? const Icon(Icons.access_time)
              : const Icon(Icons.place_outlined),
          trailing: query.isEmpty
              ? IconButton(
                  onPressed: () => viewModel
                      .onEvent(SearchEvent.deleteHistory(places[index])),
                  icon: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error))
              : null,
          onTap: () {
            viewModel.onEvent(SearchEvent.search(places[index]));
          },
        );
      },
    );
  }
}
