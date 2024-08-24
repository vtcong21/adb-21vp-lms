import { createUploadthing } from "uploadthing/express";
import dotenv from 'dotenv';
dotenv.config();

const f = createUploadthing();


export const ourFileRouter = {
  courseThumbnail: f({
    image: { maxFileSize: "1MB", maxFileCount: 1 },
  }).onUploadComplete((response) => {
    console.log('Upload response:', response);
    // Additional processing here
  }),
  courseAdvertisementVideo: f({
    video: { maxFileSize: "2MB", maxFileCount: 1 },
  })
    .onUploadComplete(() => { }),
  courseSectionFile: f(["text", "image", "video", "audio", "pdf"])
    .onUploadComplete(() => { }),
  courseSectionVideo: f({ video: { maxFileSize: "2MB", maxFileCount: 1 } })
    .onUploadComplete(() => { }),
};