import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ListFeature {
  final String title;
  final String asset;

  ListFeature({required this.title, required this.asset});
}

class ListService {
  final String id;
  final String content;
  final String time;

  ListService({required this.id, required this.content, required this.time});
}

class Home2Page extends StatefulWidget {
  static const String route = '/home2';

  const Home2Page({super.key});

  @override
  State<Home2Page> createState() => _Home2State();
}

class _Home2State extends State<Home2Page> {
  final List<ListFeature> listFeature = [
    ListFeature(title: 'Check Rates', asset: 'assets/home/ic_check_rate.svg'),
    ListFeature(title: 'Nearby Drop', asset: 'assets/home/ic_nearby_drop.svg'),
    ListFeature(title: 'Order', asset: 'assets/home/ic_order.svg'),
    ListFeature(title: 'Help Center', asset: 'assets/home/ic_help.svg'),
    ListFeature(title: 'Wallet', asset: 'assets/home/ic_wallet.svg'),
    ListFeature(title: 'Others', asset: 'assets/home/ic_others.svg'),
  ];

  final List<ListService> listService = [
    ListService(
        id: 'MM09132005', content: 'Processed at sort facility', time: '2 Hrs'),
    ListService(
        id: 'MA84561259', content: 'Processed at sort facility', time: '2 Hrs'),
    ListService(
        id: 'FU84593276', content: 'Processed at sort facility', time: '2 Hrs'),
  ];

  @override
  Widget build(BuildContext context) {
    final TextEditingController controllerSearch = TextEditingController();

    final double screenWidth = MediaQuery.of(context).size.width;
    const imageBg = AssetImage('assets/home/bg_home.png');

    precacheImage(imageBg, context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: imageBg,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        SvgPicture.asset(
                          'assets/home/ic_notice.svg',
                          width: 50,
                          height: 50,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ]),
                      Container(
                        margin: const EdgeInsetsDirectional.only(
                            top: 30, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('My Balance',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 14,
                                            color: Color(0xFFA7A9B7))),
                                    Text('\$3.382.00',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black))
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 14),
                                child: Text('Top Up',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                        color: Colors.black)),
                              ),
                              SvgPicture.asset(
                                'assets/home/ic_add.svg',
                                width: 22,
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                    Colors.black, BlendMode.srcIn),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFD683D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: SvgPicture.asset(
                                'assets/home/ic_search.svg',
                                width: 30,
                                height: 30,
                                colorFilter: const ColorFilter.mode(
                                    Color(0xFF1D272F), BlendMode.srcIn),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: controllerSearch,
                                decoration: const InputDecoration(
                                    hintText: 'Enter track number',
                                    hintStyle: TextStyle(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF1D272F)),
                                    border: InputBorder.none),
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/home/ic_scan.svg',
                              width: 30,
                              height: 30,
                              colorFilter: const ColorFilter.mode(
                                  Colors.black, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 30, left: 24, bottom: 14),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Features',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14),
                    itemCount: listFeature.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = listFeature[index];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFF3F3F3),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              item.asset,
                              width: 50,
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 30, left: 24, bottom: 14),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'FeatServices and Productures',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 22, right: 22, bottom: 20),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: listService.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = listService[index];
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFF3F3F3),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFFF2F4F9),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/home/ic_package.svg',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.id,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        Text(
                                          item.content,
                                          style: const TextStyle(
                                              color: Color(0xFFA7A9B7),
                                              fontStyle: FontStyle.italic),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Text(item.time,
                                    style: const TextStyle(
                                        color: Color(0xFFA7A9B7),
                                        fontStyle: FontStyle.italic))
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
