import express from 'express';
import { AccessToken } from 'livekit-server-sdk';

const app = express();
app.use(express.json());

app.post('/token', async (req, res) => {
  const { roomName, userId } = req.body || {};
  if (!roomName || !userId) return res.status(400).json({ error: 'roomName and userId are required' });

  const apiKey = process.env.LIVEKIT_API_KEY;
  const apiSecret = process.env.LIVEKIT_API_SECRET;
  if (!apiKey || !apiSecret) return res.status(500).json({ error: 'LiveKit server credentials are missing' });

  const token = new AccessToken(apiKey, apiSecret, { identity: userId, ttl: '10m' });
  token.addGrant({ roomJoin: true, room: roomName });
  res.json({ token: await token.toJwt() });
});

app.listen(process.env.PORT || 3000, () => console.log('Token server running'));
