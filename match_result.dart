class MatchResult {
  const MatchResult.waiting()
      : matched = false,
        encounterId = null,
        roomName = null,
        token = null,
        liveKitUrl = null,
        partnerId = null,
        partnerName = null,
        partnerAvatarUrl = null,
        partnerRating = null,
        partnerVip = false;

  const MatchResult.matched({
    required this.encounterId,
    required this.roomName,
    required this.token,
    required this.liveKitUrl,
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatarUrl,
    this.partnerRating,
    this.partnerVip = false,
  }) : matched = true;

  final bool matched;
  final String? encounterId, roomName, token, liveKitUrl;
  final String? partnerId, partnerName, partnerAvatarUrl;
  final double? partnerRating;
  final bool partnerVip;
}
