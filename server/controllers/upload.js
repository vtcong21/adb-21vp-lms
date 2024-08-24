import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const uploadFile = (req, res) => {
    if (!req.files) {
        return res.status(400).send('No files uploaded.');
    }

    const uploadedFiles = Object.keys(req.files).map(fieldname => {
        return { field: fieldname, filename: req.files[fieldname][0].filename };
    });

    res.status(200).send({
        message: 'Files uploaded successfully',
        files: uploadedFiles
    });
};

export const getFile = (req, res) => {
    const filename = req.params.filename;
    const filePath = path.join(__dirname, '../uploads', filename);

    if (fs.existsSync(filePath)) {
        res.sendFile(filePath);
    } else {
        res.status(404).send('File not found.');
    }
};
