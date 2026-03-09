import 'package:equatable/equatable.dart';
import '../../models/listing_model.dart';

abstract class MyListingsEvent extends Equatable {
  const MyListingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyListings extends MyListingsEvent {
  final String userId;

  const LoadMyListings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class MyListingsUpdated extends MyListingsEvent {
  final List<ListingModel> listings;

  const MyListingsUpdated(this.listings);

  @override
  List<Object?> get props => [listings];
}

class AddMyListing extends MyListingsEvent {
  final ListingModel listing;

  const AddMyListing(this.listing);

  @override
  List<Object?> get props => [listing];
}

class UpdateMyListing extends MyListingsEvent {
  final ListingModel listing;

  const UpdateMyListing(this.listing);

  @override
  List<Object?> get props => [listing];
}

class DeleteMyListing extends MyListingsEvent {
  final String listingId;

  const DeleteMyListing(this.listingId);

  @override
  List<Object?> get props => [listingId];
}
