export interface UploadedImage {
  url: string;
  preview: string;
  name: string;
}

export interface GenerationState {
  isGenerating: boolean;
  error: string | null;
  videoUrl: string | null;
}
