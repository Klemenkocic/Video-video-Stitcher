export const DEFAULT_PROMPT =
  "Create an ultra-realistic cinematic drone video that transitions seamlessly from Reference Image 1 to Reference Image 2 using a hidden cut (NOT a morph).\n\nSHOT A (Reference Image 1):\nStart exactly matching Reference Image 1 composition, subject placement, and scale. Use realistic drone camera motion: smooth stabilized forward glide with subtle rise or descent (choose what fits the scene), gentle parallax, physically plausible motion blur, and natural exposure/white balance. Maintain real-world geometry and architecture/nature structure—no surreal changes.\n\nTRANSITION (must be a hidden cut with full-frame occlusion):\nDo NOT blend the two locations. Do NOT transform one scene into another.\nPerform a transition where the camera movement naturally causes the frame to become fully occluded for a short moment (choose the most plausible occluder based on the scene):\n\t•\ttilt up into 100% sky/clouds, OR\n\t•\tpass behind trees/foliage, OR\n\t•\tpass behind/under a wall/bridge/rock, OR\n\t•\twhip-pan causing full-frame motion blur with no readable details.\n\nHold full occlusion (or fully unreadable blur) for 12–18 frames. During that occluded/blurred moment, do a clean hard cut to the second location.\n\nSHOT B (Reference Image 2):\nEmerge from the same occlusion element into Reference Image 2 and immediately match its composition, subject placement, and scale. Continue the same camera direction and speed so the move feels continuous. Stabilize and ease into a cinematic hero framing that ends close to Reference Image 2.\n\nGLOBAL REALISM RULES:\n\t•\tPhotoreal, cinematic color grade, consistent lens and exposure across both shots.\n\t•\tKeep lighting/weather/time-of-day consistent (soft daylight preferred unless references suggest otherwise).\n\t•\tMaintain realistic perspective: no bending lines, no melting surfaces, no stretching structures, no impossible topology changes.\n\t•\tNo portals, no magical transitions, no morphing, no environment “opening up.”\n\t•\tNo text, subtitles, logos, watermarks, UI.\n\nCAMERA / FILM LOOK:\nDrone camera, stabilized gimbal, natural micro-jitter only, 24–30 fps, cinematic motion blur, crisp detail, realistic atmospheric haze if appropriate.";

export const NEGATIVE_PROMPT =
  "morphing, scene blending, architecture transforming, unfolding environment, warping, melted buildings, bending geometry, duplicated windows/trees, floating objects, portal/vortex, surreal transition, flicker, jitter, stutter, low-res, cartoon, CGI look, oversharpen, heavy noise, text, watermark, logo";

export const LOADING_MESSAGES = [
  "Starting your memory...",
  "Capturing the journey...",
  "Adding cinematic movement...",
  "Almost ready...",
];

export const MAX_FILE_SIZE_MB = 10;
export const MIN_IMAGE_DIMENSION = 300;
export const ALLOWED_FILE_TYPES = ["image/jpeg", "image/png", "image/webp"];
