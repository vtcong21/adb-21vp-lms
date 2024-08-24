import React from 'react';
import { Card, Rate, Carousel } from 'antd';
import 'antd/dist/reset.css';
import '../../assets/styles/carousel.css'

const top50Courses = [
    { title: 'Python for Beginners', rating: 4.5, students: 12345 },
    { title: 'Web Development Bootcamp', rating: 4.7, students: 23456 },
    { title: 'Web Development Bootcamp', rating: 4.7, students: 23456 },
    { title: 'Web Development Bootcamp', rating: 4.7, students: 23456 },
    { title: 'Web Development Bootcamp', rating: 4.7, students: 23456 },
    { title: 'Web Development Bootcamp', rating: 4.7, students: 23456 },
    { title: 'Web Development Bootcamp', rating: 4.7, students: 23456 },
    { title: 'Web Development Bootcamp', rating: 4.7, students: 23456 },
    // Add more courses here
  ];

const chunkArray = (array, size) => {
    return array.reduce((result, item, index) => {
        const chunkIndex = Math.floor(index / size);
        if (!result[chunkIndex]) {
        result[chunkIndex] = [];
        }
        result[chunkIndex].push(item);
        return result;
    }, []);
};

const HomePage = () => {
    const coursesInChunks = chunkArray(top50Courses, 3);
    return (
        <Card>
            <div className="flex justify-between items-center p-8">
                <div className="text-left">
                    <h1 className="text-4xl font-bold mb-4">Learning that gets you</h1>
                    <p className="text-xl">Skills for your present and future. Get started with us.</p>
                </div>
                <img src="./images/homepage-1.svg" className="w-1/3" />
            </div>
            <Carousel
                arrows
                    dotPosition="bottom"
                    autoplay
                    className="w-100 flex"
                    >
                    {coursesInChunks.map((chunk, chunkIndex) => (
                        <div key={chunkIndex} className="flex justify-center">
                        <div className="grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-3 gap-6 p-10">
                            {chunk.map((course, index) => (
                            <Card
                                key={index}
                                hoverable
                                className="rounded-lg shadow-lg bg-white"
                            >
                                <Card.Meta
                                title={<h2 className="text-l font-semibold text-gray-800">{course.title}</h2>}
                                description={`Rating: ${course.rating}`}
                                />
                                <div className="mt-2">
                                <Rate disabled defaultValue={course.rating} />
                                <p className="text-gray-600">{course.students.toLocaleString()} students</p>
                                </div>
                            </Card>
                            ))}
                        </div>
                        </div>
                    ))}
                    </Carousel>
        </Card>
    );
}

export default HomePage;
