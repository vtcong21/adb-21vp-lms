import React, { useEffect, useState } from 'react';
import { Card, Rate, Carousel, message } from 'antd';
import 'antd/dist/reset.css';
import '../../assets/styles/carousel.css';
import OnlineService from '../../services/public/';
import { useNavigate } from 'react-router-dom';

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
    const [top50Courses, setTop50Courses] = useState([]);
    const navigate = useNavigate(); // Hook to navigate

    useEffect(() => {
        const fetchCourseData = async () => {
            try {
                const res = await OnlineService.getTop50Courses();
                console.log(res);
                const resFormatted = await res.map((data, row) => ({
                    ...data,
                    key: row,
                    rating: Math.min(5, Math.floor(Math.random() * (5 - 3 + 1)) + 3 + Math.floor(Math.random() * (9 - 0 + 1)) / 10),
                    students: Math.floor(Math.random() * (10000 - 100 + 1)) + 100
                }));
                setTop50Courses(resFormatted);
            } catch (error) {
                message.error("Cannot load course data." + error);
            }
        };

        fetchCourseData();
    }, []);

    const coursesInChunks = chunkArray(top50Courses, 3);

    // Function to handle card click
    const handleCardClick = (courseId) => {
        navigate(`/course-detail/${courseId}`);
    };

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
                                    onClick={() => handleCardClick(course.id)} // Click handler
                                >
                                    <Card.Meta
                                        title={<h2 className="text-l font-semibold text-gray-800">{course.title}</h2>}
                                        description={`Rating: ${course.rating}`}
                                    />
                                    <div className="mt-2">
                                        <Rate disabled value={course.rating} />
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
