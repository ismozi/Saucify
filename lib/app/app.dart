    import 'package:stacked/stacked_annotations.dart';
    import 'package:saucify/services/spotifyService.dart';
    @StackedApp(
     dependencies: [
      LazySingleton(classType: spotifyService),
     ],
    )
    class AppSetup {}