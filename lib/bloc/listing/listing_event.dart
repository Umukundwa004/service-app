import 'package:equatable/equatable.dart';
import '../../models/listing_model.dart';

abstract class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object?> get props => [];
}

class LoadListings extends ListingEvent {
  const LoadListings();
}

class ListingsUpdated extends ListingEvent {
  final List<ListingModel> listings;

  const ListingsUpdated(this.listings);

  @override
  List<Object?> get props => [listings];
}

// Event fired when user changes search query.
class SearchListings extends ListingEvent {
  final String query;

  const SearchListings(this.query);

  @override
  List<Object?> get props => [query];
}

// Event fired when user applies or clears category filter.
class FilterListingsByCategory extends ListingEvent {
  final String? category;

  const FilterListingsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class AddListing extends ListingEvent {
  final ListingModel listing;

  const AddListing(this.listing);

  @override
  List<Object?> get props => [listing];
}

class UpdateListing extends ListingEvent {
  final ListingModel listing;

  const UpdateListing(this.listing);

  @override
  List<Object?> get props => [listing];
}

class DeleteListing extends ListingEvent {
  final String listingId;

  const DeleteListing(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

class SelectListing extends ListingEvent {
  final ListingModel listing;

  const SelectListing(this.listing);

  @override
  List<Object?> get props => [listing];
}

class ClearSelection extends ListingEvent {
  const ClearSelection();
}


