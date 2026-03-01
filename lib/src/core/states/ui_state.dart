sealed class UIState<T> {
  const UIState();
}

class InitialState<T> extends UIState<T> {
  const InitialState();
}

class LoadingState<T> extends UIState<T> {
  const LoadingState();
}

class SuccessState<T> extends UIState<T> {
  final T data;
  const SuccessState(this.data);
}

class ErrorState<T> extends UIState<T> {
  final String message;
  const ErrorState(this.message);
}
