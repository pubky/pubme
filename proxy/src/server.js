const fastify = require('fastify')({ logger: true });
const {PubkyClient, Keypair, PublicKey} = require('@synonymdev/pubky');

//Creates a new client per user. pubky => client
const clients = {};

fastify.post('/generate-key-pair', async (request, reply) => {
  let keypair = Keypair.random();

  reply.send({ secretKey: z32_string(keypair.secretKey()), publicKey: (keypair.publicKey().z32()) });
});

fastify.post('/signup', async (request, reply) => {
  console.log(request.body);
  const secretKey = request.body.secretKey;
  const homeServerPublicKey = request.body.homeServerPublicKey;

  const keypair = Keypair.fromSecretKey(z32ToBytes(secretKey));

  const homeserver = PublicKey.from(homeServerPublicKey);

  const client = PubkyClient.testnet();
  
  await client.signup(keypair, homeserver);

  clients[keypair.publicKey().z32()] = client;

  const session = await client.session(keypair.publicKey());
  if (!session) {
    throw new Error('Session not found');
  }

  console.log('✅ Session');

  reply.send({ message: 'Success' });
});

fastify.post('/put', async (request, reply) => {
  const publicKey = request.body.publicKey;
  const url = request.body.url;
  const body = request.body.body;

  const bytes = new TextEncoder().encode(JSON.stringify(body));

  console.log(`💾 ${url} ${JSON.stringify(body)}`);

  const client = clients[publicKey];

  await client.put(url, bytes);

  reply.send({ message: 'Data saved' });
});

fastify.get('/get', async (request, reply) => {
  //Decode the url from params
  const url = request.query.url;
  console.log(`📚 ${url}`);

  const publicClient = PubkyClient.testnet();
  const bytes = await publicClient.get(url);
  const body = JSON.parse(new TextDecoder().decode(bytes));

  console.log(`📚 ${url} ${JSON.stringify(body)}`);

  reply.send(body);
});

fastify.get('/list', async (request, reply) => {
  const url = request.query.url;

  const publicClient = PubkyClient.testnet();
  const list = await publicClient.list(url);

  reply.send(list);
});

fastify.post('/delete', async (request, reply) => {
  const publicKey = request.body.publicKey;
  const url = request.body.url;

  const client = clients[publicKey];

  await client.delete(url);

  reply.send({ message: 'Message deleted' });
});

module.exports = async ({host, port}) => {
  try {
    await fastify.listen({ port, host });
  } catch (err) {
    fastify.log.error(err);
    throw err;
  }
}

const zBase32Alphabet = 'ybndrfg8ejkmcpqxot1uwisza345h769';
const zBase32Map = new Map(zBase32Alphabet.split('').map((char, index) => [char, index]));
function z32_string(bytes) {
  let bits = 0;
  let value = 0;
  let output = '';

  for (let i = 0; i < bytes.length; i++) {
      value = (value << 8) | bytes[i];
      bits += 8;

      while (bits >= 5) {
          output += zBase32Alphabet[(value >>> (bits - 5)) & 31];
          bits -= 5;
      }
  }

  if (bits > 0) {
      output += zBase32Alphabet[(value << (5 - bits)) & 31];
  }

  return output;
}

function z32ToBytes(z32) {
  let bits = 0;
  let value = 0;
  let index = 0;
  const output = [];

  for (let i = 0; i < z32.length; i++) {
      value = (value << 5) | zBase32Map.get(z32[i]);
      bits += 5;

      if (bits >= 8) {
          output[index++] = (value >>> (bits - 8)) & 255;
          bits -= 8;
      }
  }

  return new Uint8Array(output);
}