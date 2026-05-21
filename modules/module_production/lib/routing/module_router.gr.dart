// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'module_router.dart';

/// generated route for
/// [ProductionHomePage]
class ProductionHomeRoute extends PageRouteInfo<void> {
  const ProductionHomeRoute({List<PageRouteInfo>? children})
    : super(ProductionHomeRoute.name, initialChildren: children);

  static const String name = 'ProductionHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProductionHomePage();
    },
  );
}

/// generated route for
/// [RaporlamaPage]
class RaporlamaRoute extends PageRouteInfo<void> {
  const RaporlamaRoute({List<PageRouteInfo>? children})
    : super(RaporlamaRoute.name, initialChildren: children);

  static const String name = 'RaporlamaRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RaporlamaPage();
    },
  );
}

/// generated route for
/// [SiparisListesiPage]
class SiparisListesiRoute extends PageRouteInfo<void> {
  const SiparisListesiRoute({List<PageRouteInfo>? children})
    : super(SiparisListesiRoute.name, initialChildren: children);

  static const String name = 'SiparisListesiRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SiparisListesiPage();
    },
  );
}

/// generated route for
/// [TumHareketlerPage]
class TumHareketlerRoute extends PageRouteInfo<TumHareketlerRouteArgs> {
  TumHareketlerRoute({
    Key? key,
    required String productId,
    List<PageRouteInfo>? children,
  }) : super(
         TumHareketlerRoute.name,
         args: TumHareketlerRouteArgs(key: key, productId: productId),
         rawPathParams: {'productId': productId},
         initialChildren: children,
       );

  static const String name = 'TumHareketlerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TumHareketlerRouteArgs>(
        orElse: () => TumHareketlerRouteArgs(
          productId: pathParams.getString('productId'),
        ),
      );
      return TumHareketlerPage(key: args.key, productId: args.productId);
    },
  );
}

class TumHareketlerRouteArgs {
  const TumHareketlerRouteArgs({this.key, required this.productId});

  final Key? key;

  final String productId;

  @override
  String toString() {
    return 'TumHareketlerRouteArgs{key: $key, productId: $productId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TumHareketlerRouteArgs) return false;
    return key == other.key && productId == other.productId;
  }

  @override
  int get hashCode => key.hashCode ^ productId.hashCode;
}

/// generated route for
/// [UrunDetayiPage]
class UrunDetayiRoute extends PageRouteInfo<UrunDetayiRouteArgs> {
  UrunDetayiRoute({
    Key? key,
    required String productId,
    List<PageRouteInfo>? children,
  }) : super(
         UrunDetayiRoute.name,
         args: UrunDetayiRouteArgs(key: key, productId: productId),
         rawPathParams: {'productId': productId},
         initialChildren: children,
       );

  static const String name = 'UrunDetayiRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<UrunDetayiRouteArgs>(
        orElse: () =>
            UrunDetayiRouteArgs(productId: pathParams.getString('productId')),
      );
      return UrunDetayiPage(key: args.key, productId: args.productId);
    },
  );
}

class UrunDetayiRouteArgs {
  const UrunDetayiRouteArgs({this.key, required this.productId});

  final Key? key;

  final String productId;

  @override
  String toString() {
    return 'UrunDetayiRouteArgs{key: $key, productId: $productId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UrunDetayiRouteArgs) return false;
    return key == other.key && productId == other.productId;
  }

  @override
  int get hashCode => key.hashCode ^ productId.hashCode;
}

/// generated route for
/// [UrunYonetimiPage]
class UrunYonetimiRoute extends PageRouteInfo<void> {
  const UrunYonetimiRoute({List<PageRouteInfo>? children})
    : super(UrunYonetimiRoute.name, initialChildren: children);

  static const String name = 'UrunYonetimiRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UrunYonetimiPage();
    },
  );
}
