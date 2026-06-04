import 'package:derpiviewer/core/data/datasources/strategies/booru_api_strategy.dart';
import 'package:derpiviewer/core/data/datasources/strategies/philomena_v1_strategy.dart';
import 'package:derpiviewer/core/data/datasources/strategies/philomena_v3_strategy.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';

/// Factory that maps a [Booru] enum value to its corresponding [BooruApiStrategy].
///
/// Eliminates the need for booru-specific `if`/`switch` branching in client code.
/// Every [Booru] value is exhaustively mapped — the compiler enforces this.
class BooruApiStrategyFactory {
  BooruApiStrategyFactory._();

  /// Returns the correct [BooruApiStrategy] for a given [Booru].
  ///
  /// The [host] parameter allows callers to provide the booru's host string
  /// (from booru_config.dart) at the call site, keeping this factory host-agnostic.
  static BooruApiStrategy create(Booru booru, String host) {
    switch (booru) {
      case Booru.twi:
        return PhilomenaV3Strategy(host, booru);
      case Booru.derpi:
      case Booru.trixie:
      case Booru.pony:
      case Booru.fur:
      case Booru.ponerpics:
      case Booru.mane:
        return PhilomenaV1Strategy(host, booru);
    }
  }
}
