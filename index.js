const { createServer } = require("./src/server");

const port = Number(process.env.PORT || 3000);
const server = createServer();

server.listen(port, () => {
  console.log(`Backend API is running on http://localhost:${port}`);
});
