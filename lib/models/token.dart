class Token {
  final String accessToken;
  final String tokenType;

  Token({
    required this.accessToken,
    required this.tokenType,
  });

  // Convertir un Token a JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }

  // Convertir de JSON a un Token
  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}
