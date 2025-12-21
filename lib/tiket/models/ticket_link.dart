import 'dart:convert';

class TicketLink {
  const TicketLink({
    this.id,
    required this.linkId,
    required this.vendor,
    required this.vendorLink,
    required this.price,
    required this.imgVendor,
  });

  final int? id;
  final String linkId;
  final String vendor;
  final String vendorLink;
  final int price;
  final String imgVendor;

  factory TicketLink.fromJson(Map<String, dynamic> json) {
    final dynamic rawUrl = json['vendor_link'] ?? json['url'] ?? json['link'];
    return TicketLink(
      id: _asInt(json['id']),
      linkId: json['link_id']?.toString() ?? '',
      vendor: json['vendor']?.toString() ?? '',
      vendorLink: rawUrl?.toString() ?? '',
      price: _asInt(json['price']) ?? 0,
      imgVendor: json['img_vendor']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'link_id': linkId,
      'vendor': vendor,
      'vendor_link': vendorLink,
      'price': price,
      'img_vendor': imgVendor,
    };
  }

  TicketLink copyWith({
    int? id,
    String? linkId,
    String? vendor,
    String? vendorLink,
    int? price,
    String? imgVendor,
  }) {
    return TicketLink(
      id: id ?? this.id,
      linkId: linkId ?? this.linkId,
      vendor: vendor ?? this.vendor,
      vendorLink: vendorLink ?? this.vendorLink,
      price: price ?? this.price,
      imgVendor: imgVendor ?? this.imgVendor,
    );
  }
}

TicketLink ticketLinkFromJson(String str) =>
    TicketLink.fromJson(json.decode(str) as Map<String, dynamic>);

List<TicketLink> ticketLinkListFromJson(String str) {
  final dynamic data = json.decode(str);
  if (data is List) {
    return data.map((e) => TicketLink.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

String ticketLinkToJson(TicketLink data) => json.encode(data.toJson());
String ticketLinkListToJson(List<TicketLink> data) =>
    json.encode(data.map((link) => link.toJson()).toList());

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
