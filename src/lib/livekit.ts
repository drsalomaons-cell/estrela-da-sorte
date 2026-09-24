import { Room, RoomOptions } from "livekit-client";

export const livekitUrl = import.meta.env.VITE_LIVEKIT_URL as string | undefined;

export const livekitConfigured = Boolean(livekitUrl);

export function createLiveKitRoom(): Room {
  const options: RoomOptions = {
    adaptiveStream: true,
    dynacast: true,
  };
  return new Room(options);
}
