// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AdminHomePage]
class AdminHomeRoute extends PageRouteInfo<void> {
  const AdminHomeRoute({List<PageRouteInfo>? children})
    : super(AdminHomeRoute.name, initialChildren: children);

  static const String name = 'AdminHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminHomePage();
    },
  );
}

/// generated route for
/// [BootstrapPage]
class BootstrapRoute extends PageRouteInfo<void> {
  const BootstrapRoute({List<PageRouteInfo>? children})
    : super(BootstrapRoute.name, initialChildren: children);

  static const String name = 'BootstrapRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BootstrapPage();
    },
  );
}

/// generated route for
/// [CategoriesPage]
class CategoriesRoute extends PageRouteInfo<void> {
  const CategoriesRoute({List<PageRouteInfo>? children})
    : super(CategoriesRoute.name, initialChildren: children);

  static const String name = 'CategoriesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategoriesPage();
    },
  );
}

/// generated route for
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [MainHomePage]
class MainHomeRoute extends PageRouteInfo<void> {
  const MainHomeRoute({List<PageRouteInfo>? children})
    : super(MainHomeRoute.name, initialChildren: children);

  static const String name = 'MainHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainHomePage();
    },
  );
}

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
/// [SignInPage]
class SignInRoute extends PageRouteInfo<SignInRouteArgs> {
  SignInRoute({Key? key, String? infoMessage, List<PageRouteInfo>? children})
    : super(
        SignInRoute.name,
        args: SignInRouteArgs(key: key, infoMessage: infoMessage),
        initialChildren: children,
      );

  static const String name = 'SignInRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignInRouteArgs>(
        orElse: () => const SignInRouteArgs(),
      );
      return SignInPage(key: args.key, infoMessage: args.infoMessage);
    },
  );
}

class SignInRouteArgs {
  const SignInRouteArgs({this.key, this.infoMessage});

  final Key? key;

  final String? infoMessage;

  @override
  String toString() {
    return 'SignInRouteArgs{key: $key, infoMessage: $infoMessage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignInRouteArgs) return false;
    return key == other.key && infoMessage == other.infoMessage;
  }

  @override
  int get hashCode => key.hashCode ^ infoMessage.hashCode;
}

/// generated route for
/// [SignUpPage]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpPage();
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

/// generated route for
/// [VerifyEmailPage]
class VerifyEmailRoute extends PageRouteInfo<VerifyEmailRouteArgs> {
  VerifyEmailRoute({
    Key? key,
    required String email,
    required String password,
    List<PageRouteInfo>? children,
  }) : super(
         VerifyEmailRoute.name,
         args: VerifyEmailRouteArgs(key: key, email: email, password: password),
         initialChildren: children,
       );

  static const String name = 'VerifyEmailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerifyEmailRouteArgs>();
      return VerifyEmailPage(
        key: args.key,
        email: args.email,
        password: args.password,
      );
    },
  );
}

class VerifyEmailRouteArgs {
  const VerifyEmailRouteArgs({
    this.key,
    required this.email,
    required this.password,
  });

  final Key? key;

  final String email;

  final String password;

  @override
  String toString() {
    return 'VerifyEmailRouteArgs{key: $key, email: $email, password: $password}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VerifyEmailRouteArgs) return false;
    return key == other.key &&
        email == other.email &&
        password == other.password;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode ^ password.hashCode;
}
