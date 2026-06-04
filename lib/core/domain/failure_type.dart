/// Classifies the type of failure for error handling in Result and ViewState.
enum FailureType {
  network,
  notFound,
  timeout,
  api,
  deserialization,
  unknown,
}
