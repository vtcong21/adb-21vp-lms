import React from 'react';
import { Card, Rate } from 'antd';

const top50Courses = [
    { title: 'Python for Beginners', rating: 4.5, students: 12345 },
    { title: 'Web Development Bootcamp', rating: 4.7, students: 23456 },
    // Add more courses here
  ];

const HomePage = () => {
  return (
    <Card>
        <div className="flex justify-between items-center bg-gray-200 p-8">
            <div className="text-left">
                <h1 className="text-4xl font-bold mb-4">Learning that gets you</h1>
                <p className="text-xl">Skills for your present and future. Get started with us.</p>
            </div>
            <img src="./images/homepage_img.jpg" className="w-1/3" />
        </div>
        <div className="p-8">
            <h2 className="text-3xl font-bold mb-4">A broad selection of courses</h2>
            <div className="grid grid-cols-4 gap-4">
            {top50Courses.map((course, index) => (
                <Card
                key={index}
                hoverable
                // cover={<img alt={course.title} src={course.image} />}
                className="w-full"
                >
                <Card.Meta title={course.title} description={`Rating: ${course.rating}`} />
                <div className="mt-2">
                    <Rate disabled defaultValue={course.rating} />
                    <p>{course.students} students</p>
                </div>
                </Card>
            ))}
            </div>
        </div>
    </Card>
  );
}

export default HomePage;
