<<<<<<< HEAD
import React from 'react';
import { Card, Avatar, Typography, Row, Col } from 'antd';
=======
import React, { useState } from "react";
import { Form, Input } from "antd";
// import DentistService from "../../services/dentist";
import { useSelector } from "react-redux";
import { ButtonBlue } from "~/components/button";
const ProfileNS = () => {
  const user = useSelector((state) => state.user);
  const { ROLE, HOTEN, PHAI, MANS } = user;
  const [form] = Form.useForm();
>>>>>>> main

const { Title, Text } = Typography;

const ProfilePage = () => {
  return (
    <div className="p-4 flex justify-center items-center bg-gray-100">
      <Card
        className="w-full h-full max-w-3xl p-6 bg-white rounded-lg shadow-lg"
        bordered={false}
      >
        <Row gutter={[16, 16]}>
          {/* Column for Instructor Info - 3/4 of the width */}
          <Col xs={24} md={18}>
            <Title level={2} className="mb-0">
              Assem Hafsi
            </Title>
            <Text className="block mb-2">Web & Graphic Designer</Text>
            {/* <Text className="block mb-1">
              <strong>Total students: </strong>15,359
            </Text>
            <Text className="block mb-4">
              <strong>Reviews: </strong>267
            </Text> */}
            <Title level={3} className="mb-4">About me</Title>
            <Text>
              Hello everyone, my name is <strong>Assem Hafsi</strong> and I have an EQF (European Qualification Framework) level 5 professional Diploma in <strong>Graphic Design</strong> and <strong>Web Design</strong>. I have learned graphic Design from top Instructors all over the world such as the US, the UK, Canada... and I'm still learning and sharpening my skills because as you know there is always something to learn especially in our world because every day you see and hear about new technologies and techniques.
            </Text>
            <div className="mt-6">
              <Title level={4} className="mt-6">Together we are going to build a learning community online</Title>
              <Text className="block">My <strong>passion</strong> is inspiring and motivating people through online courses.</Text>
              <Text className="block">My <strong>goal</strong> is to make the best version of you.</Text>
              <Text className="block"><strong>Making</strong> learning online not boring, however, it would be interesting and fun.</Text>
              <Text className="block">To <strong>enjoy</strong> your time while you are studying and learning new skills that will help you in your day-to-day life.</Text>
              <Text className="block">To <strong>share</strong> with you what I have learned and my expertise in many fields in life.</Text>
              <Text className="block">To <strong>become</strong> a lifetime learner.</Text>

              <Title level={4} className="mt-6">So let's start our learning journey.</Title>
            </div>
          </Col>

          {/* Column for Avatar - 1/4 of the width */}
          <Col xs={24} md={6} className="flex justify-center md:justify-end items-start">
            <Avatar
              size={100}
              src="https://via.placeholder.com/100" // Replace with the actual image URL
              className="md:ml-4"
            />
          </Col>
        </Row>
      </Card>
    </div>
  );
};

export default ProfilePage;