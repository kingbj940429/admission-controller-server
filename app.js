const bodyParser = require('body-parser');
const express = require('express');
const fs = require('fs');
const https = require('https');

const app = express()
app.use(bodyParser.json());

const port = 8443

const options = {
  ca: fs.readFileSync('ca.crt'),
  cert: fs.readFileSync('server.crt'),
  key: fs.readFileSync('server.key')
}

app.get('/health', (req, res) => {
  res.send('ok');
});

app.post('/', (req, res) => {
  if (req.body.request === undefined) {
    res.status(400).send();
  }

  console.log(req.body);

  const {request: {uid}} = req.body;

  res.send(
      {
        "apiVersion": "admission.k8s.io/v1",
        "kind": "AdmissionReview",
        "response": {
          uid,
          "allowed": validate(req)
        }
      }
  )

});

function validate(req) {
  if (req.body['request']['object']['kind'] == 'Pod' && req.body['request']['operation'] == 'CREATE') {
    return false
  } else {
    return true
  }
}

const server = https.createServer(options, app)

server.listen(port, () => {
  console.log(`Server running ${port}`);
})