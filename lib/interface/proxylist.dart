class ProxyItem {
  final String  country;
  final String flag;
  final String ip;
  final int port;
  final String price;

  const ProxyItem(this.country, this.flag, this.ip, this.port, this.price);

  ProxyItem.fromJson(Map<String, dynamic> json)
      : country = json['country'] as String,
        flag = json['flag'] as String,
        ip = json['ip'] as String,
        port = json['port'] as int,
        price = json['price'] as String;

  Map<String, dynamic> toJson() => {
        'country': country,
        'flag': flag,
        'ip': ip,
        'port': port,
        'price': price,
      };
}





