import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yeohaeng_ttukttak/domain/model/travel.dart';
import 'package:yeohaeng_ttukttak/presentation/bookmark/bookmark_event.dart';
import 'package:yeohaeng_ttukttak/presentation/bookmark/bookmark_view_model.dart';
import 'package:yeohaeng_ttukttak/presentation/main/main_event.dart';
import 'package:yeohaeng_ttukttak/presentation/main/main_view_model.dart';
import 'package:yeohaeng_ttukttak/presentation/travel/travel_page.dart';

class TravelListView extends StatefulWidget {
  final List<Travel> travels;

  const TravelListView({super.key, required this.travels});

  @override
  State<TravelListView> createState() => _TravelListViewState();
}

class _TravelListViewState extends State<TravelListView> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    Future.microtask(() {
      final viewModel = context.read<MainViewModel>();

      _controller.addListener(() {
        bool canScrollUp = _controller.offset > 0;
        viewModel.onEvent(MainEvent.setCanViewScrollUp(canScrollUp));
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    final state = viewModel.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!state.isExpanded)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 24, bottom: 12),
              width: 25,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        if (state.isExpanded) const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            controller: _controller,
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 20.0),
            itemBuilder: (BuildContext context, int index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TravelWidget(
                  travel: widget.travels[index], width: double.maxFinite),
            ),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 20),
            itemCount: widget.travels.length,
          ),
        ),
      ],
    );
  }
}

class TravelWidget extends StatelessWidget {
  final Travel travel;
  double _width;

  TravelWidget({super.key, required width, required this.travel})
      : _width = width;

  @override
  Widget build(BuildContext context) {
    TextStyle? titleLarge = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: Colors.white, fontSize: 20);
    TextStyle? bodyMedium =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white);

    final bookmarkViewModel = context.watch<BookmarkViewModel>();
    bool isBookmarked = bookmarkViewModel.state.travelIdSet.contains(travel.id);


    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TravelPage(travel: travel)));
      },
      child: Container(
        width: _width,
        height: 240,
        constraints: const BoxConstraints(maxWidth: 480),
        child: Stack(
          children: [
            Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                        image: NetworkImage(travel.thumbnail!.medium),
                        fit: BoxFit.cover))),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.75),
                    ]),
              ),
            ),
            Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travel.name,
                      style: titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: travel.nickname,
                                style: bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    " · ${travel.ageGroup!.label} · ${travel.transport!.label}")
                          ])),
                        ),
                        IconButton(
                          onPressed: isBookmarked
                              ? () => bookmarkViewModel
                                  .onEvent(BookmarkEvent.deleteTravel(travel))
                              : () => bookmarkViewModel
                                  .onEvent(BookmarkEvent.addTravel(travel)),
                          icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
