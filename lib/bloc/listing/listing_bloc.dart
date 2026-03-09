import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/listing_model.dart';
import '../../services/listing_service.dart';
import 'listing_event.dart';
import 'listing_state.dart';

class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingService _listingService;
  StreamSubscription<List<ListingModel>>? _listingSubscription;

  ListingBloc({required ListingService listingService})
    : _listingService = listingService,
      super(const ListingState()) {
    on<LoadListings>(_onLoadListings);
    on<ListingsUpdated>(_onListingsUpdated);
    on<SearchListings>(_onSearchListings);
    on<FilterListingsByCategory>(_onFilterByCategory);
    on<AddListing>(_onAddListing);
    on<UpdateListing>(_onUpdateListing);
    on<DeleteListing>(_onDeleteListing);
    on<SelectListing>(_onSelectListing);
    on<ClearSelection>(_onClearSelection);
  }

  void _onLoadListings(LoadListings event, Emitter<ListingState> emit) {
    emit(state.copyWith(status: ListingStatus.loading));

    _listingSubscription?.cancel();
    _listingSubscription = _listingService.getListingsStream().listen(
      (listings) {
        add(ListingsUpdated(listings));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: ListingStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  void _onListingsUpdated(ListingsUpdated event, Emitter<ListingState> emit) {
    final filtered = _applyFilters(
      event.listings,
      state.searchQuery,
      state.selectedCategory,
    );
    emit(
      state.copyWith(
        status: ListingStatus.loaded,
        listings: event.listings,
        filteredListings: filtered,
      ),
    );
  }

  // Recompute filtered listings when search text changes.
  void _onSearchListings(SearchListings event, Emitter<ListingState> emit) {
    final filtered = _applyFilters(
      state.listings,
      event.query,
      state.selectedCategory,
    );
    emit(state.copyWith(searchQuery: event.query, filteredListings: filtered));
  }

  // Recompute filtered listings when category filter changes.
  void _onFilterByCategory(
    FilterListingsByCategory event,
    Emitter<ListingState> emit,
  ) {
    final filtered = _applyFilters(
      state.listings,
      state.searchQuery,
      event.category,
    );
    emit(
      state.copyWith(
        selectedCategory: event.category,
        filteredListings: filtered,
        clearCategory: event.category == null || event.category!.isEmpty,
      ),
    );
  }

  Future<void> _onAddListing(
    AddListing event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.addListing(event.listing);
    } catch (e) {
      emit(
        state.copyWith(status: ListingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateListing(
    UpdateListing event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.updateListing(event.listing);
    } catch (e) {
      emit(
        state.copyWith(status: ListingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteListing(
    DeleteListing event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.deleteListing(event.listingId);
    } catch (e) {
      emit(
        state.copyWith(status: ListingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onSelectListing(SelectListing event, Emitter<ListingState> emit) {
    emit(state.copyWith(selectedListing: event.listing));
  }

  void _onClearSelection(ClearSelection event, Emitter<ListingState> emit) {
    emit(state.copyWith(clearSelectedListing: true));
  }

  // Apply combined search + category filters to the current listing collection.
  List<ListingModel> _applyFilters(
    List<ListingModel> listings,
    String searchQuery,
    String? category,
  ) {
    var filtered = listings;

    // Apply category filter
    filtered = _listingService.filterByCategory(filtered, category);

    // Apply search filter
    filtered = _listingService.searchListings(filtered, searchQuery);

    return filtered;
  }

  @override
  Future<void> close() {
    _listingSubscription?.cancel();
    return super.close();
  }
}



