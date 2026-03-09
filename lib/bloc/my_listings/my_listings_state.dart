import 'package:equatable/equatable.dart';
import '../../models/listing_model.dart';

enum MyListingsStatus { initial, loading, loaded, error }

class MyListingsState extends Equatable {
  final MyListingsStatus status;
  final List<ListingModel> listings;
  final String? errorMessage;

  const MyListingsState({
    this.status = MyListingsStatus.initial,
    this.listings = const [],
    this.errorMessage,
  });

  MyListingsState copyWith({
    MyListingsStatus? status,
    List<ListingModel>? listings,
    String? errorMessage,
  }) {
    return MyListingsState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, listings, errorMessage];
}
