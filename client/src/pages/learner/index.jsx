import { generateUploadButton } from "@uploadthing/react";
import { message } from 'antd';

const UploadButton = generateUploadButton({
  url: "http://localhost:8000/api/uploadthing",
  skipPolling: true,
});
const LearnerPage = () => {
  return (
    <>
      <div className="  flex justify-center">
        <h1 className="text-red-800 text-3xl">
          Day la trang danh cho khach hang da dang nhap
        </h1>
      </div>
      <div className="flex justify-center">
        <h1 className="text-red-800 text-3xl">
          Đây là trang dành cho khách hàng đã đăng nhập
        </h1>
      </div>
      <div>
        <h1>Upload Files</h1>
        <UploadButton endpoint="courseThumbnail"
          onClientUploadComplete={(response) => {
            if (response.status === 200) {
              console.log(response);
              message.success(`File uploaded successfully! URL: ${uploadedFileUrl}`);
            } else {

              message.error(`Upload failed. Status: ${response.status}`);
            }
          }}
          onUploadError={(error) => {
            message.error(error.message);
          }} />
      </div>
    </>
  );

};

export default LearnerPage;
