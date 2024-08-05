const axios = require('axios');

const server = 'http://0.0.0.0:3000';
const homeServerPublicKey = '8pinxxgqs41n4aididenw5apqp1urfmzdztr8jt4abrkdn435ewo';

const createMessage = (message) => {
    return {
        chatId: Math.random().toString(36).substring(7),
        body: {
            message,
            timestamp: new Date().toISOString()
        }
    };
}

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
        secretKey,
        homeServerPublicKey
    });
    if (response.status !== 200) {
        throw new Error('POST /signup failed');
    }

    console.log('✅ Signup');

    
    // Save data
    const testMessagesToSend = [
        createMessage('Hello'),
        createMessage('World'),
        createMessage('Welcome to Pubky')
    ];
    
    for (const messageData of testMessagesToSend) {
        const { chatId, body } = messageData;
        response = await axios.post(`${server}/put`, {
            publicKey,
            url: chatStoreUrl(publicKey, chatId),
            body: body
        });
        if (response.status !== 200) {
            throw new Error('POST /put failed');
        }

        console.log('✅Sent message:', body.message);
    }

    //Show chat list
    response = await axios.get(`${server}/list`, {
        params: {
            url: chatStoreUrl(publicKey)
        }
    });
    if (response.status !== 200) {
        throw new Error('GET /list failed');
    }

    const chatList = response.data;

    console.log(`Chat list: ${JSON.stringify(chatList)}`);

    //Check count
    if (chatList.length !== testMessagesToSend.length) {
        throw new Error('Chat list count mismatch');
    }

    console.log('✅ Chat list');
  
    for (const chatUrl of chatList) {
        console.log(`Getting data for ${chatUrl}`);
        response = await axios.get(`${server}/get`, {
            params: {
              url: chatUrl
            }
          });
        if (response.status !== 200) {
            throw new Error('GET /get failed');
        }

        const data = response.data;

        console.log(`✅ Data: ${JSON.stringify(data)}`);
    }
    
    // Test delete chat
    response = await axios.post(`${server}/delete`, {
        publicKey,
        url: chatStoreUrl(publicKey, testMessagesToSend[0].chatId)
    });
    if (response.status !== 200) {
        throw new Error('DELETE /delete failed');
    }

    console.log('✅ First message deleted');

    response = await axios.get(`${server}/list`, {
        params: {
            url: chatStoreUrl(publicKey)
        }
    });
    if (response.status !== 200) {
        throw new Error('GET /list failed');
    }

    const chatList2 = response.data;

    console.log(`New chat list: ${JSON.stringify(chatList2)}`);
};

const chatStoreUrl = (publicKey, chatId) => {
    let url = `pubky://${publicKey}/pub/pubme.chat`;
  
    if (chatId) {
      url += `/${chatId}`;
    }
  
    return url;
  }

test()
    .then(() => {
        console.log("✅✅✅Test Success");
    }).catch((error) => {
        console.error("Test fail ❌ ", error);
    });