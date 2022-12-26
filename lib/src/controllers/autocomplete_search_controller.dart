import 'package:flutter/cupertino.dart';
import '../autocomplete_search.dart';

class SearchBarController extends ChangeNotifier {
  late AutoCompleteSearchBarState _autoCompleteSearch;

  attach(AutoCompleteSearchBarState searchWidget) {
    _autoCompleteSearch = searchWidget;
  }

  /// Just clears text.
  clear() {
    _autoCompleteSearch.clearText();
  }

  /// Clear and remove focus (Dismiss keyboard)
  reset() {
    _autoCompleteSearch.resetSearchBar();
  }

  clearOverlay() {
    _autoCompleteSearch.clearOverlay();
  }
}
