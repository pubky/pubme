const axios = require('axios');

const server = 'http://0.0.0.0:3000';

const test = async () => {
    // Generate keypair
    let response = await axios.post(`${server}/generate-key-pair`, {});
    if (response.status !== 200) {
        throw new Error('POST /generate-key-pair failed');
    }

    const { secretKey, publicKey } = response.data;

    console.log('✅ Key pair');
    console.log(`Secret key: ${secretKey}`);
    console.log(`Public key: ${publicKey}`);

    //Signup
    response = await axios.post(`${server}/signup`, {
        secretKey
    });
    if (response.status !== 200) {
        throw new Error('POST /signup failed');
    }

    console.log('✅ Signup');

    const chatId = 'public-chat-1';
    const testMessage = 'Hey chat store ' + new Date().toISOString();
  
    // Save data
    response = await axios.post(`${server}/put`, {
        publicKey,
        chatId,
        body: {
            message: testMessage
        }
    });
    if (response.status !== 200) {
        throw new Error('PUT /put failed');
    }

    console.log('✅ Data saved');

    // Get data from public key
    response = await axios.get(`${server}/get?publicKey=${publicKey}&chatId=${chatId}`);
    if (response.status !== 200) {
        throw new Error('GET /get failed');
    }

    const data = response.data;
    if (data.message !== testMessage) {
        throw new Error('Data mismatch');
    }

    console.log('✅ Data retrieved');
    console.log(`Data: ${JSON.stringify(data)}`);
  
    // Test delete chat
    response = await axios.post(`${server}/delete`, {
        publicKey,
        chatId
    });
    if (response.status !== 200) {
        throw new Error('DELETE /delete failed');
    }

    console.log('✅ Data deleted');
};

test()
    .then(() => {
        console.log("✅✅✅Test Success");
    }).catch((error) => {
        console.error("Test fail ❌ ", error);
    });