import "../../assets/styles/instructor.css";
import React, { useState } from "react";
import { Input, Button, Divider, Form, Select, Upload, message, Anchor } from "antd";
import { MinusCircleOutlined, PlusOutlined, UploadOutlined } from '@ant-design/icons';
import InstructorService from '../../services/instructor';

const placeholderStyle = {
  fontSize: '18px', 
  color: 'black',
};

const handleClick = (e, link) => {
  e.preventDefault();
  console.log(link);
};
const Sidebar = ({ onSubmit }) => (
  <div className="w-1/4 bg-white p-6 pt-12 shadow-md">
    <div className="text-xl font-bold mb-4">Plan your course</div>
    <Anchor
      affix={false}
      onClick={handleClick}
      items={[
        { key: '1', href: '#anchor-intended-learner', title: <span className="text-lg leading-loose">Intended learners</span> },
        { key: '2', href: '#anchor-requirement', title: <span className="text-lg leading-loose">Course Requirements</span> },
        { key: '3', href: '#anchor-objective', title: <span className="text-lg leading-loose">Course Objectives</span> },
        { key: '4', href: '#anchor-curriculum', title: <span className="text-lg leading-loose">Curriculum</span> },
        { key: '5', href: '#anchor-landing-page', title: <span className="text-lg leading-loose">Course landing page</span> },
        { key: '6', href: '#anchor-pricing', title: <span className="text-lg leading-loose">Pricing</span> },
      ]}
    />
    <Button type="primary" className="mt-6 w-full h-9 text-base font-bold" onClick={onSubmit}>
      Submit for Review
    </Button>
  </div>
);


const IntendedLearners = ({ form }) => {
  const initialLearners = Array(1).fill("");
  const [learners, setLearners] = useState(initialLearners);

  const addLearner = () => {
    setLearners([...learners, ""]);
  };

  const handleLearnerChange = (index, value) => {
    const newLearners = [...learners];
    newLearners[index] = value;
    setLearners(newLearners);
  };

  const removeLearner = (index) => {
    if (learners.length > 1) {
      const newLearners = learners.filter((_, i) => i !== index);
      setLearners(newLearners);
    }
  };

  return (
    <section id="anchor-intended-learner">
      <h2 className="text-2xl font-semibold mb-4">Who is this course for?</h2>
      <p className="text-gray-600 mb-6">
        Write a clear description of the intended learners for your course who will find your course content valuable.
        This will help you attract the right learners to your course.
      </p>

      <Form form={form} layout="vertical">
        {learners.map((learner, index) => (
          <Form.Item
            key={index}
            name={`learner-${index}`}
            rules={[{ required: true, message: 'Please enter a description for the learner.' }]}
          >
            <div className="flex items-center">
              <Input
                value={learner}
                placeholder={`Learner description ${index + 1}`}
                style={placeholderStyle}
                onChange={(e) => handleLearnerChange(index, e.target.value)}
                className="flex-grow mr-2 border-black"
              />
              {learners.length > 1 && (
                <MinusCircleOutlined
                  onClick={() => removeLearner(index)}
                  style={{ fontSize: '20px', color: 'red' }}
                />
              )}
            </div>
          </Form.Item>
        ))}

        <Button type="dashed" onClick={addLearner} className="w-full text-blue">
          Add more to your response
        </Button>
      </Form>

      <Divider />
    </section>
  );
};


const CourseRequirements = ({ form }) => {
  const initialRequirements = Array(1).fill("");
  const [requirements, setRequirements] = useState(initialRequirements);

  const addRequirement = () => {
    setRequirements([...requirements, ""]);
  };

  const handleRequirementChange = (index, value) => {
    const newRequirements = [...requirements];
    newRequirements[index] = value;
    setRequirements(newRequirements);
  };

  const removeRequirement = (index) => {
    if (requirements.length > 1) {
      const newRequirements = requirements.filter((_, i) => i !== index);
      setRequirements(newRequirements);
    }
  };

  return (
    <section id="anchor-requirement">
      <h2 className="text-2xl font-semibold mb-4">What are the requirements or prerequisites for taking your course?</h2>
      <p className="text-gray-600 mb-6">
        List the required skills, experience, tools, or equipment learners should have prior to taking your course.
        If there are no requirements, use this space as an opportunity to lower the barrier for beginners.
      </p>

      <Form form={form} layout="vertical">
        {requirements.map((requirement, index) => (
          <Form.Item
            key={index}
            name={`requirement-${index}`}
            rules={[{ required: true, message: 'Please enter a course requirement.' }]}
          >
            <div className="flex items-center">
              <Input
                value={requirement}
                placeholder={`Course requirement ${index + 1}`}
                style={placeholderStyle}
                onChange={(e) => handleRequirementChange(index, e.target.value)}
                className="flex-grow mr-2 border-black"
              />
              {requirements.length > 1 && (
                <MinusCircleOutlined
                  onClick={() => removeRequirement(index)}
                  style={{ fontSize: '20px', color: 'red' }}
                />
              )}
            </div>
          </Form.Item>
        ))}

        <Button type="dashed" onClick={addRequirement} className="w-full text-blue">
          Add more to your response
        </Button>
      </Form>

      <Divider />
    </section>
  );
};


const CourseObjectives = ({ form }) => {
  const initialObjectives = Array(4).fill("");
  const [objectives, setObjectives] = useState(initialObjectives);

  const addObjective = () => {
    setObjectives([...objectives, ""]);
  };

  const handleObjectiveChange = (index, value) => {
    const newObjectives = [...objectives];
    newObjectives[index] = value;
    setObjectives(newObjectives);
  };

  const removeObjective = (index) => {
    if (objectives.length > 4) {
      const newObjectives = objectives.filter((_, i) => i !== index);
      setObjectives(newObjectives);
    }
  };

  return (
    <section id="anchor-objective">
      <h2 className="text-2xl font-semibold mb-4">What will students learn in your course?</h2>
      <p className="text-gray-600 mb-6">
        You must enter at least 4 learning objectives or outcomes that learners can expect to achieve after completing your course.
      </p>

      <Form form={form} layout="vertical">
        {objectives.map((objective, index) => (
          <Form.Item
            key={index}
            name={`objective-${index}`}
            rules={[{ required: true, message: 'Please enter a course objective.' }]}
          >
            <div className="flex items-center">
              <Input
                value={objective}
                placeholder={`Course objective ${index + 1}`}
                style={placeholderStyle}
                onChange={(e) => handleObjectiveChange(index, e.target.value)}
                className="flex-grow mr-2 border-black"
              />
              {objectives.length > 4 && (
                <MinusCircleOutlined
                  onClick={() => removeObjective(index)}
                  style={{ fontSize: '20px', color: 'red' }}
                />
              )}
            </div>
          </Form.Item>
        ))}

        <Button type="dashed" onClick={addObjective} className="w-full text-blue">
          Add more to your response
        </Button>
      </Form>

      <Divider />
    </section>
  );
};


const { Option } = Select;

const Curriculum = () => {
  const [sections, setSections] = useState([{ title: '', lessons: [] }]);

  const addSection = () => {
    setSections([...sections, { title: '', lessons: [] }]);
  };

  const handleSectionTitleChange = (index, value) => {
    const updatedSections = [...sections];
    updatedSections[index].title = value;
    setSections(updatedSections);
  };

  const removeSection = (index) => {
    if (sections.length > 1) {
      const updatedSections = sections.filter((_, i) => i !== index);
      setSections(updatedSections);
    }
  };

  const removeLesson = (sectionIndex, lessonIndex) => {
    const updatedSections = [...sections];
    if (updatedSections[sectionIndex].lessons.length > 1) {
      updatedSections[sectionIndex].lessons = updatedSections[sectionIndex].lessons.filter((_, i) => i !== lessonIndex);
      setSections(updatedSections);
    }
  };

  const addLesson = (sectionIndex, type) => {
    const updatedSections = [...sections];
    const newLesson = { type, title: '', content: '' };
    updatedSections[sectionIndex].lessons.push(newLesson);
    setSections(updatedSections);
  };

  const handleLessonTitleChange = (sectionIndex, lessonIndex, value) => {
    const updatedSections = [...sections];
    updatedSections[sectionIndex].lessons[lessonIndex].title = value;
    setSections(updatedSections);
  };

  const handleUpload = (sectionIndex, lessonIndex, info) => {
    if (info.file.status === 'done') {
      message.success(`${info.file.name} file uploaded successfully`);
      const updatedSections = [...sections];
      updatedSections[sectionIndex].lessons[lessonIndex].content = info.file.name; // store uploaded file name as content
      setSections(updatedSections);
    } else if (info.file.status === 'error') {
      message.error(`${info.file.name} file upload failed.`);
    }
  };

  return (
    <div>
      <section id="anchor-curriculum">
        <h2 className="text-2xl font-semibold mb-4">Curriculum</h2>
        <p className="text-gray-600 mb-6">
          Start putting together your course by creating sections, lectures, and practice activities.
        </p>

        {sections.map((section, sectionIndex) => (
          <div key={sectionIndex} className="mb-4 p-4 border rounded-md" style={{ borderColor: 'black' }}>
            <div className="flex justify-between items-center mb-2">
              <Input
                placeholder="Section title"
                style={placeholderStyle}
                value={section.title}
                onChange={(e) => handleSectionTitleChange(sectionIndex, e.target.value)}
                className="flex-grow mr-2 border-black"
              />
              {sections.length > 1 && (
                <MinusCircleOutlined
                  onClick={() => removeSection(sectionIndex)}
                  style={{ fontSize: '20px', color: 'red' }}
                />
              )}
            </div>

            {section.lessons.map((lesson, lessonIndex) => (
              <div key={lessonIndex} className="mb-2 p-2 rounded" style={{ borderColor: 'black' }}>
                <div className="flex justify-between items-center mb-2">
                  <Input
                    placeholder={`${lesson.type === 'lecture' ? 'Lecture' : 'Quiz'} title`}
                    style={placeholderStyle}
                    value={lesson.title}
                    onChange={(e) => handleLessonTitleChange(sectionIndex, lessonIndex, e.target.value)}
                    className="flex-grow border-black"
                  />
                  <span className="ml-2">
                    {lesson.type === 'lecture' ? 'Lecture' : 'Quiz'}
                  </span>
                  {section.lessons.length > 1 && (
                    <MinusCircleOutlined
                      onClick={() => removeLesson(sectionIndex, lessonIndex)}
                      style={{ fontSize: '20px', color: 'red', marginLeft: '8px' }}
                    />
                  )}
                </div>

                {lesson.type === 'lecture' && (
                  <Upload
                    name="file"
                    action="/upload.do" // Update this with your server upload URL
                    onChange={(info) => handleUpload(sectionIndex, lessonIndex, info)}
                  >
                    <Button className="border border-blue rounded-md text-blue text-base font-bold" icon={<UploadOutlined />}>Upload Video</Button>
                  </Upload>
                )}
              </div>
            ))}

            <div className="flex justify-start mb-2">
              <Select
                placeholder="Select lesson type"
                style={{ width: 200 }}
                onChange={(value) => addLesson(sectionIndex, value)}
                className="border rounded-md"
              >
                <Option value="lecture">Lecture</Option>
                <Option value="quiz">Quiz</Option>
              </Select>
            </div>
          </div>
        ))}
      </section>
      <Button type="dashed" onClick={addSection} className="w-full text-blue">
        + Section
      </Button>
      <Divider />
    </div>
  );
};


const { TextArea } = Input;

const CourseLandingPage = () => {
  const [form] = Form.useForm();
  
  const handleFormSubmit = (values) => {
    console.log('Form Submitted:', values);
  };

  return (
    <div>
      <h2 className="text-2xl font-semibold mb-4">Course landing page</h2>
      <p className="text-gray-600 mb-4">
        Your course landing page is crucial to your success on Udemy. If it's done right, it can also help you gain visibility in search engines like Google. As you complete this section, think about creating a compelling Course Landing Page that demonstrates why someone would want to enroll in your course.
        Learn more about <a href="#">creating your course landing page</a> and <a href="#">course title standards</a>.
      </p>

      <Form
        form={form}
        layout="vertical"
        onFinish={handleFormSubmit}
      >
        {/* Course Title */}
        <Form.Item
          label={<span style={{ fontSize: '18px' }}>Course title</span>}
          name="title"
          rules={[{ required: true, message: 'Please enter a course title.' }]}
        >
          <Input
            placeholder="Insert your course title."
            maxLength={60}
            style={placeholderStyle}
            className="flex-grow mr-2 border-black"
          />
        </Form.Item>

        {/* Course Subtitle */}
        <Form.Item
          label={<span style={{ fontSize: '18px' }}>Course subtitle</span>}
          name="subtitle"
          rules={[{ required: true, message: 'Please enter a course subtitle.' }]}
        >
          <Input
            placeholder="Insert your course subtitle."
            maxLength={120}
            style={placeholderStyle}
            className="flex-grow mr-2 border-black"
          />
        </Form.Item>

        {/* Course Description */}
        <Form.Item
          label={<span style={{ fontSize: '18px' }}>Course description</span>}
          name="description"
          rules={[{ required: true, message: 'Please enter a course description.' }]}
        >
          <TextArea
            placeholder="Insert your course description."
            rows={6}
            style={placeholderStyle}
            className="flex-grow mr-2 border-black"
          />
        </Form.Item>

        {/* Languages Dropdown */}
        <Form.Item
          label={<span style={{ fontSize: '18px' }}>Language</span>}
          name="language"
          rules={[{ required: true, message: 'Please enter a course language.' }]}
        >
          <Select placeholder="Select a language" style={placeholderStyle} className="border rounded-md">
            <Option value="english">English</Option>
            <Option value="french">French</Option>
            <Option value="spanish">Spanish</Option>
          </Select>
        </Form.Item>

        {/* Category Dropdown */}
        <Form.Item
          label={<span style={{ fontSize: '18px' }}>Category</span>}
          name="category"
          rules={[{ required: true, message: 'Please enter a course category.' }]}
        >
        <Select placeholder="Select a category" style={placeholderStyle} className="border rounded-md">
          <Option value="8">Business & Management</Option>
          <Option value="3">Cloud Computing & IoT</Option>
          <Option value="4">Cybersecurity</Option>
          <Option value="5">Data Engineering & Analytics</Option>
          <Option value="1">Data Science</Option>
          <Option value="9">Economics</Option>
          <Option value="11">Education</Option>
          <Option value="13">Environmental Science</Option>
          <Option value="12">Health and Wellness</Option>
          <Option value="2">Machine Learning & AI</Option>
          <Option value="7">Networking & Systems</Option>
          <Option value="14">Psychology</Option>
          <Option value="10">Sociology</Option>
          <Option value="6">Software Development & Programming</Option>
        </Select>
        </Form.Item>

        {/* Subcategory Dropdown */}
        <Form.Item
          label={<span style={{ fontSize: '18px' }}>Subcategory</span>}
          name="subcategory"
          rules={[{ required: true, message: 'Please enter a course subCategory.' }]}
        >
          <Select placeholder="Select a subcategory" style={placeholderStyle} className="border rounded-md">
            <Option value="webDevelopment">Web Development</Option>
            <Option value="graphicDesign">Graphic Design</Option>
            <Option value="marketing">Marketing</Option>
            {/* Add more subcategories as needed */}
          </Select>
        </Form.Item>

         {/* Course Image Upload */}
         <Form.Item
          label={<span style={{ fontSize: '18px' }}>Course image</span>}
          name="image"
          rules={[{ required: true, message: 'Please upload a course image.' }]}
        >
          <Upload 
            listType="picture" 
            beforeUpload={() => false} // Prevent auto upload
          >
            <Button className="border border-blue rounded-md text-blue text-base font-bold" icon={<UploadOutlined />}>Upload Course Image</Button>
          </Upload>
        </Form.Item>

        {/* Course Video Upload */}
        <Form.Item
          label={<span style={{ fontSize: '18px' }}>Course video</span>}
          name="video"
          rules={[{ required: true, message: 'Please upload a course video.' }]}
        >
          <Upload 
            beforeUpload={() => false} // Prevent auto upload
            accept="video/*"
          >
            <Button className="border border-blue rounded-md text-blue text-base font-bold" icon={<UploadOutlined />}>Upload Course Video</Button>
          </Upload>
        </Form.Item>

      </Form>
      <Divider />
    </div>
  );
};


const Pricing = ({ form }) => {
  const [isPaid, setIsPaid] = useState(false);

  const handlePriceChange = (value) => {
    setIsPaid(value === 'paid');
  };

  return (
    <section id="anchor-pricing">
      <h2 className="text-2xl font-semibold mb-4">Pricing</h2>
      <p className="text-gray-600 mb-6">
        Set a price for your course. Consider the value you're providing and the price learners are willing to pay.
      </p>

      <Form form={form} layout="vertical">
        {/* Flex container to hold both dropdowns */}
        <div style={{ display: 'flex', gap: '16px' }}>
          <Form.Item
            name="coursePriceType"
            style={{ flex: 1 }}
            rules={[{ required: true, message: 'Please select a course price type.' }]}
          >
            <Select placeholder="Select a price type" onChange={handlePriceChange} style={placeholderStyle} className="border  rounded-md">
              <Select.Option value="free">Free</Select.Option>
              <Select.Option value="paid">Paid</Select.Option>
            </Select>
          </Form.Item>

          {isPaid && (
            <Form.Item
              name="courseSpecificPrice"
              style={{ flex: 1 }}
              rules={[{ required: true, message: 'Please select a specific price for your course.' }]}
            >
              <Select placeholder="Select a specific price" style={placeholderStyle} className="border rounded-md">
                <Select.Option value="19.99">$19.99</Select.Option>
                <Select.Option value="29.99">$29.99</Select.Option>
                <Select.Option value="39.99">$39.99</Select.Option>
                <Select.Option value="49.99">$49.99</Select.Option>
              </Select>
            </Form.Item>
          )}
        </div>
      </Form>

      <Divider />
    </section>
  );
};


const CreateCourse = () => {
  const [intendedLearnersForm] = Form.useForm();
  const [requirementsForm] = Form.useForm();
  const [objectivesForm] = Form.useForm();
  const [curriculumForm] = Form.useForm();
  const [landingPageForm] = Form.useForm();
  const [pricingForm] = Form.useForm();

  const handleSubmit = () => {
    const forms = [
      intendedLearnersForm,
      requirementsForm,
      objectivesForm,
      curriculumForm,
      landingPageForm,
      pricingForm,
    ];

    Promise.all(forms.map((form) => form.validateFields()))
      .then((values) => {
        const allValues = values.reduce((acc, curr) => ({ ...acc, ...curr }), {});
        console.log('All forms validated:', allValues);
        // Submit all data here
      })
      .catch((errorInfo) => {
        console.error('Validation failed:', errorInfo);
      });
  };

  const [loading, setLoading] = useState(false);

  const handleCreateCourse = async (values) => {
    setLoading(true);
    try {
      const { instructorId1, instructorId2, title, subTitle, description, image, video, subCategoryId, categoryId, language, price } = values;
      const courseId = await InstructorService.createCourse(instructorId1, NULL, title, subTitle, description, image, video, subCategoryId, categoryId, language, price);

      if (courseId) {
        message.success("Course created successfully!");
        form.resetFields();
      }
    } catch (error) {
      message.error("Failed to create course.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex">
      <Sidebar onSubmit={handleSubmit} />
      <div className="w-3/4 p-12 bg-white shadow-lg">
        <IntendedLearners form={intendedLearnersForm} />
        <CourseRequirements form={requirementsForm} />
        <CourseObjectives form={objectivesForm} />
        <Curriculum form={curriculumForm} />
        <CourseLandingPage form={landingPageForm} />
        <Pricing form={pricingForm} />
      </div>
    </div>
  );
};

export default CreateCourse;