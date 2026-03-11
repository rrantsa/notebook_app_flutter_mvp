enum BookletPageSide {
  front,
  back,
}

class BookletSpread {
  final int sheetNumber;
  final BookletPageSide side;
  final int? leftPage;
  final int? rightPage;

  const BookletSpread({
    required this.sheetNumber,
    required this.side,
    required this.leftPage,
    required this.rightPage,
  });
}

class BookletImpositionResult {
  final int originalPageCount;
  final int paddedPageCount;
  final int blankPageCount;
  final int sheetCount;
  final List<int?> imposedOrder;
  final List<BookletSpread> spreads;

  const BookletImpositionResult({
    required this.originalPageCount,
    required this.paddedPageCount,
    required this.blankPageCount,
    required this.sheetCount,
    required this.imposedOrder,
    required this.spreads,
  });
}

class BookletImposition {
  const BookletImposition._();

  static BookletImpositionResult build(int originalPageCount) {
    if (originalPageCount <= 0) {
      return const BookletImpositionResult(
        originalPageCount: 0,
        paddedPageCount: 0,
        blankPageCount: 0,
        sheetCount: 0,
        imposedOrder: [],
        spreads: [],
      );
    }

    final paddedPageCount = _padToMultipleOf4(originalPageCount);
    final blankPageCount = paddedPageCount - originalPageCount;
    final sheetCount = paddedPageCount ~/ 4;

    final spreads = <BookletSpread>[];
    final imposedOrder = <int?>[];

    int low = 1;
    int high = paddedPageCount;

    for (int sheet = 1; sheet <= sheetCount; sheet++) {
      final frontLeft = _pageOrBlank(high, originalPageCount);
      final frontRight = _pageOrBlank(low, originalPageCount);

      final backLeft = _pageOrBlank(low + 1, originalPageCount);
      final backRight = _pageOrBlank(high - 1, originalPageCount);

      final frontSpread = BookletSpread(
        sheetNumber: sheet,
        side: BookletPageSide.front,
        leftPage: frontLeft,
        rightPage: frontRight,
      );

      final backSpread = BookletSpread(
        sheetNumber: sheet,
        side: BookletPageSide.back,
        leftPage: backLeft,
        rightPage: backRight,
      );

      spreads.add(frontSpread);
      spreads.add(backSpread);

      imposedOrder
        ..add(frontLeft)
        ..add(frontRight)
        ..add(backLeft)
        ..add(backRight);

      low += 2;
      high -= 2;
    }

    return BookletImpositionResult(
      originalPageCount: originalPageCount,
      paddedPageCount: paddedPageCount,
      blankPageCount: blankPageCount,
      sheetCount: sheetCount,
      imposedOrder: imposedOrder,
      spreads: spreads,
    );
  }

  static int _padToMultipleOf4(int pageCount) {
    final remainder = pageCount % 4;
    if (remainder == 0) return pageCount;
    return pageCount + (4 - remainder);
  }

  static int? _pageOrBlank(int pageNumber, int originalPageCount) {
    if (pageNumber > originalPageCount) return null;
    return pageNumber;
  }
}