# adb-21vp-lms
A learning management system.
## Note
- Chạy file bak mới nhất.
- Merge main.
- Role nào check kĩ data role đó, mấy chục bảng lận coi chừng có sai sót.
## Upload (cho Tạo khóa học, ai ko code thì lướt)
- Route:
```
POST /api/upload
```
- Hình demo thì google, video để demo thì có thể tải từ đây: https://pixabay.com/videos/search/teaching/
- Response có trả về filename, lưu nó vô các cột image/video/resource trong các bảng.
- File được lưu ở /server/uploads, **đừng xóa gì trong này**.
- Có 4 file type, test postman thì để dữ liệu dạng form-data:
```
thumbnail (cho course.image)
advertisement (cho course.video)
course_video (cho lesson.resource)
course_file (cho lesson.resource)
```
## Lấy file (cho Xem khóa học, ai ko code thì lướt)
```
GET /api/files/:filename
 ```
- Filename được lưu ở các cột image/video/resource trong các bảng.
- File được lưu ở /server/uploads, **đừng xóa gì trong này**.
- Có thể mở server, paste link này vô browser chạy thử:
```
http://localhost:8000/api/files/1.mp4
```
## Course xịn để demo
- Course.id = 1.
- 3 section, mỗi section 3 video.
- Các course còn lại mỗi course 2 section, 1 section lecture file tới 1.mp4, 1 section exercise.
- learning time các lesson sẽ random, vì 1 clip có mấy giây à.
# Chúc may mắn, có gì hỏi tui