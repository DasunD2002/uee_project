Map<String, dynamic> provinceFixture({
  String id = 'uva',
  String name = 'Uva Province',
  int page = 0,
  bool hasNext = false,
  bool empty = false,
  bool images = false,
}) => {
  'province': {
    'id': id,
    'name': name,
    'description': 'Province of Sri Lanka',
    'capital': 'Badulla',
    'districts': ['Badulla District', 'Monaragala District'],
    'imageUrl': images
        ? 'https://commons.wikimedia.org/wiki/Special:FilePath/Test.jpg'
        : null,
    'imageSourceUrl': 'https://commons.wikimedia.org/wiki/File:Test.jpg',
    'sourceUrl': 'https://www.wikidata.org/wiki/Q876293',
  },
  'places': {
    'items': [
      if (!empty)
        {
          'id': 'Q${100 + page}',
          'name': 'Heritage Site ${page + 1}',
          'subtitle': 'Badulla District, Sri Lanka',
          'category': 'Sacred Sites',
          'categoryId': 'sacred-sites',
          'location': {'latitude': 6.98, 'longitude': 81.06},
          'description': 'A documented temple',
          'imageUrl': images
              ? 'https://commons.wikimedia.org/wiki/Special:FilePath/Temple.jpg'
              : null,
          'sourceUrl': 'https://www.wikidata.org/wiki/Q${100 + page}',
        },
    ],
    'page': page,
    'size': 10,
    'total': empty ? 0 : 2,
    'hasNext': hasNext,
    'source': 'Wikidata',
    'fetchedAt': '2026-09-12T00:00:00Z',
    'stale': false,
    'truncated': false,
  },
  'traditions': [
    if (!empty)
      {
        'id': 'Q400',
        'name': 'Regional Festival',
        'description': 'A documented regional tradition',
        'sourceUrl': 'https://www.wikidata.org/wiki/Q400',
      },
  ],
};
