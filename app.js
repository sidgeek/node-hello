var http = require("http");
var fs = require("fs");

const config = require('config');
const port = config.get('port');

http.createServer(function(request, response) {
  if (request.url == "/demo") {
    fs.readFile("./1.html", function(err, data) {
      response.writeHead(200, {"Content-type": "text/html"})
      response.end(data)
    })
  }
}).listen(port);

console.log(`Server is running on port: ${port}`);