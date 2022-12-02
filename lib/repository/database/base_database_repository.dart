import 'package:leggo/model/user.dart';

abstract class BaseDatabaseRepository {
  Stream<User> getUser(String userId);
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> updateUserPictures(User user, String imageName);
  Future<bool> checkUsernameAvailability(String userName);
  Future<void> registerUsername(String username, String userId);
  Future<void> deregisterUsername(String username);
}
