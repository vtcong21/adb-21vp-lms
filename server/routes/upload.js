import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { uploadFile, getFile } from '../controllers/upload.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const router = Router();

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadPath = path.join(__dirname, '../uploads');
        if (!fs.existsSync(uploadPath)) {
            fs.mkdirSync(uploadPath);
        }
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});

const fileFilter = (req, file, cb) => {
    const fileTypes = {
        'thumbnail': ['image/jpeg', 'image/png', 'image/gif'],
        'advertisement': ['video/mp4', 'video/mkv'],
        'course_video': ['video/mp4', 'video/mkv'],
        'course_file': ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
    };

    const fileType = file.fieldname;
    const allowedTypes = fileTypes[fileType];

    if (allowedTypes && allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error(`Invalid file type for ${fileType}. Allowed types: ${allowedTypes.join(', ')}`), false);
    }
};

const limits = {
    thumbnail: 1024 * 1024 * 2, // 2MB
    advertisement: 1024 * 1024 * 100, // 100MB
    course_video: 1024 * 1024 * 500, // 500MB
    course_file: 1024 * 1024 * 10 // 10MB
};

const upload = multer({
    storage,
    fileFilter,
    limits: (req, file) => {
        const sizeLimit = limits[file.fieldname];
        return { fileSize: sizeLimit };
    }
});

router.post('/upload', upload.fields([
    { name: 'thumbnail', maxCount: 1 },
    { name: 'advertisement', maxCount: 1 },
    { name: 'course_video', maxCount: 1 },
    { name: 'course_file', maxCount: 1 }
]), uploadFile);

router.get('/files/:filename', getFile);

export default router;
