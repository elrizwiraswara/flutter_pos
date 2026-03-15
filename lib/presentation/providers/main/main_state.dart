import '../../../domain/entities/user_entity.dart';

class MainState {
  final bool isLoaded;
  final bool isHasInternet;
  final bool isHasQueuedActions;
  final bool isSyncronizing;
  final UserEntity? user;

  const MainState({
    this.isLoaded = false,
    this.isHasInternet = true,
    this.isHasQueuedActions = false,
    this.isSyncronizing = false,
    this.user,
  });

  MainState copyWith({
    bool? isLoaded,
    bool? isHasInternet,
    bool? isHasQueuedActions,
    bool? isSyncronizing,
    UserEntity? user,
  }) {
    return MainState(
      isLoaded: isLoaded ?? this.isLoaded,
      isHasInternet: isHasInternet ?? this.isHasInternet,
      isHasQueuedActions: isHasQueuedActions ?? this.isHasQueuedActions,
      isSyncronizing: isSyncronizing ?? this.isSyncronizing,
      user: user ?? this.user,
    );
  }
}
