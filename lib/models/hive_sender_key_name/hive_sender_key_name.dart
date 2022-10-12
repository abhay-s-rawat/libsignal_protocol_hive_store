import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import '../hive_signal_protocol_address/hive_signal_protocol_address.dart';
part 'hive_sender_key_name.g.dart';

@HiveType(typeId: 222)
class HiveSenderKeyName extends Equatable {
  @HiveField(0)
  final String groupId;
  @HiveField(1)
  final HiveSignalProtocolAddress sender;

  const HiveSenderKeyName({
    required this.groupId,
    required this.sender,
  });

  SenderKeyName get toSignalName {
    return SenderKeyName(groupId, sender.toSignalAddress);
  }

  factory HiveSenderKeyName.fromSignalName(SenderKeyName name) {
    return HiveSenderKeyName(
      groupId: name.groupId,
      sender: HiveSignalProtocolAddress.fromSignalAddress(name.sender),
    );
  }

  @override
  List<Object> get props => [groupId, sender];
}
