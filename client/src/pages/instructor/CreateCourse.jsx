import React, { useState } from "react";
import { Input, Button, Divider, Anchor, Select } from "antd";
import { MinusCircleOutlined, PlusOutlined } from '@ant-design/icons';

const handleClick = (e, link) => {
  e.preventDefault();
  console.log(link);
};
const Sidebar = () => (
  <div className="w-1/4 bg-white p-6 shadow-md">
    <div className="text-xl font-semibold mb-4">Plan your course</div>
    <Anchor
      affix={false}
      onClick={handleClick}
      items={[
        {
          key: '1',
          href: '#anchor-intended-learner',
          title: 'Intended learners',
        },
        {
          key: '2',
          href: '#anchor-requirement',
          title: 'Course Requirements',
        },
        {
          key: '3',
          href: '#anchor-objective',
          title: 'Course Objectives',
        },
        {
          key: '4',
          href: '#anchor-curriculum',
          title: 'Curriculum',
        },
        {
          key: '5',
          href: '#anchor-landing-page',
          title: 'Course landing page',
        },
        {
          key: '6',
          href: '#anchor-pricing',
          title: 'Pricing',
        },
      ]}
    />
    <Button type="primary" className="mt-6 w-full">
      Submit for Review
    </Button>
  </div>
);


const IntendedLearners = () => {
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

      {learners.map((learner, index) => (
        <div key={index} className="flex items-center mb-4">
          <Input
            value={learner}
            placeholder={`Learner description ${index + 1}`}
            onChange={(e) => handleLearnerChange(index, e.target.value)}
            className="flex-grow mr-2"
          />
          {learners.length > 1 && (
            <MinusCircleOutlined
              onClick={() => removeLearner(index)}
              style={{ fontSize: '20px', color: 'red' }}
            />
          )}
        </div>
      ))}

      <Button type="dashed" onClick={addLearner} className="w-full">
        Add more to your response
      </Button>

      <Divider />
    </section>
  );
};


const CourseRequirements = () => {
  // Initialize with 4 input fields
  const initialRequirements = Array(1).fill("");
  const [requirements, setRequirements] = useState(initialRequirements);

  // Add a new input field
  const addRequirement= () => {
    setRequirements([...requirements, ""]);
  };

  // Handle input change
  const handleRequirementChange = (index, value) => {
    const newRequirements = [...requirements];
    newRequirements[index] = value;
    setRequirements(newRequirements);
  };

  // Remove an input field, but ensure at least 4 remain
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
    List the required skills, experience, tools or equipment learners should have prior to taking your course.
    If there are no requirements, use this space as an opportunity to lower the barrier for beginners.
    </p>

      {requirements.map((requirement, index) => (
        <div key={index} className="flex items-center mb-4">
          <Input
            value={requirement}
            placeholder={`Course requirement ${index + 1}`}
            onChange={(e) => handleRequirementChange(index, e.target.value)}
            className="flex-grow mr-2"
          />
          {requirements.length > 1 && (
            <MinusCircleOutlined
              onClick={() => removeRequirement(index)}
              style={{ fontSize: '20px', color: 'red' }}
            />
          )}
        </div>
      ))}

      <Button type="dashed" onClick={addRequirement} className="w-full">
        Add more to your response
      </Button>

      <Divider />
    </section>
  );
};


const CourseObjectives = () => {
  // Initialize with 4 input fields
  const initialObjectives = Array(4).fill("");
  const [objectives, setObjectives] = useState(initialObjectives);

  // Add a new input field
  const addObjective = () => {
    setObjectives([...objectives, ""]);
  };

  // Handle input change
  const handleObjectiveChange = (index, value) => {
    const newObjectives = [...objectives];
    newObjectives[index] = value;
    setObjectives(newObjectives);
  };

  // Remove an input field, but ensure at least 4 remain
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

      {objectives.map((objective, index) => (
        <div key={index} className="flex items-center mb-4">
          <Input
            value={objective}
            placeholder={`Course objective ${index + 1}`}
            onChange={(e) => handleObjectiveChange(index, e.target.value)}
            className="flex-grow mr-2"
          />
          {objectives.length > 4 && (
            <MinusCircleOutlined
              onClick={() => removeObjective(index)}
              style={{ fontSize: '20px', color: 'red' }}
            />
          )}
        </div>
      ))}

      <Button type="dashed" onClick={addObjective} className="w-full">
        Add more to your response
      </Button>

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

  return (
    <div>
      <section id="anchor-curriculum">
      <h2 className="text-2xl font-semibold mb-4">Curriculum</h2>
      <p className="text-gray-600 mb-6">
      Start putting together your course by creating sections, lectures and practice activities 
      </p>

      {sections.map((section, sectionIndex) => (
        <div key={sectionIndex} className="mb-4 p-4 border rounded">
          <div className="flex justify-between items-center mb-2">
            <Input
              placeholder="Section title"
              value={section.title}
              onChange={(e) => handleSectionTitleChange(sectionIndex, e.target.value)}
              className="flex-grow mr-2"
            />
            {sections.length > 1 && (
              <MinusCircleOutlined
                onClick={() => removeSection(sectionIndex)}
                style={{ fontSize: '20px', color: 'red' }}
              />
            )}
          </div>

          {section.lessons.map((lesson, lessonIndex) => (
            <div key={lessonIndex} className="mb-2 p-2 border rounded">
              <div className="flex justify-between items-center mb-2">
                <Input
                  placeholder={`${lesson.type === 'lecture' ? 'Lecture' : 'Quiz'} title`}
                  value={lesson.title}
                  onChange={(e) => handleLessonTitleChange(sectionIndex, lessonIndex, e.target.value)}
                  className="flex-grow"
                />
                <span className="ml-2">
                  {lesson.type === 'lecture' ? 'Lecture' : 'Quiz'}
                </span>
              </div>
              {section.lessons.length > 1 && (
                <MinusCircleOutlined
                  onClick={() => removeLesson(sectionIndex, lessonIndex)}
                  style={{ fontSize: '20px', color: 'red' }}
                />
              )}
              <Button>+ Content</Button>
            </div>
          ))}

          <div className="flex justify-start mb-2">
            <Select
              placeholder="Select lesson type"
              style={{ width: 200 }}
              onChange={(value) => addLesson(sectionIndex, value)}
            >
              <Option value="lecture">Lecture</Option>
              <Option value="quiz">Quiz</Option>
            </Select>
          </div>
        </div>
      ))}
      </section>
      <Button type="dashed" onClick={addSection} className="w-full">
        + Section
      </Button>
    </div>
  );
};

const CourseLandingPage = () => (
  <section id="anchor-landing-page">
    <h2 className="text-2xl font-semibold mb-4">Course Landing Page</h2>
    <p className="text-gray-600 mb-6">
      Description and details of the course landing page.
    </p>
    {/* Add more content specific to Course Landing Page */}
    <Divider />
  </section>
);

const Pricing = () => (
  <section id="anchor-pricing">
    <h2 className="text-2xl font-semibold mb-4">Pricing</h2>
    <p className="text-gray-600 mb-6">
      Information about pricing options for the course.
    </p>
    {/* Add more content specific to Pricing */}
    <Divider />
  </section>
);

const MainContent = () => {
  return (
    <div className="w-3/4 p-6">
      <IntendedLearners />
      <CourseRequirements />
      <CourseObjectives />
      <Curriculum />
      <CourseLandingPage />
      <Pricing />
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