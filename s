<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IPTV Player</title>
    <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            background-color: #000;
            color: #fff;
            margin: 0;
            padding: 0;
        }
        #player-container {
            width: 80%;
            margin-top: 20px;
        }
        video {
            width: 100%;
            height: auto;
            border: 2px solid #fff;
        }
        #channel-list {
            margin-top: 20px;
            max-height: 300px;
            overflow-y: auto;
            width: 80%;
        }
        .channel {
            padding: 10px;
            border: 1px solid #fff;
            margin-bottom: 5px;
            cursor: pointer;
            background: #111;
            transition: background 0.3s;
        }
        .channel:hover {
            background: #333;
        }
    </style>
</head>
<body>
    <h1>IPTV Player</h1>
    <div id="player-container">
        <video id="video" controls></video>
    </div>
    <div id="channel-list">
        <!-- Lista de canales generada dinámicamente -->
    </div>

    <script>
        const video = document.getElementById('video');
        const channelList = document.getElementById('channel-list');

        // URL de tu lista M3U
        const playlistUrl = "https://zonamovie.live:8443/playlist/M4VSR2EnNF/N9Jg3DmfP4/m3u?output=hls";

        // Función para cargar y analizar la lista M3U
        const loadPlaylist = async () => {
            try {
                const response = await fetch(playlistUrl);
                const data = await response.text();
                const channels = parseM3U(data);
                generateChannelList(channels);
                if (channels.length > 0) {
                    loadChannel(channels[0].url); // Cargar el primer canal por defecto
                }
            } catch (error) {
                console.error("Error al cargar la lista M3U:", error);
            }
        };

        // Analiza la lista M3U y extrae los canales
        const parseM3U = (data) => {
            const lines = data.split('\n');
            const channels = [];
            for (let i = 0; i < lines.length; i++) {
                if (lines[i].startsWith('#EXTINF')) {
                    const name = lines[i].split(',')[1]; // Extrae el nombre del canal
                    const url = lines[i + 1]; // La URL está en la siguiente línea
                    if (url) channels.push({ name, url });
                }
            }
            return channels;
        };

        // Generar la lista de canales en la interfaz
        const generateChannelList = (channels) => {
            channels.forEach(channel => {
                const channelElement = document.createElement('div');
                channelElement.className = 'channel';
                channelElement.innerText = channel.name;
                channelElement.onclick = () => loadChannel(channel.url);
                channelList.appendChild(channelElement);
            });
        };

        // Cargar un canal en el reproductor
        const loadChannel = (url) => {
            if (Hls.isSupported()) {
                const hls = new Hls();
                hls.loadSource(url);
                hls.attachMedia(video);
                hls.on(Hls.Events.MANIFEST_PARSED, () => {
                    video.play();
                });
            } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
                video.src = url;
                video.play();
            } else {
                alert('Tu navegador no soporta HLS.');
            }
        };

        // Cargar la lista M3U al iniciar
        loadPlaylist();
    </script>
</body>
</html>
