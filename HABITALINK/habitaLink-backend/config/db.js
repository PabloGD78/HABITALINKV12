// db.js - CÓDIGO FINAL CORREGIDO

const mysql = require('mysql2');

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',          // si usas XAMPP suele estar vacío
  database: 'habitalink', // DEBE existir y coincidir exactamente
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool.promise();
