

import React, { useRef, useEffect, useState } from 'react';
import { Space, Table, Tag, Button, Input, message } from 'antd';
import {
  CheckCircleOutlined,
  SyncOutlined,
  SearchOutlined,
  EditOutlined
} from '@ant-design/icons'
import Highlighter from 'react-highlight-words';
import OnlineService from '../../services/public';
import { useNavigate } from 'react-router-dom';

const AdminCourses = () => {
  const [course, setCourse] = useState([]);
  const [searchText, setSearchText] = useState('');
  const [searchedColumn, setSearchedColumn] = useState('');
  const searchInput = useRef(null);
  const states = ['public', 'pendingReview', 'draft'];
  const navigate = useNavigate();

  const handleSearch = (selectedKeys, confirm, dataIndex) => {
    confirm();
    setSearchText(selectedKeys[0]);
    setSearchedColumn(dataIndex);
  };
  const handleReset = (clearFilters) => {
    clearFilters();
    setSearchText('');
  };
  const handleEditCourse = (record) => {
    navigate(`/admin/courses/${record.courseId}`, { state: { 'courseId': record.courseId, 'state': record.state, } })
  } 

  useEffect(() => {
    setCourse([]);

    const fetchCourseData = async ( searchText, state ) => {
      try {
        const res = await OnlineService.getCourseByName( searchText , state )
        const resWithState = await res.map((data, row) => ({
          ...data,
          key: row,
          state: state
        }));
        setCourse(course => [...course, ...resWithState])
      } catch (error) {
        message.error("Cannot load course revenue data.");
      }
    };

    states.map(state => {
      fetchCourseData((searchText === '') ? 'advanced' : searchText, state );
    })
    console.log(course);
  }, [searchText]);

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

  const columns = [
    {
      title: 'Course ID',
      dataIndex: 'courseId',
    },
    {
      title: 'Title',
      dataIndex: 'title',
      render: (text) => <a>{text}</a>,
      ...getColumnSearchProps('title')
    },
    {
      title: 'Last Update',
      dataIndex: 'lastUpdateTime',
      render: (lastUpdateTime) => {
        const formattedDate = new Date(lastUpdateTime).toLocaleString()
        return <>{formattedDate}</>
      },
      sorter: (a, b) => {
        const dateA = new Date(a.lastUpdateTime)
        const dateB = new Date(b.lastUpdateTime)
        return dateA - dateB;
      }
    },
    {
      title: 'State',
      dataIndex: 'state',
      filters: [
        {
          text: 'Pending Review',
          value: 'pendingReview'
        },
        {
          text: 'Draft',
          value: 'draft'
        },
        {
          text: 'Public',
          value: 'public'
        }
      ],
      filterMode: 'menu',
      onFilter: (value, record) => record.state === value,
      render: (state) => {
        if (state === 'pendingReview') {
          state = 'pending review';
        }
    
        let color = 'blue';
        if (state === 'pending review') {
          color = 'red';
        } else if (state === 'public') {
          color = 'green';
        } else if (state === 'draft') {
          color = 'default'
        }

        let icon = <></>;
        if (state === 'pending review') {
          icon = <SyncOutlined spin/>;
        } else if (state === 'public') {
          icon = <CheckCircleOutlined/>;
        }

        return (
          <Tag color={color} key={state} icon={icon} bordered={false}>
            {state.toUpperCase()}
          </Tag>
        );
      },
    },  
    {
      title: 'Action',
      render: (_, record) => (
        <Space type='middle'>
          <Button 
          icon={<EditOutlined/>}
          onClick={() => handleEditCourse(record)}
          />
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Table
        columns={columns}
        pagination={{
          position: ['bottomCenter'],
        }}
        dataSource={course}
        rowKey={record => record.courseId}
      />
    </div>
  );
};
export default AdminCourses;
