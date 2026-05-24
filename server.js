const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({
    message: 'Secure App is Running!',
    port: 3000
  });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});