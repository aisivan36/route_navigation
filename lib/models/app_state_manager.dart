import 'dart:async';
import 'package:flutter/material.dart';

/// Contstant for each tab the user taps
class FooderlichTab {
  static const int explore = 0;
  static const int recipes = 1;
  static const int toBuy = 2;
}

class AppStateManager extends ChangeNotifier {
  /// [_initialized] checks if the app is initialized
  bool _initialized = false;

  /// [_loggedIn] lets us check if the user has logged in
  bool _loggedIn = false;

  /// [_onBoardingComplete] checks if the user completed the onboarding flow
  bool _onBoardingComplete = false;

  /// [_selectedTab] keeps track of which tab the user is on
  int _selectedTab = FooderlichTab.explore;

  ///  ===========================
  /// These are getter methods for each property.
  /// We cannot change these properties
  /// outside AppStateManager. This is important for the unidirectional flow
  /// architecture, where we don’t change state directly but only via function
  /// calls ordispatched events
  bool get isInitialized => _initialized;
  bool get isLoggedIn => _loggedIn;
  bool get isOnboardingComplete => _onBoardingComplete;
  int get getSelectedTab => _selectedTab;

  void initializeApp() {
    Timer(
      const Duration(milliseconds: 2000),
      () {
        _initialized = true; // sets initialized to true
        notifyListeners(); //Notifies listener
      },
    );
  }

  void login(String username, String password) {
    _loggedIn = true; // sets [_loggedIn] to true
    notifyListeners(); //Notifies listener
  }

  void completedOnboarding() {
    _onBoardingComplete = true; // sets [_onBoardingComplete] to true
    notifyListeners(); //Notifies listener
  }

  void goToTab(index) {
    // sets the index of [_selectedTab] and notifies all listener
    _selectedTab = index;
    notifyListeners(); //Notifies listener
  }

  void goToRecipes() {
    // helper method that goes straight to the recipes
    _selectedTab = FooderlichTab.recipes;
    notifyListeners();
  }

  /// When the user presses [logout]
  /// it Restes all the app state properties
  /// it re-initializes the app
  /// it notifies all listener of state change
  void logout() {
    _loggedIn = false;
    _onBoardingComplete = false;
    _initialized = false;
    _selectedTab = 0;

    initializeApp();
    notifyListeners();
  }
}
