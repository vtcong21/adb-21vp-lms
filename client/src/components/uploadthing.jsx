import { generateUploadButton } from "@uploadthing/react";
 
export const UploadButton = generateUploadButton({
  url: "http://localhost:8000/api/uploadthing",
});