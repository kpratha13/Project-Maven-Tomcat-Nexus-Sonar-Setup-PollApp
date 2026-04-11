<%@ page import="java.util.concurrent.ConcurrentHashMap" %>
<html>
<head>
    <title>DevOpsPulse - Live Poll</title>
    <style>
        body { font-family: 'Segoe UI', Arial; text-align: center; background: #f0f2f5; padding-top: 50px; }
        .poll-box { background: white; display: inline-block; padding: 30px; border-radius: 15px; shadow: 0 4px 10px rgba(0,0,0,0.1); }
        button { padding: 10px 20px; margin: 5px; cursor: pointer; border-radius: 5px; border: 1px solid #ddd; transition: 0.3s; }
        button:hover { background: #007bff; color: white; }
        .result-bar { background: #28a745; color: white; padding: 10px; margin: 10px 0; border-radius: 5px; text-align: left; }
    </style>
</head>
<body>
    <div class="poll-box">
        <h1>Which DevOps tool is your favorite?</h1>
        <form action="submit-vote" method="post" target="voter_frame">
            <button name="option" value="Docker">Docker</button>
            <button name="option" value="Kubernetes">Kubernetes</button>
            <button name="option" value="Terraform">Terraform</button>
            <button name="option" value="Jenkins">Jenkins</button>
        </form>
        <iframe name="voter_frame" style="display:none;"></iframe>
        <hr>
        <div id="live-results">Loading results...</div>
    </div>

    <script>
        function fetchVotes() {
            fetch('get-results')
                .then(res => res.text())
                .then(data => document.getElementById('live-results').innerHTML = data);
        }
        setInterval(fetchVotes, 2000); // Update every 2 seconds
        fetchVotes(); // Initial load
    </script>
</body>
</html>
