import 'package:flutter/material.dart';
import 'package:fooderlich/models/fooderlich_pages.dart';

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

        ///Chek if the user is creating a new grocery item
        if (groceryManager.isCreatingNewItem)
          //If so, shows the [GroceryItemScreen]
          GroceryItemScreen.page(
            /// When the user saves the item, it updates the grocery list
            onCreate: (item) {
              groceryManager.addItem(item);
            },
            //onUpdate only gets called when the user updates an existing item
            onUpdate: (item, index) {
              /// no update
            },
          ),

        /// [Edited Screen] Checks to see if a grocery item is selected
        if (groceryManager.selectedIndex != -1)
          //If so, then creates the Grocery Item screen page
          GroceryItemScreen.page(
            item: groceryManager.selectedGroceryItem,
            index: groceryManager.selectedIndex,

            /// [onCreate] only gets called when the user adds a new item
            onCreate: (_) {
              // no create
            },

            /// When the user changes and saves an item,
            ///  it updates the item at the current index
            onUpdate: (item, index) {
              groceryManager.updateItem(item, index);
            },
          ),

        ///This checks the profile manager to see if the user
        ///selected their profile, if so then it shows the [Profile Screen]
        if (profileManager.didSelectUser)
          ProfileScreen.page(profileManager.getUser),

        /// This checks if the user tapped the option to go to the
        /// websites, if so then it presents the [WebView] scree
        if (profileManager.didTapOnRaywenderlich) WebViewScreen.page(),
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

    /// Closes onboarding Guide when the user presses skip button
    if (route.settings.name == FooderlichPages.onboardingPath) {
      appStateManager.logout();
    }

    ///to ensure that the appropriate state is reset
    /// when the user taps the back button from the grocery item screen
    if (route.settings.name == FooderlichPages.groceryItemDetails) {
      groceryManager.groceryItemTapped(-1);
    }

    /// This checks to see if the route we are popping is indeed the profilePath
    /// Then tells the [profileManager] that the [Profile] screen
    /// is not visible anymore. Button [X] close function
    if (route.settings.name == FooderlichPages.profilePath) {
      profileManager.tapOnProfile(false);
    }

    /// Check if the name of the route setting is [raywenderlich],
    /// then it calls the appropriate method on [profileManager]
    if (route.settings.name == FooderlichPages.raywenderlich) {
      profileManager.tapOnRaywenderlich(false);
    }
    return true;
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;
}
