var express = require('express');
var router = express.Router();

var { getPool } = require('../config/database.js');
const pool =  getPool("QTV");

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

module.exports = router;
