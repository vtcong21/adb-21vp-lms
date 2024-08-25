import { Table, Space, Progress, Input, Button, Typography, Card } from "antd";
import { SearchOutlined } from '@ant-design/icons';
import Highlighter from 'react-highlight-words';
import React, { useState, useEffect, useRef } from "react";

// {
//     "courseId": 1,
//     "learnerId": "LN001",
//     "learnerName": "Alice Smith",
//     "learnerScore": 7.5,
//     "completionPercentInCourse": 85.00
// },

const { Title } = Typography

const course = {
    "id": 1,
    "title": "Artificial Intelligence for Beginners",
    "subTitle": "Manage projects effectively.",
    "description": "Discover the basics of digital marketing and how to effectively promote your business online.",
    "image": "https://example.com/images/course26.jpg",
    "video": "https://example.com/videos/course66.mp4",
    "state": "public",
    "numberOfStudents": 361,
    "numberOfLectures": 38,
    "totalTime": 93.06,
    "averageRating": 2.82,
    "ratingCount": 475,
    "subCategoryId": 3,
    "categoryId": 7,
    "totalRevenue": 41038.4,
    "revenueByMonth": 3240.71,
    "language": "Japanese",
    "price": 82.99,
    "lastUpdateTime": "2024-03-10T10:57:14.084116"
};

const LearnerList = () => {
    const [learners, setLearners] = useState([]);

    // search button
    const [searchText, setSearchText] = useState('');
    const [searchedColumn, setSearchedColumn] = useState('');
    const searchInput = useRef(null);
    const handleSearch = (selectedKeys, confirm, dataIndex) => {
        confirm();
        setSearchText(selectedKeys[0]);
        setSearchedColumn(dataIndex);
    };
    const handleReset = (clearFilters) => {
        clearFilters();
        setSearchText('');
    };
    const getColumnSearchProps = (dataIndex) => ({
        filterDropdown: ({ setSelectedKeys, selectedKeys, confirm, clearFilters, close }) => (
        <div
            style={{
            padding: 8,
            }}
            onKeyDown={(e) => e.stopPropagation()}
        >
            <Input
            ref={searchInput}
            placeholder={`Search ${dataIndex}`}
            value={selectedKeys[0]}
            onChange={(e) => setSelectedKeys(e.target.value ? [e.target.value] : [])}
            onPressEnter={() => handleSearch(selectedKeys, confirm, dataIndex)}
            style={{
                marginBottom: 8,
                display: 'block',
            }}
            />
            <Space>
            <Button
                type="primary"
                onClick={() => handleSearch(selectedKeys, confirm, dataIndex)}
                icon={<SearchOutlined />}
                size="small"
                style={{
                width: 90,
                }}
            >
                Search
            </Button>
            <Button
                onClick={() => clearFilters && handleReset(clearFilters)}
                size="small"
                style={{
                width: 90,
                }}
            >
                Reset
            </Button>
            <Button
                type="link"
                size="small"
                onClick={() => {
                confirm({
                    closeDropdown: false,
                });
                setSearchText(selectedKeys[0]);
                setSearchedColumn(dataIndex);
                }}
            >
                Filter
            </Button>
            <Button
                type="link"
                size="small"
                onClick={() => {
                close();
                }}
            >
                close
            </Button>
            </Space>
        </div>
        ),
        filterIcon: (filtered) => (
        <SearchOutlined
            style={{
            color: filtered ? '#1677ff' : undefined,
            }}
        />
        ),
        onFilter: (value, record) =>
        record[dataIndex].toString().toLowerCase().includes(value.toLowerCase()),
        onFilterDropdownOpenChange: (visible) => {
        if (visible) {
            setTimeout(() => searchInput.current?.select(), 100);
        }
        },
        render: (text) =>
        searchedColumn === dataIndex ? (
            <Highlighter
            highlightStyle={{
                backgroundColor: '#ffc069',
                padding: 0,
            }}
            searchWords={[searchText]}
            autoEscape
            textToHighlight={text ? text.toString() : ''}
            />
        ) : (
            text
        ),
    });
    // table
    const columns = [
        {
          title: 'Learner ID',
          dataIndex: 'learnerId',
          render: (text) => <a>{text}</a>,
          ...getColumnSearchProps('learnerId')
        },
        {
            title: 'Learner\'s name',
            dataIndex: 'learnerName',
            ...getColumnSearchProps('learnerName')
        },
        {
            title: 'Learner\'s Score',
            dataIndex: 'learnerScore',
            sorter: (a, b) => a.learnerScore - b.learnerScore,
        },
        {
            title: 'Completion Percentage',
            dataIndex: 'completionPercentInCourse',
            sorter: (a, b) => a.completionPercentInCourse - b.completionPercentInCourse,
            render: (value) => <Progress percent={value} />
        },
      ];
    
    useEffect(() => {
        fetch('./json/tmp_learnerEnrollCourse.json')
        .then(response => response.json())
        .then(data => setLearners(data))
        .catch(error => console.error('Error displaying Admin/Instructor\'s Course Learner list: ', error))
    }, [])

    return (
        <>
            <Title level={2}>
                Learner List for Course {course.id}
            </Title>
            <Table 
                columns={columns}
                dataSource={learners}
                pagination={{
                    position: ['bottomCenter'],
                }}
                rowKey='learnerId'
            />
        </>
    )
}

export default LearnerList;