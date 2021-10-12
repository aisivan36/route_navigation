import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/screens.dart';

/// it extens RouterDelegate The system will tell the router to build
/// and configure a navigator widget
class AppRouter extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  /// Declares [GlobalKey] a unique key across the entire app
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  /// Declares [AppStateManager] the router will listen to app state changes
  /// to configure the navigator's list of pages
  final AppStateManager appStateManager;

  /// Declares [GroceryManager] to listen to the user's state when we create
  /// or edit an item
  final GroceryManager groceryManager;

  /// Declares [ProfileManager] to listen to the user profile state
  final ProfileManager profileManager;

  AppRouter({
    required this.appStateManager,
    required this.groceryManager,
    required this.profileManager,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    /// [appStateManager] determines the state of the app.
    /// it manages thether the app initialized login
    /// and if the user completed the onborading
    appStateManager.addListener(notifyListeners);

    /// [groceryManager] manages the list of grocery
    ///  items and the item selection state
    groceryManager.addListener(notifyListeners);

    /// [profileManager] manages the user's profile and settings
    profileManager.addListener(notifyListeners);
  }

  ///Note that! When we [dispose] the [router] we must [remove] [all] [listener]
  ///[Forggeting] to do this will throw an exception.
  @override
  void dispose() {
    appStateManager.removeListener(notifyListeners);
    groceryManager.removeListener(notifyListeners);
    profileManager.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,

      ///It's called every time a page pops from the stack
      onPopPage: _handlePopPage,

      /// Navigation stack
      pages: [
        /// Check if the app is initialized. If it's not we show the SplasScreen
        if (!appStateManager.isInitialized) SplashScreen.page(),

        /// If the app initialized and the user hans't logged in,
        /// it should show the login page
        if (appStateManager.isInitialized && !appStateManager.isLoggedIn)
          LoginScreen.page(),

        ///If the user is loggedin but hasn't completed the Onboarding Guide yet
        if (appStateManager.isLoggedIn && !appStateManager.isOnboardingComplete)
          OnboardingScreen.page(),

        ///it tells the app to show the home page
        ///only when the user completes [Onboarding]
        if (appStateManager.isOnboardingComplete)
          Home.page(appStateManager.getSelectedTab),
// TODO: Create new item
// TODO: Select GroceryItemScreen
// TODO: Add Profile Screen
// TODO: Add WebView Screen
      ],
    );
  }

  /// When the user taps the Back button or triggers a system back button event,
  /// it fires a helper method, [onPopPage]
  bool _handlePopPage(Route<dynamic> route, result) {
    /// Check if the current route's pop succeeded
    if (!route.didPop(result)) {
      return false;
    }
    if (route.settings.name == FooderlichPages.onboardingPath) {
      appStateManager.logout();
    }
// TODO: Handle state when user closes grocery item screen
// TODO: Handle state when user closes profile screen
// TODO: Handle state when user closes WebView scree
    return true;
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;
}
