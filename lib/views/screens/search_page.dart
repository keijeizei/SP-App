import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amethyst/models/core/receipt.dart';
import 'package:amethyst/models/helper/db_helper.dart';
import 'package:amethyst/views/utils/AppColor.dart';
import 'package:amethyst/views/widgets/modals/search_filter_modal.dart';
import 'package:amethyst/views/widgets/receipt_tile.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchInputController = TextEditingController();
  late Future<List<Receipt>> searchResult;

  int sortMode = 0; // newest, oldest, cheapest, most expensive

  DBHelper db = DBHelper();

  @override
  void initState() {
    super.initState();

    searchResult = db.getReceipts();
  }

  void updateSortMode(int mode) async {
    List<Receipt> presentSearchResult = await searchResult;
    if (mode == 0) {
      presentSearchResult.sort((a, b) => b.title.compareTo(a.title));
    }
    if (mode == 1) {
      presentSearchResult.sort((a, b) => a.title.compareTo(b.title));
    }
    if (mode == 2) {
      presentSearchResult.sort((a, b) => b.date.compareTo(a.date));
    }
    if (mode == 3) {
      presentSearchResult.sort((a, b) => a.date.compareTo(b.date));
    }
    if (mode == 4) {
      presentSearchResult.sort((a, b) => a.price.compareTo(b.price));
    }
    if (mode == 5) {
      presentSearchResult.sort((a, b) => b.price.compareTo(a.price));
    }
    setState(() {
      searchResult = Future.value(presentSearchResult);
      sortMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(searchInputController.text.isEmpty);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text('Search Receipt',
            style: TextStyle(
                fontFamily: 'inter',
                fontWeight: FontWeight.w400,
                fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          // Section 1 - Search
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80,
            color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search TextField
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.primarySoft),
                          child: TextField(
                            controller: searchInputController,
                            autofocus: true,
                            onChanged: (value) {
                              setState(() {});
                            },
                            onSubmitted: (value) {
                              print(value);
                              setState(() {
                                searchResult = db.searchReceipts(value);
                                updateSortMode(sortMode);
                              });
                            },
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            maxLines: 1,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.2)),
                              prefixIconConstraints:
                                  const BoxConstraints(maxHeight: 20),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 17),
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              prefixIcon: Visibility(
                                visible: true,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 12),
                                  child: SvgPicture.asset(
                                    'assets/icons/search.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Filter Button
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              builder: (context) {
                                return SearchFilterModal(
                                    sortMode: sortMode,
                                    updateSortMode: updateSortMode);
                              });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColor.secondary,
                          ),
                          child: SvgPicture.asset('assets/icons/filter.svg'),
                        ),
                      )
                    ],
                  ),
                ),
                // Search Keyword Recommendation
                // Container(
                //   height: 60,
                //   margin: EdgeInsets.only(top: 8),
                //   child: ListView.separated(
                //     shrinkWrap: true,
                //     scrollDirection: Axis.horizontal,
                //     physics: BouncingScrollPhysics(),
                //     padding: EdgeInsets.symmetric(horizontal: 16),
                //     itemCount: popularReceiptKeyword.length,
                //     separatorBuilder: (context, index) {
                //       return SizedBox(width: 8);
                //     },
                //     itemBuilder: (context, index) {
                //       return Container(
                //         alignment: Alignment.topCenter,
                //         child: TextButton(
                //           onPressed: () {
                //             searchInputController.text = popularReceiptKeyword[index];
                //           },
                //           child: Text(
                //             popularReceiptKeyword[index],
                //             style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w400),
                //           ),
                //           style: OutlinedButton.styleFrom(
                //             side: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // )
              ],
            ),
          ),
          // Section 2 - Search Result
          FutureBuilder(
              future: searchResult,
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: const Text(
                            'Search results',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            return ReceiptTile(
                              data: snapshot.data[index],
                              refreshDB: () {},
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}
