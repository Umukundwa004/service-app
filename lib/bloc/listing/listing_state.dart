import 'package:equatable/equatable.dart';
import '../../models/listing_model.dart';

enum ListingStatus { initial, loading, loaded, error }

class ListingState extends Equatable {
  final ListingStatus status;
  final List<ListingModel> listings;
  final List<ListingModel> filteredListings;
  final String searchQuery;
  final String? selectedCategory;
  final ListingModel? selectedListing;
  final String? errorMessage;

  const ListingState({
    this.status = ListingStatus.initial,
    this.listings = const [],
    this.filteredListings = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedListing,
    this.errorMessage,
  });

  ListingState copyWith({
    ListingStatus? status,
    List<ListingModel>? listings,
    List<ListingModel>? filteredListings,
    String? searchQuery,
    String? selectedCategory,
    ListingModel? selectedListing,
    String? errorMessage,
    bool clearSelectedListing = false,
    bool clearCategory = false,
  }) {
    return ListingState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      filteredListings: filteredListings ?? this.filteredListings,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedListing: clearSelectedListing
          ? null
          : (selectedListing ?? this.selectedListing),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    listings,
    filteredListings,
    searchQuery,
    selectedCategory,
    selectedListing,
    errorMessage,
  ];
}
