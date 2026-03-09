import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/listing_model.dart';
import '../../services/listing_service.dart';
import 'my_listings_event.dart';
import 'my_listings_state.dart';

class MyListingsBloc extends Bloc<MyListingsEvent, MyListingsState> {
  final ListingService _listingService;
  StreamSubscription<List<ListingModel>>? _listingSubscription;

  MyListingsBloc({required ListingService listingService})
    : _listingService = listingService,
      super(const MyListingsState()) {
    on<LoadMyListings>(_onLoadMyListings);
    on<MyListingsUpdated>(_onMyListingsUpdated);
    on<AddMyListing>(_onAddMyListing);
    on<UpdateMyListing>(_onUpdateMyListing);
    on<DeleteMyListing>(_onDeleteMyListing);
  }

  void _onLoadMyListings(LoadMyListings event, Emitter<MyListingsState> emit) {
    emit(state.copyWith(status: MyListingsStatus.loading));

    _listingSubscription?.cancel();
    _listingSubscription = _listingService
        .getUserListingsStream(event.userId)
        .listen(
          (listings) {
            add(MyListingsUpdated(listings));
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: MyListingsStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  void _onMyListingsUpdated(
    MyListingsUpdated event,
    Emitter<MyListingsState> emit,
  ) {
    emit(
      state.copyWith(status: MyListingsStatus.loaded, listings: event.listings),
    );
  }

  Future<void> _onAddMyListing(
    AddMyListing event,
    Emitter<MyListingsState> emit,
  ) async {
    try {
      await _listingService.addListing(event.listing);
    } catch (e) {
      emit(
        state.copyWith(
          status: MyListingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateMyListing(
    UpdateMyListing event,
    Emitter<MyListingsState> emit,
  ) async {
    try {
      await _listingService.updateListing(event.listing);
    } catch (e) {
      emit(
        state.copyWith(
          status: MyListingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteMyListing(
    DeleteMyListing event,
    Emitter<MyListingsState> emit,
  ) async {
    try {
      await _listingService.deleteListing(event.listingId);
    } catch (e) {
      emit(
        state.copyWith(
          status: MyListingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _listingSubscription?.cancel();
    return super.close();
  }
}
