const io = require("socket.io")(3001, {
  cors: {
    origin: "*",
  },
});

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const { v4: uuidv4 } = require('uuid'); 

io.on("connection", async (socket) => {
  console.log("new client connected");
  const uid = uuidv4();
  socket.uid = uid;

  socket.emit('uid', uid);

  // Retrieve and send all messages to the new client
  const messages = await prisma.message.findMany();
  console.log(messages);
  socket.emit('getMessages', messages);

  socket.on("disconnect", () => {
    console.log("disconnected");
  });

  socket.on("message", async (data) => {
    console.log(`Message received: ${data.message} from UID: ${socket.uid}`);
    
    // Broadcast the message to other clients
    socket.broadcast.emit("message", { uid: socket.uid, message: data.message });

    // Save the message in the database
    await prisma.message.create({
      data: {
        uid: socket.uid,
        message: data.message,
      },
    });
  });
});

io.on('error', (err) => {
  console.error('Server Error:', err);
});

console.log("Server is running on port 3001");

// const express = require('express');
// const http = require('http');
// const socketIo = require('socket.io');
// const { v4: uuidv4 } = require('uuid');

// const app = express();
// const server = http.createServer(app);
// const io = socketIo(server);

// const rooms = {};

// io.on('connection', (socket) => {
//   socket.on('createRoom', (callback) => {
//     const roomId = uuidv4();
//     rooms[roomId] = [];
//     callback(roomId);
//   });

//   socket.on('joinRoom', ({ roomId }, callback) => {
//     if (rooms[roomId]) {
//       rooms[roomId].push(socket.id);
//       socket.join(roomId);
//       callback(true);

//       if (rooms[roomId].length === 2) {
//         io.to(roomId).emit('ready');
//       }
//     } else {
//       callback(false);
//     }
//   });

//   socket.on('signal', (data) => {
//     const { roomId, signalData } = data;
//     socket.to(roomId).emit('signal', signalData);
//   });
//   const rooms = {};

//   io.on('connection', (socket) => {
//     socket.on('createRoom', (callback) => {
//       const roomId = uuidv4();
//       rooms[roomId] = [];
//       callback(roomId);
//     });

//     socket.on('joinRoom', ({ roomId }, callback) => {
//       if (rooms[roomId]) {
//         rooms[roomId].push(socket.id);
//         socket.join(roomId);
//         callback(true);

//         if (rooms[roomId].length === 2) {
//           io.to(roomId).emit('ready');
//         }
//       } else {
//         callback(false);
//       }
//     });

//     socket.on('signal', (data) => {
//       const { roomId, signalData } = data;
//       socket.to(roomId).emit('signal', signalData);
//     });
//   });

//   socket.on('offer', ({ roomId, description }) => {
//     socket.to(roomId).emit('offer', description);
//   });

//   socket.on('answer', ({ roomId, description }) => {
//     socket.to(roomId).emit('answer', description);
//   });

//   socket.on('candidate', ({ roomId, candidate }) => {
//     socket.to(roomId).emit('candidate', candidate);
//   });

//   socket.on('disconnect', () => {
//     console.log('Client disconnected: ' + socket.id);
//     for (const roomId in rooms) {
//       const index = rooms[roomId].indexOf(socket.id);
//       if (index !== -1) {
//         rooms[roomId].splice(index, 1);
//         if (rooms[roomId].length === 0) {
//           delete rooms[roomId];
//         }
//       }
//     }
//   });
// });

// server.listen(3000, () => console.log('Signaling server is running on port 3000'));
