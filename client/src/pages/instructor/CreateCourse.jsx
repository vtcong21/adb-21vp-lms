import React, { memo } from "react";
import { Input, Button, Divider } from "antd";

const Sidebar = () => {
  return (
    <div className="w-1/4 bg-white p-6 shadow-md">
      <h3 className="text-xl font-semibold mb-4">Plan your course</h3>
      <ul className="space-y-4">
        <li className="font-medium text-gray-700">Intended learners</li>
        <li className="text-gray-500">Course structure</li>
        <li className="text-gray-500">Setup & test video</li>
        <li className="text-gray-500">Film & edit</li>
        <li className="text-gray-500">Curriculum</li>
        <li className="text-gray-500">Captions (optional)</li>
        <li className="text-gray-500">Accessibility (optional)</li>
        <li className="text-gray-500">Course landing page</li>
        <li className="text-gray-500">Pricing</li>
        <li className="text-gray-500">Promotions</li>
        <li className="text-gray-500">Course messages</li>
      </ul>
      <Button type="primary" className="mt-6 w-full">
        Submit for Review
      </Button>
    </div>
  );
};


const MainContent = () => {
  return (
    <div className="w-3/4 p-6">
      <h2 className="text-2xl font-semibold mb-4">Intended learners</h2>
      <p className="text-gray-600 mb-6">
        The following descriptions will be publicly visible on your Course Landing Page and will have a direct impact on your course performance. These descriptions will help learners decide if your course is right for them.
      </p>

      <div className="mb-6">
        <h3 className="text-lg font-medium mb-2">What will students learn in your course?</h3>
        <p className="text-gray-600 mb-4">
          You must enter at least 4 learning objectives or outcomes that learners can expect to achieve after completing your course.
        </p>
        {[
          "Define the roles and responsibilities of a project manager",
          "Estimate project timelines and budgets",
          "Identify and manage project risks",
          "Complete a case study to manage a project from conception to completion"
        ].map((placeholder, index) => (
          <Input.TextArea
            key={index}
            placeholder={placeholder}
            maxLength={160}
            className="mb-4"
          />
        ))}
        <Button type="dashed" className="w-full">
          + Add more to your response
        </Button>
      </div>

      <Divider />

      <div className="mb-6">
        <h3 className="text-lg font-medium mb-2">What are the requirements or prerequisites for taking your course?</h3>
        <p className="text-gray-600 mb-4">
          List the required skills, experience, tools or equipment learners should have prior to taking your course. If there are no requirements, use this space as an opportunity to lower the barrier for beginners.
        </p>
        <Input.TextArea
          placeholder="Example: No programming experience needed. You will learn everything you need to know."
          maxLength={160}
          className="mb-4"
        />
        <Button type="dashed" className="w-full">
          + Add more to your response
        </Button>
      </div>

      <Divider />

      <div className="mb-6">
        <h3 className="text-lg font-medium mb-2">Who is this course for?</h3>
        <p className="text-gray-600 mb-4">
          Write a clear description of the intended learners for your course who will find your course content valuable. This will help you attract the right learners to your course.
        </p>
        <Input.TextArea
          placeholder="Enter your description here"
          maxLength={160}
          className="mb-4"
        />
      </div>

      <Button type="primary" className="w-full">
        Submit for Review
      </Button>
    </div>
  );
};

const CreateCourse = () => {
  return (
    <div className="flex min-h-screen bg-gray-100">
      <Sidebar />
      <MainContent />
    </div>
  );
};

export default CreateCourse;