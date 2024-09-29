class User {
  String name;
  String lastname;
  String username;
  String password;

  User(
      {required this.name,
      required this.lastname,
      required this.username,
      required this.password});

  factory User.fromJson(Map<String, dynamic> json) => User(
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      username: json['username'] as String,
      password: json['password'] as String);
}
