class User {
  final String uid;
  final String email;
  final String token;
  final String avatar;

  User({
    this.uid,
    this.email,
    this.token,
    this.avatar =
        "https://firebasestorage.googleapis.com/v0/b/flutterstarter-83233.appspot.com/o/user.jpg?alt=media&token=f08fc0f9-5cd3-4a58-8256-b2dc4f0b0251",
  });
}
