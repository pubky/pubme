const start = require('./src/server');
require('dotenv').config();

const HOST = 'localhost'; // process.env.HOST;
const PORT = 3000; //process.env.PORT;

if (!HOST || !PORT) {
    console.error('HOST or PORT environment variable is not set');
    process.exit(1);
}

start({host: HOST, port: PORT}).then(() => {
    console.log("Server started");
}).catch((error) => {
    console.error(error);
    process.exit(1);
});
