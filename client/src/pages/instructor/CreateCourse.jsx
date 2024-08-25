import "../../assets/styles/instructor.css";
import React, { useState, useEffect } from "react";
import { Input, Button, Divider, Form, Select, Upload, message, Anchor } from "antd";
import { MinusCircleOutlined, UploadOutlined } from '@ant-design/icons';
import InstructorService from '../../services/instructor';
import { useSelector } from 'react-redux';

const placeholderStyle = {
  fontSize: '18px', 
  color: 'black',
};

const categories = [
  { id: 8, name: 'Business & Management' },
  { id: 3, name: 'Cloud Computing & IoT' },
  { id: 4, name: 'Cybersecurity' },
  { id: 5, name: 'Data Engineering & Analytics' },
  { id: 1, name: 'Data Science' },
  { id: 9, name: 'Economics' },
  { id: 11, name: 'Education' },
  { id: 13, name: 'Environmental Science' },
  { id: 12, name: 'Health and Wellness' },
  { id: 2, name: 'Machine Learning & AI' },
  { id: 7, name: 'Networking & Systems' },
  { id: 14, name: 'Psychology' },
  { id: 10, name: 'Sociology' },
  { id: 6, name: 'Software Development & Programming' }
];


const subcategories = [
  { id: 15, idParent: 14, name: 'Abnormal Psychology' },
  { id: 10, idParent: 11, name: 'Adult Education' },
  { id: 12, idParent: 2, name: 'Advanced Computational Techniques' },
  { id: 6, idParent: 6, name: 'Advanced Programming' },
  { id: 2, idParent: 13, name: 'Agricultural Analytics' },
  { id: 18, idParent: 9, name: 'Agricultural Economics' },
  { id: 10, idParent: 2, name: 'AI in Healthcare' },
  { id: 13, idParent: 2, name: 'AI in Robotics' },
  { id: 9, idParent: 2, name: 'AI-driven Decision Making' },
  { id: 7, idParent: 6, name: 'Algorithm Design' },
  { id: 2, idParent: 2, name: 'Artificial Intelligence' },
  { id: 6, idParent: 2, name: 'Artificial Neural Networks' },
  { id: 1, idParent: 6, name: 'Augmented Reality' },
  { id: 9, idParent: 9, name: 'Behavioral Economics' },
  { id: 4, idParent: 14, name: 'Behavioral Psychology' },
  { id: 2, idParent: 5, name: 'Big Data' },
  { id: 1, idParent: 4, name: 'Bioinformatics' },
  { id: 3, idParent: 6, name: 'Blockchain' },
  { id: 1, idParent: 8, name: 'Business Analysis' },
  { id: 6, idParent: 5, name: 'Business Intelligence' },
  { id: 4, idParent: 8, name: 'Business Process Management' },
  { id: 4, idParent: 13, name: 'Climate Change' },
  { id: 3, idParent: 14, name: 'Clinical Psychology' },
  { id: 12, idParent: 12, name: 'Clinical Research' },
  { id: 1, idParent: 3, name: 'Cloud Computing' },
  { id: 2, idParent: 3, name: 'Cloud Security' },
  { id: 3, idParent: 3, name: 'Cloud Storage Solutions' },
  { id: 1, idParent: 14, name: 'Cognitive Psychology' },
  { id: 25, idParent: 10, name: 'Community Studies' },
  { id: 10, idParent: 13, name: 'Conservation Biology' },
  { id: 2, idParent: 9, name: 'Content Management Systems' },
  { id: 14, idParent: 14, name: 'Counseling Psychology' },
  { id: 7, idParent: 10, name: 'Criminal Sociology' },
  { id: 5, idParent: 10, name: 'Cultural Sociology' },
  { id: 3, idParent: 11, name: 'Curriculum Development' },
  { id: 5, idParent: 8, name: 'Customer Relationship Management' },
  { id: 2, idParent: 4, name: 'Cybersecurity' },
  { id: 1, idParent: 1, name: 'Data Analysis' },
  { id: 2, idParent: 1, name: 'Data Analytics' },
  { id: 5, idParent: 1, name: 'Data Engineering' },
  { id: 8, idParent: 1, name: 'Data Governance' },
  { id: 4, idParent: 1, name: 'Data Mining' },
  { id: 7, idParent: 1, name: 'Data Privacy' },
  { id: 6, idParent: 1, name: 'Data Science' },
  { id: 3, idParent: 1, name: 'Data Visualization' },
  { id: 9, idParent: 1, name: 'Data Warehousing' },
  { id: 5, idParent: 7, name: 'Database Management' },
  { id: 5, idParent: 4, name: 'Database Security' },
  { id: 3, idParent: 2, name: 'Deep Learning' },
  { id: 8, idParent: 9, name: 'Development Economics' },
  { id: 2, idParent: 14, name: 'Developmental Psychology' },
  { id: 17, idParent: 10, name: 'Deviance and Social Control' },
  { id: 3, idParent: 9, name: 'Digital Marketing' },
  { id: 31, idParent: 10, name: 'Digital Sociology' },
  { id: 8, idParent: 11, name: 'Early Childhood Education' },
  { id: 6, idParent: 13, name: 'Ecology' },
  { id: 4, idParent: 9, name: 'E-commerce Analytics' },
  { id: 15, idParent: 9, name: 'Econometrics' },
  { id: 21, idParent: 10, name: 'Economic Sociology' },
  { id: 5, idParent: 9, name: 'Economic Theory' },
  { id: 6, idParent: 11, name: 'Education Policy' },
  { id: 1, idParent: 11, name: 'Educational Data Mining' },
  { id: 11, idParent: 11, name: 'Educational Leadership' },
  { id: 2, idParent: 11, name: 'Educational Psychology' },
  { id: 1, idParent: 13, name: 'Energy Management' },
  { id: 13, idParent: 13, name: 'Environmental Chemistry' },
  { id: 11, idParent: 1, name: 'Environmental Data Analysis' },
  { id: 14, idParent: 9, name: 'Environmental Economics' },
  { id: 7, idParent: 13, name: 'Environmental Policy' },
  { id: 17, idParent: 14, name: 'Environmental Psychology' },
  { id: 3, idParent: 13, name: 'Environmental Science' },
  { id: 2, idParent: 12, name: 'Epidemiology' },
  { id: 11, idParent: 2, name: 'Ethical AI Practices' },
  { id: 3, idParent: 4, name: 'Ethical Hacking' },
  { id: 15, idParent: 10, name: 'Ethnography' },
  { id: 16, idParent: 14, name: 'Experimental Psychology' },
  { id: 11, idParent: 10, name: 'Family Sociology' },
  { id: 7, idParent: 5, name: 'Financial Analytics' },
  { id: 11, idParent: 9, name: 'Financial Economics' },
  { id: 8, idParent: 5, name: 'Financial Modeling' },
  { id: 8, idParent: 14, name: 'Forensic Psychology' },
  { id: 8, idParent: 2, name: 'Fuzzy Logic' },
  { id: 10, idParent: 10, name: 'Gender Studies' },
  { id: 7, idParent: 2, name: 'Genetic Algorithms' },
  { id: 4, idParent: 12, name: 'Global Health' },
  { id: 13, idParent: 10, name: 'Globalization Studies' },
  { id: 26, idParent: 10, name: 'Health and Society' },
  { id: 10, idParent: 1, name: 'Health Data Analysis' },
  { id: 17, idParent: 9, name: 'Health Economics' },
  { id: 11, idParent: 12, name: 'Health Informatics' },
  { id: 3, idParent: 12, name: 'Health Policy' },
  { id: 7, idParent: 12, name: 'Health Promotion' },
  { id: 9, idParent: 14, name: 'Health Psychology' },
  { id: 9, idParent: 12, name: 'Healthcare Ethics' },
  { id: 6, idParent: 12, name: 'Healthcare Management' },
  { id: 13, idParent: 12, name: 'Healthcare Technology' },
  { id: 7, idParent: 11, name: 'Higher Education' },
  { id: 16, idParent: 9, name: 'Industrial Organization' },
  { id: 11, idParent: 14, name: 'Industrial-Organizational Psychology' },
  { id: 6, idParent: 4, name: 'Information Retrieval' },
  { id: 4, idParent: 11, name: 'Instructional Design' },
  { id: 10, idParent: 9, name: 'International Trade' },
  { id: 5, idParent: 3, name: 'IoT Applications' },
  { id: 4, idParent: 3, name: 'IoT Security' },
  { id: 3, idParent: 7, name: 'IT Infrastructure' },
  { id: 13, idParent: 9, name: 'Labor Economics' },
  { id: 6, idParent: 8, name: 'Logistics Management' },
  { id: 1, idParent: 2, name: 'Machine Learning' },
  { id: 12, idParent: 6, name: 'Machine Vision' },
  { id: 6, idParent: 9, name: 'Macroeconomics' },
  { id: 11, idParent: 13, name: 'Marine Biology' },
  { id: 14, idParent: 12, name: 'Medical Sociology' },
  { id: 5, idParent: 12, name: 'Mental Health' },
  { id: 7, idParent: 9, name: 'Microeconomics' },
  { id: 19, idParent: 10, name: 'Migration Studies' },
  { id: 9, idParent: 13, name: 'Natural Resource Management' },
  { id: 4, idParent: 4, name: 'Network Security' },
  { id: 1, idParent: 7, name: 'Networking' },
  { id: 5, idParent: 14, name: 'Neuroscience' },
  { id: 8, idParent: 12, name: 'Nutrition and Wellness' },
  { id: 8, idParent: 6, name: 'Optimization' },
  { id: 9, idParent: 6, name: 'Optimization Techniques' },
  { id: 5, idParent: 11, name: 'Pedagogical Methods' },
  { id: 12, idParent: 14, name: 'Personality Psychology' },
  { id: 10, idParent: 12, name: 'Pharmaceutical Sciences' },
  { id: 8, idParent: 10, name: 'Political Sociology' },
  { id: 10, idParent: 14, name: 'Positive Psychology' },
  { id: 4, idParent: 2, name: 'Predictive Analytics' },
  { id: 3, idParent: 5, name: 'Predictive Modeling' },
  { id: 5, idParent: 6, name: 'Programming' },
  { id: 2, idParent: 8, name: 'Project Management' },
  { id: 6, idParent: 14, name: 'Psychological Assessment' },
  { id: 7, idParent: 14, name: 'Psychotherapy' },
  { id: 12, idParent: 9, name: 'Public Economics' },
  { id: 1, idParent: 12, name: 'Public Health' },
  { id: 5, idParent: 5, name: 'Quantitative Analysis' },
  { id: 29, idParent: 10, name: 'Race and Ethnicity Studies' },
  { id: 9, idParent: 3, name: 'Real-Time Data Processing' },
  { id: 15, idParent: 12, name: 'Rehabilitation Sciences' },
  { id: 5, idParent: 2, name: 'Reinforcement Learning' },
  { id: 8, idParent: 13, name: 'Renewable Energy' },
  { id: 1, idParent: 9, name: 'Retail Analytics' },
  { id: 1, idParent: 10, name: 'Sentiment Analysis' },
  { id: 6, idParent: 3, name: 'Smart Cities' },
  { id: 7, idParent: 3, name: 'Smart Technologies' },
  { id: 30, idParent: 10, name: 'Social Capital' },
  { id: 14, idParent: 10, name: 'Social Change' },
  { id: 27, idParent: 10, name: 'Social Impact Assessment' },
  { id: 24, idParent: 10, name: 'Social Inequality' },
  { id: 20, idParent: 10, name: 'Social Movements' },
  { id: 2, idParent: 10, name: 'Social Network Analysis' },
  { id: 16, idParent: 10, name: 'Social Networks' },
  { id: 18, idParent: 10, name: 'Social Policy' },
  { id: 22, idParent: 10, name: 'Social Psychology' },
  { id: 9, idParent: 10, name: 'Social Stratification' },
  { id: 3, idParent: 10, name: 'Social Theory' },
  { id: 4, idParent: 10, name: 'Sociological Research Methods' },
  { id: 12, idParent: 10, name: 'Sociology of Education' },
  { id: 23, idParent: 10, name: 'Sociology of Religion' },
  { id: 32, idParent: 10, name: 'Sociology of the Family' },
  { id: 28, idParent: 10, name: 'Sociology of Work' },
  { id: 4, idParent: 6, name: 'Software Development' },
  { id: 1, idParent: 5, name: 'Spatial Data Analysis' },
  { id: 9, idParent: 11, name: 'Special Education' },
  { id: 13, idParent: 14, name: 'Sports Psychology' },
  { id: 4, idParent: 5, name: 'Statistical Methods' },
  { id: 3, idParent: 8, name: 'Supply Chain Management' },
  { id: 5, idParent: 13, name: 'Sustainability Studies' },
  { id: 4, idParent: 7, name: 'System Integration' },
  { id: 2, idParent: 7, name: 'Systems Analysis' },
  { id: 10, idParent: 6, name: 'Text Mining' },
  { id: 11, idParent: 6, name: 'Time Series Analysis' },
  { id: 12, idParent: 13, name: 'Urban Ecology' },
  { id: 19, idParent: 9, name: 'Urban Economics' },
  { id: 6, idParent: 10, name: 'Urban Sociology' },
  { id: 2, idParent: 6, name: 'Virtual Reality' },
  { id: 8, idParent: 3, name: 'Virtualization Technologies' }
];


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
            name={`learners[${index}]`}  // Đảm bảo `name` đúng với cách truy xuất dữ liệu
            rules={[{ required: true, message: 'Please enter a description for the learner.' }]}
          >
            <div className="flex items-center">
              <Input
                value={learner}
                placeholder={`Learner description ${index + 1}`}
                style={{ placeholderStyle }}
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

const Curriculum = ({ form }) => {
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

const CourseLandingPage = ({ form }) => {

  const [subcategoryOptions, setSubcategoryOptions] = useState([]);
  const [isSubcategoryDisabled, setIsSubcategoryDisabled] = useState(true);

  const handleCategoryChange = (categoryId) => {
    const filteredSubcategories = subcategories.filter(
      (subcat) => subcat.idParent === categoryId
    );
    setSubcategoryOptions(filteredSubcategories);
    setIsSubcategoryDisabled(false); // Enable subcategory dropdown
  };

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
          name="category"
          label={<span style={{ fontSize: '18px' }}>Category</span>}
          rules={[{ required: true, message: 'Please select a course category.' }]}
        >
          <Select
            placeholder="Select a category"
            onChange={handleCategoryChange}
            style={{ width: '100%' }}
          >
            {categories.map((cat) => (
              <Option key={cat.id} value={cat.id}>
                {cat.name}
              </Option>
            ))}
          </Select>
        </Form.Item>

        <Form.Item
          name="subcategory"
          label={<span style={{ fontSize: '18px' }}>Subcategory</span>}
          rules={[{ required: true, message: 'Please select a subcategory.' }]}
        >
          <Select
            placeholder="Select a subcategory"
            disabled={isSubcategoryDisabled}
            style={{ width: '100%' }}
          >
            {subcategoryOptions.map((subcat) => (
              <Option key={subcat.id} value={subcat.id}>
                {subcat.name}
              </Option>
            ))}
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

  const userId = useSelector((state) => state.user.userId);

  const handleSubmit = async () => {
    try {
      // Validate each form separately if needed
      const intendedLearnersValues = await intendedLearnersForm.validateFields();
      const requirementsValues = await requirementsForm.validateFields();
      const objectivesValues = await objectivesForm.validateFields();
      // const curriculumValues = await curriculumForm.validateFields();
      const landingPageValues = await landingPageForm.validateFields();
      const pricingValues = await pricingForm.validateFields();
      console.log(landingPageValues.video);

      const courseData = {
        title: landingPageValues.title,
        subtitle: landingPageValues.subtitle,
        description: landingPageValues.description,
        language: landingPageValues.language,
        category: landingPageValues.category, 
        subcategory: 1,//landingPageValues.subcategory,
        price: pricingValues.coursePriceType === 'paid' ? pricingValues.courseSpecificPrice : 'Free',
        // image: landingPageValues.image ? landingPageValues.image.fileList[0].originFileObj : null,
        // video: landingPageValues.video ? landingPageValues.video.fileList[0].originFileObj : null,
        // learners: intendedLearnersValues.learners, // Assuming you have learners data gathered from the form
        // requirements: requirementsValues.requirements, // Assuming you have requirements data gathered from the form
        // objectives: objectivesValues.objectives, // Assuming you have objectives data gathered from the form
        // curriculum: curriculumValues.sections, // Assuming you have curriculum data gathered from the form
        instructorId1: userId // Adding userId to course data
      };

      await InstructorService.createCourse(courseData);
      message.success("Course submitted successfully!");
    } catch (error) {
      console.error("Failed to submit course:", error);
      message.error("Failed to submit course. Please try again.");
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