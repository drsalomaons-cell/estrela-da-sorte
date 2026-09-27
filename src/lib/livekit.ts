import { Room, RoomOptions, RoomEvent } from "livekit-client";

export const livekitUrl = import.meta.env.VITE_LIVEKIT_URL as string | undefined;

export const livekitConfigured = Boolean(livekitUrl);

export function createLiveKitRoom(): Room {
  const options: RoomOptions = {
    adaptiveStream: true,
    dynacast: true,
  };
  return new Room(options);
}

export type LiveKitMediaState = {
  connected: boolean;
  microphoneEnabled: boolean;
  cameraEnabled: boolean;
  participantCount: number;
};

export async function connectLiveKitRoom(
  room: Room,
  token: string,
  url: string = livekitUrl ?? "",
): Promise<void> {
  if (!url) throw new Error("VITE_LIVEKIT_URL não configurado");
  if (!token) throw new Error("Token LiveKit não informado");
  await room.connect(url, token, { autoSubscribe: true });
}

export async function enableMicrophone(room: Room, enabled: boolean): Promise<void> {
  await room.localParticipant.setMicrophoneEnabled(enabled);
}

export async function enableCamera(room: Room, enabled: boolean): Promise<void> {
  await room.localParticipant.setCameraEnabled(enabled);
}

export async function startLiveKitAudio(room: Room): Promise<void> {
  await room.startAudio();
}

export function subscribeLiveKitState(
  room: Room,
  onChange: (state: LiveKitMediaState) => void,
): () => void {
  const emit = () => {
    onChange({
      connected: room.state !== "disconnected",
      microphoneEnabled: room.localParticipant.isMicrophoneEnabled,
      cameraEnabled: room.localParticipant.isCameraEnabled,
      participantCount: room.numParticipants,
    });
  };

  room
    .on(RoomEvent.ParticipantConnected, emit)
    .on(RoomEvent.ParticipantDisconnected, emit)
    .on(RoomEvent.LocalTrackPublished, emit)
    .on(RoomEvent.LocalTrackUnpublished, emit)
    .on(RoomEvent.TrackMuted, emit)
    .on(RoomEvent.TrackUnmuted, emit)
    .on(RoomEvent.Disconnected, emit);

  emit();

  return () => {
    room
      .off(RoomEvent.ParticipantConnected, emit)
      .off(RoomEvent.ParticipantDisconnected, emit)
      .off(RoomEvent.LocalTrackPublished, emit)
      .off(RoomEvent.LocalTrackUnpublished, emit)
      .off(RoomEvent.TrackMuted, emit)
      .off(RoomEvent.TrackUnmuted, emit)
      .off(RoomEvent.Disconnected, emit);
  };
}
