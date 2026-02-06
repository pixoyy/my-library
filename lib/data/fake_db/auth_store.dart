import '../models/user_model.dart';
import '../models/book_model.dart';

class AuthStore {
  static UserModel? currentUser;
  static final List<UserModel> users = [];
  static final Map<String, List<BookModel>> bookmarks = {};

  static bool register(UserModel user) {
    if (users.any(
      (u) => u.email == user.email || u.username == user.username,
    )) {
      return false;
    }
    users.add(user);
    bookmarks[user.email] = [];
    return true;
  }

  static bool login(String username, String password) {
    try {
      currentUser = users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static void logout() {
    currentUser = null;
  }
}
