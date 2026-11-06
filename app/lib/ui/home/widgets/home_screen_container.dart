import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/booking/booking_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../auth/logout/view_models/logout_viewmodel.dart';
import '../view_models/home_viewmodel.dart';
import 'home_screen.dart';

class HomeScreenContainer extends StatefulWidget {
  const HomeScreenContainer({super.key, required this.logoutViewModel});

  final LogoutViewModel logoutViewModel;

  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeViewModel(
      bookingRepository: context.read<BookingRepository>(),
      userRepository: context.read<UserRepository>(),
    );
  }

  @override
  void didUpdateWidget(covariant HomeScreenContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The "/" page stays mounted under every child route, so this State (and
    // its view model) survives a round trip such as Home -> ... -> Booking ->
    // Home. GoRouter re-runs the route builder on that navigation, which
    // creates a new LogoutViewModel; use that as the signal to reload so a
    // booking created meanwhile shows up in the list.
    if (!identical(oldWidget.logoutViewModel, widget.logoutViewModel)) {
      _viewModel.load.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      viewModel: _viewModel,
      logoutViewModel: widget.logoutViewModel,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
