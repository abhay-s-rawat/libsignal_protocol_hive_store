import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
part 'hive_signal_protocol_address.g.dart';

@HiveType(typeId: 221)
class HiveSignalProtocolAddress extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int deviceId;

  const HiveSignalProtocolAddress(
    this.name,
    this.deviceId,
  );

  SignalProtocolAddress get toSignalAddress {
    return SignalProtocolAddress(name, deviceId);
  }

  factory HiveSignalProtocolAddress.fromSignalAddress(
      SignalProtocolAddress address) {
    return HiveSignalProtocolAddress(address.getName(), address.getDeviceId());
  }

  @override
  List<Object> get props => [name, deviceId];
}
